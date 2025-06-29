################################################################################
<#
.SYNOPSIS
Opens one or more webbrowser instances.

.DESCRIPTION
Opens one or more webbrowsers in a configurable manner, using commandline
switches to control window position, size, and browser-specific features.

.PARAMETER Url
The URL or URLs to open in the browser. Can be provided via pipeline.

.PARAMETER Monitor
The monitor to use (0=default, -1=discard, -2=configured secondary).

.PARAMETER FullScreen
Opens browser in fullscreen mode.

.PARAMETER Width
Initial width of browser window.

.PARAMETER Height
Initial height of browser window.

.PARAMETER X
Initial X position of browser window.

.PARAMETER Y
Initial Y position of browser window.

.PARAMETER AcceptLang
Sets browser accept-lang HTTP header.

.PARAMETER Private
Opens in incognito/private browsing mode.

.PARAMETER Force
Force enable debugging port, stopping existing browsers if needed.

.PARAMETER Edge
Opens URLs in Microsoft Edge.

.PARAMETER Chrome
Opens URLs in Google Chrome.

.PARAMETER Chromium
Opens URLs in Microsoft Edge or Google Chrome, depending on default browser.

.PARAMETER Firefox
Opens URLs in Firefox.

.PARAMETER All
Opens URLs in all registered modern browsers.

.PARAMETER Left
Places browser window on left side of screen.

.PARAMETER Right
Places browser window on right side of screen.

.PARAMETER Top
Places browser window on top of screen.

.PARAMETER Bottom
Places browser window on bottom of screen.

.PARAMETER Centered
Places browser window in center of screen.

.PARAMETER ApplicationMode
Hides browser controls.

.PARAMETER NoBrowserExtensions
Prevents loading of browser extensions.

.PARAMETER DisablePopupBlocker
Disable the popup blocker.

.PARAMETER RestoreFocus
Restores PowerShell window focus after opening browser.

.PARAMETER NewWindow
Creates new browser window instead of reusing existing one.

.PARAMETER PassThru
Returns browser process object.

.EXAMPLE

url from parameter
PS> Open-Webbrowser -Chrome -Left -Top -Url "https://genxdev.net/"

urls from pipeline
PS> @("https://genxdev.net/", "https://github.com/genXdev/") | Open-Webbrowser

re-position already open window to primary monitor on right side
PS> Open-Webbrowser -Monitor 0 -right

re-position already open window to secondary monitor, full screen
PS> Open-Webbrowser -Monitor 0

re-position already open window to secondary monitor, left top
PS> Open-Webbrowser -Monitor 0 -Left -Top
PS> wb -m 0 -left -top

.NOTES
Requires the Windows 10+ Operating System

This cmdlet was mend to be used, interactively.
It performs some strange tricks to position windows, including invoking alt-tab keystrokes.
It's best not to touch the keyboard or mouse, while it is doing that.

For fast launches of multple urls:
SET    : -Monitor -1
AND    : DO NOT use any of these switches: -X, -Y, -Left, -Right, -Top, -Bottom or -RestoreFocus

For browsers that are not installed on the system, no actions may be performed or errors occur - at all.
#>
function Open-Webbrowser {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    [Alias("wb")]

    param(
        ###############################################################################
        [parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $false,
            HelpMessage = "The URLs to open in the browser"
        )]
        [Alias("Value", "Uri", "FullName", "Website", "WebsiteUrl")]
        [string[]] $Url,

        ###############################################################################
        [Alias("m", "mon")]
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = ("The monitor to use, 0 = default, -1 is discard, " +
                "-2 = Configured secondary monitor, defaults to " +
                "`Global:DefaultSecondaryMonitor or 2 if not found")
        )]
        [int] $Monitor = -2,

        ###############################################################################
        [Alias("fs", "f")]
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "Opens in fullscreen mode"
        )]
        [switch] $FullScreen,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 3,
            HelpMessage = "The initial width of the webbrowser window"
        )]
        [int] $Width = -1,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 4,
            HelpMessage = "The initial height of the webbrowser window"
        )]
        [int] $Height = -1,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 5,
            HelpMessage = "The initial X position of the webbrowser window"
        )]
        [int] $X = -999999,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 6,
            HelpMessage = "The initial Y position of the webbrowser window"
        )]
        [int] $Y = -999999,

        ###############################################################################
        [Alias("lang", "locale")]
        [Parameter(
            Mandatory = $false,
            Position = 7,
            HelpMessage = "Set the browser accept-lang http header"
        )]
        [string] $AcceptLang = $null,

        ###############################################################################
        [Alias("incognito", "inprivate")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in incognito/private browsing mode"
        )]
        [switch] $Private,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Force enable debugging port, stopping existing " +
                "browsers if needed")
        )]
        [switch] $Force,

        ###############################################################################
        [Alias("e")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in Microsoft Edge"
        )]
        [switch] $Edge,

        ###############################################################################
        [Alias("ch")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in Google Chrome"
        )]
        [switch] $Chrome,

        ###############################################################################
        [Alias("c")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Opens in Microsoft Edge or Google Chrome, depending " +
                "on what the default browser is")
        )]
        [switch] $Chromium,

        ###############################################################################
        [Alias("ff")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in Firefox"
        )]
        [switch] $Firefox,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in all registered modern browsers"
        )]
        [switch] $All,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the left side of the screen"
        )]
        [switch] $Left,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the right side of the screen"
        )]
        [switch] $Right,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the top side of the screen"
        )]
        [switch] $Top,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the bottom side of the screen"
        )]
        [switch] $Bottom,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window in the center of the screen"
        )]
        [switch] $Centered,

        ###############################################################################
        [Alias("a", "app", "appmode")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Hide the browser controls"
        )]
        [switch] $ApplicationMode,

        ###############################################################################
        [Alias("de", "ne", "NoExtensions")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Prevent loading of browser extensions"
        )]
        [switch] $NoBrowserExtensions,

        ###############################################################################
        [Alias("allowpopups")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Disable the popup blocker"
        )]
        [switch] $DisablePopupBlocker,

        ###############################################################################
        [Alias("bg")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Restore PowerShell window focus"
        )]
        [switch] $RestoreFocus,

        ###############################################################################
        [Alias("nw", "new")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Don't re-use existing browser window, instead, " +
                "create a new one")
        )]
        [switch] $NewWindow,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Returns a [System.Diagnostics.Process] object of " +
                "the browserprocess")
        )]
        [switch] $PassThru
    )

    begin {

        # get all available screens/monitors on the system
        $allScreens = @([WpfScreenHelper.Screen]::AllScreens |
            Microsoft.PowerShell.Core\ForEach-Object { $PSItem })

        # output diagnostic information about the function call
        Microsoft.PowerShell.Utility\Write-Verbose ("Open-Webbrowser monitor = $Monitor, " +
            "urls=$($Url | Microsoft.PowerShell.Utility\ConvertTo-Json)")

        # track if url parameter was explicitly provided by user
        [bool] $urlSpecified = $true

        # check if no url was specified by the user
        if (($null -eq $Url) -or ($Url.Length -lt 1)) {

            $urlSpecified = $false

            # show the default help page from github when no url provided
            $Url = @("https://powershell.genxdev.net/")
        }
        else {

            # process and normalize each url provided
            $Url = $($Url |
                Microsoft.PowerShell.Core\ForEach-Object {

                    # clean up url by trimming quotes and spaces
                    $newUrl = $PSItem.Trim(" `"'".ToCharArray())
                    $filePath = $newUrl

                    try {
                        # try to expand the path in case it's a relative file path
                        $filePath = (GenXdev.FileSystem\Expand-Path $newUrl)
                    }
                    catch {
                        # ignore expansion errors for urls that aren't file paths
                    }

                    # check if the url refers to an existing local file
                    if ([IO.File]::Exists($filePath)) {

                        # convert local file path to file:// url format
                        $newUrl = ("file://" +
                            [Uri]::EscapeUriString($filePath.Replace("\", "/")))
                    }

                    $newUrl
                }
            )
        }

        # get reference to the powershell main window for focus restoration
        $powerShellWindow = GenXdev.Windows\Get-PowershellMainWindow

        # retrieve list of all available/installed modern webbrowsers
        $browsers = GenXdev.Webbrowser\Get-Webbrowser

        # get the system's configured default webbrowser
        $defaultBrowser = GenXdev.Webbrowser\Get-DefaultWebbrowser

        # set primary monitor as the initial screen reference
        $screen = [WpfScreenHelper.Screen]::PrimaryScreen
        $allScreens = @([WpfScreenHelper.Screen]::AllScreens |
            Microsoft.PowerShell.Core\ForEach-Object { $PSItem })

        # determine which monitor to use based on monitor parameter
        if ($Monitor -eq 0) {

            Microsoft.PowerShell.Utility\Write-Verbose ("Choosing primary monitor, " +
                "because default monitor requested using -Monitor 0")
        }
        else {
            # check if secondary monitor was requested and global variable is set
            if ($Monitor -eq -2 -and $Global:DefaultSecondaryMonitor -is [int] -and
                $Global:DefaultSecondaryMonitor -ge 0) {

                Microsoft.PowerShell.Utility\Write-Verbose ("Picking monitor " +
                    "#$((($Global:DefaultSecondaryMonitor-1) % $allScreens.Length)) " +
                    "as secondary (requested with -monitor -2) set by " +
                    "`$Global:DefaultSecondaryMonitor")
                $screen = $allScreens[($Global:DefaultSecondaryMonitor - 1) %
                    $allScreens.Length]
            }
            # check if secondary monitor requested but no global variable set
            elseif ($Monitor -eq -2 -and
                (-not ($Global:DefaultSecondaryMonitor -is [int] -and
                        $Global:DefaultSecondaryMonitor -ge 0)) -and
                ((GenXdev.Windows\Get-MonitorCount) -gt 1)) {

                Microsoft.PowerShell.Utility\Write-Verbose ("Picking monitor #1 " +
                    "as default secondary (requested with -monitor -2), because " +
                    "`$Global:DefaultSecondaryMonitor not set")
                $screen = $allScreens[1]
            }
            # check if specific monitor number was requested
            elseif ($Monitor -ge 1) {

                Microsoft.PowerShell.Utility\Write-Verbose ("Picking monitor " +
                    "#$(($Monitor - 1) % $allScreens.Length) as requested by " +
                    "the -Monitor parameter")
                $screen = $allScreens[($Monitor - 1) % $allScreens.Length]
            }
            else {

                Microsoft.PowerShell.Utility\Write-Verbose ("Picking monitor #1 " +
                    "(same as PowerShell), because no monitor specified")
                $screen = [WpfScreenHelper.Screen]::FromPoint(@{
                        X = $powerShellWindow[0].Position().X
                        Y = $powerShellWindow[0].Position().Y
                    })
            }
        }

        # determine if any window positioning parameters were provided
        [bool] $havePositioning = (($Monitor -ge 0 -or $Monitor -eq -2) -or
            ($Left -or $Right -or $Top -or $Bottom -or $Centered -or
                (($X -is [int]) -and ($X -gt -999999)) -or
                (($Y -is [int]) -and ($Y -gt -999999)))) -and -not $FullScreen

        # initialize window x position based on parameters or screen defaults
        if (($X -le -999999) -or ($X -isnot [int])) {

            $X = $screen.WorkingArea.X
        }
        else {

            # adjust x position relative to selected monitor if monitor specified
            if ($Monitor -ge 0) {

                $X = $screen.WorkingArea.X + $X
            }
        }

        # initialize window y position based on parameters or screen defaults
        if (($Y -le -999999) -or ($Y -isnot [int])) {

            $Y = $screen.WorkingArea.Y
        }
        else {

            # adjust y position relative to selected monitor if monitor specified
            if ($Monitor -ge 0) {

                $Y = $screen.WorkingArea.Y + $Y
            }
        }

        # create state object to track browser window positioning and processes
        $state = @{
            existingWindow    = $false
            hadVisibleBrowser = $false
            Browser           = $null
            IsDefaultBrowser  = ((-not $All) -and
                ((-not $Chromium) -or ($defaultBrowser.Name -like "*chrome*") -or
                    ($defaultBrowser.Name -like "*edge*")) -and
                ((-not $Chrome) -or ($defaultBrowser.Name -like "*chrome*")) -and
                ((-not $Edge) -or ($defaultBrowser.Name -like "*edge*")) -and
                ((-not $Firefox) -or ($defaultBrowser.Name -like "*firefox*")))
            FirstProcess      = $null
            PositioningDone   = $false
            BrowserWindow     = $null
        }

        # determine if we can use simple start-process instead of complex positioning
        $useStartProcess = (-not ($havePositioning -or $FullScreen)) -and
        $state.IsDefaultBrowser

        # configure window dimensions and positioning if positioning is required
        if ($havePositioning -or $FullScreen) {

            # check if width parameter was explicitly provided
            $widthProvided = ($Width -gt 0) -and ($Width -is [int])

            # check if height parameter was explicitly provided
            $heightProvided = ($Height -gt 0) -and ($Height -is [int])

            # set default width if not provided by user
            if ($widthProvided -eq $false) {

                $Width = $screen.WorkingArea.Width
            }

            # set default height if not provided by user
            if ($heightProvided -eq $false) {

                $Height = $screen.WorkingArea.Height
            }

            # configure window position and size for left side placement
            if ($Left -eq $true) {

                $X = $screen.WorkingArea.X

                # use half screen width if width not explicitly provided
                if ($widthProvided -eq $false) {

                    $Width = [Math]::Min($screen.WorkingArea.Width / 2, $Width)
                }

                # use full screen height if height not explicitly provided
                if ($heightProvided -eq $false) {

                    $Height = [Math]::Min($screen.WorkingArea.Height, $Height)
                }
                $Y = $screen.WorkingArea.Y

                return
            }

            # configure window position and size for right side placement
            if ($Right -eq $true) {

                # use half screen width if width not explicitly provided
                if ($widthProvided -eq $false) {

                    $Width = [Math]::Min($screen.WorkingArea.Width / 2, $Width)
                }

                # position window on right side of screen
                $X = $screen.WorkingArea.X + $screen.WorkingArea.Width - $Width
                $Y = ($screen.WorkingArea.Y +
                    [Math]::Round(($screen.WorkingArea.Height - $Height) / 2, 0))

                # use full screen height if height not explicitly provided
                if ($heightProvided -eq $false) {

                    $Height = [Math]::Min($screen.WorkingArea.Height, $Height)
                }
                $Y = $screen.WorkingArea.Y
                return
            }

            # configure window position and size for top placement
            if ($Top -eq $true) {

                $Y = $screen.WorkingArea.Y

                # use half screen height if height not explicitly provided
                if ($heightProvided -eq $false) {

                    $Height = [Math]::Min($screen.WorkingArea.Height / 2, $Height)
                    $X = $screen.WorkingArea.X
                }
                $Width = $screen.WorkingArea.Width
                $X = $screen.WorkingArea.X
                return
            }

            # configure window position and size for bottom placement
            if ($Bottom -eq $true) {

                # use half screen height if height not explicitly provided
                if ($heightProvided -eq $false) {

                    $Height = [Math]::Min($screen.WorkingArea.Height / 2, $Height)
                }

                $Width = $screen.WorkingArea.Width

                # position window at bottom of screen
                $Y = $screen.WorkingArea.Y + $screen.WorkingArea.Height - $Height
                $X = $screen.WorkingArea.X
                return
            }

            # configure window position and size for centered placement
            if ($Centered -eq $true) {

                # use 80% of screen height if height not explicitly provided
                if ($heightProvided -eq $false) {

                    $Height = [Math]::Round([Math]::Min(
                            $screen.WorkingArea.Height * 0.8, $Height), 0)
                }

                # use 80% of screen width if width not explicitly provided
                if ($widthProvided -eq $false) {

                    $Width = [Math]::Round([Math]::Min(
                            $screen.WorkingArea.Width * 0.8, $Width), 0)
                }

                # center window on screen
                $X = ($screen.WorkingArea.X +
                    [Math]::Round(($screen.WorkingArea.Width - $Width) / 2, 0))
                $Y = ($screen.WorkingArea.Y +
                    [Math]::Round(($screen.WorkingArea.Height - $Height) / 2, 0))

                return
            }
        }
    }

    ###########################################################################
    process {

        ###########################################################################
        <#
        .SYNOPSIS
        Ensures minimum delay between browser window close and open operations.

        .DESCRIPTION
        This helper function prevents timing issues when repositioning browser
        windows by enforcing a minimum delay since the last browser close.

        .PARAMETER browser
        The browser object to check timing delays for.
        #>
        function enforceMinimumDelays($browser) {

            # skip delay enforcement if no positioning is required
            if ($havePositioning -eq $false) {

                return
            }

            # get the last close time for this specific browser
            $last = (Microsoft.PowerShell.Utility\Get-Variable -Scope Global `
                    -Name "_LastClose$($browser.Name)" -ErrorAction SilentlyContinue)

            # check if we have a valid last close timestamp
            if (($null -ne $last) -and ($last.Value -is [DateTime])) {

                $now = [DateTime]::UtcNow

                # enforce minimum 1 second delay since last close
                if ($now - $last.Value -lt [System.TimeSpan]::FromSeconds(1)) {

                    $null = [System.Threading.Thread]::Sleep(200)
                }
            }
        }

        ###########################################################################
        <#
        .SYNOPSIS
        Constructs browser-specific command line arguments.

        .DESCRIPTION
        Builds the appropriate command line argument list based on the browser
        type and user-specified parameters for launching the browser process.

        .PARAMETER browser
        The browser object containing executable path and type information.

        .PARAMETER currentUrl
        The URL to open in the browser.

        .PARAMETER state
        The state object tracking browser window positioning and process info.
        #>
        function constructArgumentList($browser, $currentUrl, $state) {

            # initialize empty argument list for browser command line
            $argumentList = @()

            ###################################################################

            # handle firefox-specific command line arguments
            if ($browser.Name -like "*Firefox*") {

                # set default firefox command line parameters
                $argumentList = @()

                # add window size parameters if both width and height specified
                if (($Width -is [int]) -and ($Width -gt 0) -and
                    ($Height -is [int]) -and ($Height -gt 0)) {

                    $argumentList = $argumentList + @("-width", $Width,
                        "-height", $Height)
                }

                # set foreground mode unless restore focus is requested
                if ($RestoreFocus -ne $true) {

                    # set firefox to foreground on startup
                    $argumentList = $argumentList + @("-foreground")
                }

                # disable browser extensions if requested
                if ($NoBrowserExtensions -eq $true) {

                    $argumentList = $argumentList + @("-safe-mode")
                }

                # disable popup blocker if requested
                if ($DisablePopupBlocker -eq $true) {

                    $argumentList = $argumentList + @("-disable-popup-blocking")
                }

                # set accept language header if provided
                if ($null -ne $AcceptLang) {

                    $argumentList = $argumentList + @("--lang", $AcceptLang)
                }

                # handle private browsing mode for firefox
                if ($Private -eq $true) {

                    # open url in firefox private window
                    $argumentList = $argumentList + @("-private-window",
                        $currentUrl)
                }
                else {

                    # handle application mode for firefox
                    if ($ApplicationMode -eq $true) {

                        Microsoft.PowerShell.Utility\Write-Warning ("Firefox " +
                            "does not support -ApplicationMode at this time")

                        GenXdev.Webbrowser\Approve-FirefoxDebugging

                        # use single site browser mode for firefox app mode
                        $argumentList = $argumentList + @("--ssb", $currentUrl)
                    }
                    else {

                        # handle new window creation for firefox
                        if ((-not $state.PositioningDone) -and
                            ($NewWindow -eq $true)) {

                            # create new firefox window with url
                            $argumentList = $argumentList + @("--new-window",
                                $currentUrl)
                        }
                        else {

                            # open url in existing or new firefox tab
                            $argumentList = $argumentList + @("-url", $currentUrl)
                        }
                    }
                }
            }
            else {
                ###############################################################

                # handle chromium-based browsers (edge and chrome)
                if ($browser.Name -like "*Edge*" -or
                    $browser.Name -like "*Chrome*") {

                    # get the appropriate debugging port for this browser type
                    $port = GenXdev.Webbrowser\Get-ChromiumRemoteDebuggingPort `
                        -Chrome:$Chrome -Edge:$Edge

                    # set default chromium command line parameters
                    # reference: https://peter.sh/experiments/chromium-command-line-switches/
                    $argumentList = $argumentList + @(
                        "--disable-infobars",
                        "--hide-crash-restore-bubble",
                        "--no-first-run",
                        "--disable-session-crashed-bubble",
                        "--disable-crash-reporter",
                        "--no-default-browser-check",
                        "--disable-restore-tabs",
                        "--remote-allow-origins=*",
                        "--remote-debugging-port=$port"
                    )

                    # add window size if both dimensions are specified
                    if (($Width -is [int]) -and ($Width -gt 0) -and
                        ($Height -is [int]) -and ($Height -gt 0)) {

                        $argumentList = $argumentList + @("--window-size=$Width,$Height")
                    }

                    # set initial window position
                    $argumentList = $argumentList + @("--window-position=$X,$Y")

                    # disable browser extensions if requested
                    if ($NoBrowserExtensions -eq $true) {

                        $argumentList = $argumentList + @("--disable-extensions")
                    }

                    # disable popup blocker if requested
                    if ($DisablePopupBlocker -eq $true) {

                        $argumentList = $argumentList + @("--disable-popup-blocking")
                    }

                    # set accept language header if provided
                    if ($null -ne $AcceptLang) {

                        $argumentList = $argumentList + @("--accept-lang=$AcceptLang")
                    }

                    # handle private browsing mode for chromium browsers
                    if ($Private -eq $true) {

                        # force new window for private mode
                        $NewWindow = $true

                        # set appropriate private browsing flag
                        if ($browser.Name -like "*Edge*") {

                            # use edge inprivate mode
                            $argumentList = $argumentList + @("-InPrivate")
                        }
                        else {
                            # use chrome incognito mode
                            $argumentList = $argumentList + @("--incognito")
                        }
                    }

                    # force new window creation if requested and not positioned yet
                    if ((-not $state.PositioningDone) -and ($NewWindow -eq $true)) {

                        # force creation of new browser window
                        $argumentList = $argumentList + @("--new-window") +
                        @("--force-launch-browser")
                    }

                    # set window to start maximized by default
                    $argumentList = $argumentList + @("--start-maximized")

                    # handle application mode for chromium browsers
                    if ($ApplicationMode -eq $true) {

                        # run browser in application mode with specific url
                        $argumentList = $argumentList + @("--app=$currentUrl")
                    }
                    else {
                        # add url to standard command line arguments
                        $argumentList = $argumentList + @($currentUrl)
                    }
                }
                else {
                    ###########################################################

                    # handle default/other browsers
                    if ($Private -eq $true) {

                        # private mode not supported for default browser
                        return
                    }

                    # add url as only argument for default browser
                    $argumentList = @($currentUrl)
                }
            }

            $argumentList
        }

        ###########################################################################
        <#
        .SYNOPSIS
        Finds and returns the browser process and main window.

        .DESCRIPTION
        Locates the browser process after launch and gets a reference to its
        main window handle for positioning and management operations.

        .PARAMETER browser
        The browser object containing executable information.

        .PARAMETER process
        The initial process object from browser launch.

        .PARAMETER state
        The state object tracking browser window and process information.
        #>
        function findProcess($browser, $process, $state) {

            # initialize window tracking variables
            $state.existingWindow = $false
            $window = @()

            # retry loop to find the browser process and window
            do {

                try {
                    # wait briefly for process to initialize
                    $null = [System.Threading.Thread]::Sleep(100)

                    # find the most recent browser process with main window
                    $processesNew = @(Microsoft.PowerShell.Management\Get-Process `
                            ([IO.Path]::GetFileNameWithoutExtension($browser.Path)) `
                            -ErrorAction SilentlyContinue |
                        Microsoft.PowerShell.Core\Where-Object -Property Path `
                            -EQ $browser.Path |
                        Microsoft.PowerShell.Core\Where-Object -Property MainWindowHandle `
                            -NE 0 |
                        Microsoft.PowerShell.Utility\Sort-Object `
                        { $PSItem.StartTime } -Descending |
                        Microsoft.PowerShell.Utility\Select-Object -First 1)

                    # check if no process was found
                    if (($processesNew.Length -eq 0) -or ($null -eq $processesNew[0])) {

                        Microsoft.PowerShell.Utility\Write-Verbose ("No process " +
                            "found, retrying..")
                        $window = @()

                        $null = [System.Threading.Thread]::Sleep(80)
                    }
                    else {

                        Microsoft.PowerShell.Utility\Write-Verbose "Found new process"

                        # get window helper utility for main window of process
                        $state.existingWindow = $state.hadVisibleBrowser
                        $process = $processesNew[0]
                        $window = [GenXdev.Helpers.WindowObj]::GetMainWindow($process,
                            1, 80)
                        break
                    }
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Verbose ("Error: " +
                        "$($_.Exception.Message)")
                    $window = @()
                    $null = [System.Threading.Thread]::Sleep(100)
                }
            } while (($i++ -lt 50) -and ($window.length -le 0))

            # return process and window information
            @{
                Process = $process
                Window  = $window
            }
        }

        ###########################################################################
        <#
        .SYNOPSIS
        Opens a browser with the specified URL and configuration.

        .DESCRIPTION
        Launches a browser process with the provided URL and handles window
        positioning, process management, and browser-specific configurations.

        .PARAMETER browser
        The browser object containing executable path and type information.

        .PARAMETER currentUrl
        The URL to open in the browser.

        .PARAMETER state
        The state object tracking browser positioning and process information.
        #>
        function open($browser, $currentUrl, $state) {

            Microsoft.PowerShell.Utility\Write-Verbose "open()"

            # determine if this browser is the system default
            $state.IsDefaultBrowser = $browser -eq $defaultBrowser

            # enforce timing delays for proper window positioning
            enforceMinimumDelays $browser

            # initialize browser launch variables
            $startBrowser = $true
            $state.hadVisibleBrowser = $false
            $process = $null

            # find any existing browser process with main window
            $prcBefore = @(Microsoft.PowerShell.Management\Get-Process `
                    ([IO.Path]::GetFileNameWithoutExtension($browser.Path)) `
                    -ErrorAction SilentlyContinue) |
                Microsoft.PowerShell.Core\Where-Object -Property Path -EQ $browser.Path |
                Microsoft.PowerShell.Core\Where-Object -Property MainWindowHandle -NE 0 |
                Microsoft.PowerShell.Utility\Sort-Object { $PSItem.StartTime } -Descending |
                Microsoft.PowerShell.Utility\Select-Object -First 1

            # check if existing browser window was found
            if ($state.PositioningDone -or (($prcBefore.Length -ge 1) -and
                    ($null -ne $prcBefore[0]))) {

                Microsoft.PowerShell.Utility\Write-Verbose ("Found existing " +
                    "webbrowser window")
                $state.hadVisibleBrowser = $true
            }

            # determine if we should skip launching new browser process
            if ((-not $NewWindow) -and
                (-not ($havePositioning -or $FullScreen)) -and
                (-not $urlSpecified)) {

                if ($state.hadVisibleBrowser) {

                    Microsoft.PowerShell.Utility\Write-Verbose ("No url specified, " +
                        "found existing webbrowser window")
                    $startBrowser = $false
                    $process = if ($state.FirstProcess) {
                        $state.FirstProcess
                    } else {
                        $prcBefore[0]
                    }
                }
            }

            # launch new browser process if needed
            if ($startBrowser) {

                # handle force parameter to ensure debug port availability
                if ($Force) {

                    try {
                        # try to get existing browser tabs with debug port
                        $a = GenXdev.Webbrowser\Select-WebbrowserTab `
                            -Chrome:$Chrome -Edge:$Edge
                    }
                    catch {
                        $a = @()
                    }

                    # close all browser instances if no debug port found
                    if ($a.length -eq 0 -or ($a -is [string])) {

                        Microsoft.PowerShell.Utility\Write-Verbose ("No browser " +
                            "with open debugger port found, closing all browser " +
                            "instances and starting a new one")
                        $null = Microsoft.PowerShell.Management\Get-Process `
                            -Name ([IO.Path]::GetFileNameWithoutExtension($browser.Path)) `
                            -ErrorAction SilentlyContinue |
                            Microsoft.PowerShell.Management\Stop-Process -Force `
                            -ErrorAction SilentlyContinue
                    }
                }

                # check if any browser processes currently exist
                $currentProcesses = @((Microsoft.PowerShell.Management\Get-Process `
                        -Name ([IO.Path]::GetFileNameWithoutExtension($browser.Path)) `
                        -ErrorAction SilentlyContinue))
                if ($currentProcesses.Count -eq 0) {

                    $NewWindow = $false
                }

                # get browser-specific command line arguments
                $argumentList = constructArgumentList $browser $currentUrl $state

                # output verbose information about browser launch
                Microsoft.PowerShell.Utility\Write-Verbose ("$($browser.Name) --> " +
                    "$($argumentList | Microsoft.PowerShell.Utility\ConvertTo-Json)")

                # start the browser process with constructed arguments
                $process = Microsoft.PowerShell.Management\Start-Process `
                    -FilePath ($browser.Path) -ArgumentList $argumentList -PassThru

                # wait briefly for process to initialize
                $null = $process.WaitForExit(200)
                $null = [System.Threading.Thread]::Sleep(200)
            }

            # validate that we have a valid process
            if ($null -eq $process) {

                Microsoft.PowerShell.Utility\Write-Warning ("Could not start " +
                    "browser $($browser.Name)")
                return
            }

            # skip positioning if not needed or already done
            if ((-not $PassThru) -and
                ((-not ($havePositioning -or ($FullScreen -and
                            -not $state.PositioningDone))) -or $state.PositioningDone)) {

                Microsoft.PowerShell.Utility\Write-Verbose ("No positioning " +
                    "required, done..")
                return
            }

            # return process object if passthru requested
            if ($PassThru) {

                # return first process if positioning done and process available
                if (($state.PositioningDone -or
                        ((-not $FullScreen) -and (-not $havePositioning))) -and
                    ($null -ne $state.FirstProcess) -and
                    (-not $state.FirstProcess.HasExited) -and
                    ($state.FirstProcess.MainWindowHandle -ne 0)) {

                    Microsoft.PowerShell.Utility\Write-Verbose ("Returning " +
                        "first process")
                    Microsoft.PowerShell.Utility\Write-Output $state.FirstProcess
                    return
                }

                # return current process if valid and has window
                if (($null -ne $process) -and (-not $process.HasExited) -and
                    ($process.MainWindowHandle -ne 0)) {

                    Microsoft.PowerShell.Utility\Write-Verbose "Returning process"
                    Microsoft.PowerShell.Utility\Write-Output $process

                    if (-not $havePositioning) {

                        return
                    }
                }
            }

            # allow browser startup time and update process handle if needed
            enforceMinimumDelays $browser
            $browserFound = findProcess $browser $process $state
            $process = $browserFound.Process
            $window = $browserFound.Window

            # return process after lookup if passthru requested
            if (($PassThru -eq $true) -and ($null -ne $process)) {

                Microsoft.PowerShell.Utility\Write-Verbose ("Returning process " +
                    "after process lookup")
                Microsoft.PowerShell.Utility\Write-Output $process
            }

            # skip positioning if not required or already completed
            if ((-not ($havePositioning -or ($FullScreen -and
                        -not $state.PositioningDone))) -or $state.PositioningDone) {

                Microsoft.PowerShell.Utility\Write-Verbose ("No positioning " +
                    "required, done..")
                return
            }

            # mark positioning as completed and store first process
            $state.PositioningDone = $true
            $state.FirstProcess = $process

            # position browser window if we have a valid window handle
            if ($window.Length -eq 1) {

                # store browser window reference for later use
                $state.BrowserWindow = $window[0]

                Microsoft.PowerShell.Utility\Write-Verbose ("Restoring and " +
                    "positioning browser window")

                # restore window if not in fullscreen mode
                if (-not $FullScreen) {

                    $null = $window[0].Show()
                    $null = $window[0].Restore()
                }

                # move and resize window to specified position and dimensions
                $null = $window[0].Move($X, $Y, $Width, $Height)
            }

            # wait for window positioning to complete
            Microsoft.PowerShell.Utility\Start-Sleep 2
        }

        # initialize url processing index counter
        $index = -1
        try {
            # iterate through each url that needs to be opened
            foreach ($currentUrl in $Url) {

                $index++
                Microsoft.PowerShell.Utility\Write-Verbose "Opening $currentUrl"

                # use simple start-process for default browser without positioning
                if ($useStartProcess -or (($index -gt 0) -and
                        ($state.IsDefaultBrowser))) {

                    Microsoft.PowerShell.Utility\Write-Verbose "Start-Process"

                    # launch default browser with simple start-process method
                    $process = Microsoft.PowerShell.Management\Start-Process $currentUrl `
                        -PassThru

                    # return process if passthru requested for first launch
                    if ($PassThru -and $useStartProcess -and ($index -eq 0)) {

                        $browserFound = findProcess $defaultBrowser $process $state

                        $process = $browserFound.Process
                        $window = $browserFound.Window

                        Microsoft.PowerShell.Utility\Write-Verbose ("Returning " +
                            "process after Start-Process")
                        Microsoft.PowerShell.Utility\Write-Output $process
                    }

                    continue
                }

                # handle opening url in all available browsers
                if ($All -eq $true) {

                    # open current url in all installed browsers
                    $browsers |
                        Microsoft.PowerShell.Core\ForEach-Object {
                            open $PSItem $currentUrl $state
                        }

                    continue
                }
                # handle chrome-specific browser selection
                elseif ($Chrome -eq $true) {

                    # find and open chrome browser instances
                    $browsers |
                        Microsoft.PowerShell.Core\ForEach-Object {

                            # check if this is a chrome browser
                            if ($PSItem.Name -like "*Chrome*") {

                                # open url in chrome
                                open $PSItem $currentUrl $state
                            }
                        }
                }
                # handle edge-specific browser selection
                elseif ($Edge -eq $true) {

                    # find and open edge browser instances
                    $browsers |
                        Microsoft.PowerShell.Core\ForEach-Object {

                            # check if this is an edge browser
                            if ($PSItem.Name -like "*Edge*") {

                                # open url in edge
                                open $PSItem $currentUrl $state
                            }
                        }
                }
                # handle chromium-based browser preference (edge or chrome)
                elseif ($Chromium -eq $true) {

                    # check if default browser is already chromium-based
                    if (($defaultBrowser.Name -like "*Chrome*") -or
                        ($defaultBrowser.Name -like "*Edge*")) {

                        # use default browser since it's already chromium-based
                        open $defaultBrowser $currentUrl $state
                        continue
                    }

                    # find available chromium-based browsers
                    $browsers |
                        Microsoft.PowerShell.Utility\Sort-Object { $PSItem.Name } `
                        -Descending |
                        Microsoft.PowerShell.Core\ForEach-Object {

                            # check if this is a chromium-based browser
                            if (($PSItem.Name -like "*Chrome*") -or
                                ($PSItem.Name -like "*Edge*")) {

                                # open url in chromium-based browser
                                open $PSItem $currentUrl $state
                            }
                        }
                }

                # handle firefox-specific browser selection
                if ($Firefox -eq $true) {

                    # find and open firefox browser instances
                    $browsers |
                        Microsoft.PowerShell.Core\ForEach-Object {

                            # check if this is a firefox browser
                            if ($PSItem.Name -like "*Firefox*") {

                                # open url in firefox
                                open $PSItem $currentUrl $state
                            }
                        }
                }

                # use default browser when no specific browser requested
                if (($Chromium -ne $true) -and ($Chrome -ne $true) -and
                    ($Edge -ne $true) -and ($Firefox -ne $true)) {

                    # open url in system default browser
                    open $defaultBrowser $currentUrl $state
                }
            }
        }
        finally {

            # handle fullscreen mode activation after all urls processed
            if ($FullScreen -eq $true) {

                Microsoft.PowerShell.Utility\Write-Verbose "Setting fullscreen"

                # use browser window reference if available
                if ($null -ne $state.BrowserWindow) {

                    Microsoft.PowerShell.Utility\Write-Verbose ("Changing focus " +
                        "to browser window")

                    try {
                        $null = $state.BrowserWindow.Maximize()
                        $null = $state.BrowserWindow.SetForeground()
                    }
                    catch {
                        # ignore window manipulation errors
                    }
                    $tt = 0
                    $focusedWindowProcess = GenXdev.Windows\Get-CurrentFocusedProcess

                    # wait for browser window to receive focus
                    while (($tt++ -lt 20) -and
                        (($null -eq $focusedWindowProcess) -or
                            ($focusedWindowProcess.MainWindowHandle -ne
                                $state.BrowserWindow.Handle))) {

                        Microsoft.PowerShell.Utility\Write-Verbose ("have browser " +
                            "window, sleeping 500ms")
                        $null = [System.Threading.Thread]::Sleep(500)

                        try {
                            $null = $state.BrowserWindow.Maximize()
                            $null = $state.BrowserWindow.SetForeground()
                        }
                        catch {
                            # ignore window manipulation errors
                        }
                        $null = GenXdev.Windows\Set-ForegroundWindow `
                            ($state.BrowserWindow.Handle)

                        $focusedWindowProcess = GenXdev.Windows\Get-CurrentFocusedProcess
                    }
                }
                else {
                    Microsoft.PowerShell.Utility\Write-Verbose ("Setting " +
                        "fullscreen without having reference to browser window")
                    $tt = 0
                    $focusedWindowProcess = GenXdev.Windows\Get-CurrentFocusedProcess
                    $powershellWindow = GenXdev.Windows\Get-PowershellMainWindow

                    # wait for powershell window focus before sending f11
                    while (($tt++ -lt 20) -and
                        (($null -eq $focusedWindowProcess) -or
                            ($null -eq $powerShellWindow) -or
                            ($focusedWindowProcess.MainWindowHandle -ne
                                $powerShellWindow.Handle))) {
                        Microsoft.PowerShell.Utility\Write-Verbose ("no browser " +
                            "window, sleeping 500ms")
                        $null = [System.Threading.Thread]::Sleep(500)

                        $focusedWindowProcess = GenXdev.Windows\Get-CurrentFocusedProcess
                        $powershellWindow = GenXdev.Windows\Get-PowershellMainWindow
                    }
                }

                # send f11 key to activate fullscreen if browser has focus
                if ((GenXdev.Windows\Get-CurrentFocusedProcess).MainWindowHandle -ne
                    (GenXdev.Windows\Get-PowershellMainWindow).Handle) {
                    try {

                        # create com object to send f11 key press
                        $helper = Microsoft.PowerShell.Utility\New-Object `
                            -ComObject WScript.Shell
                        $null = $helper.sendKeys("{F11}")
                        Microsoft.PowerShell.Utility\Write-Verbose "Sending F11"
                        $null = [System.Threading.Thread]::Sleep(500)
                    }
                    catch {
                        # ignore key sending errors
                    }
                }
            }
        }
    }
    ###########################################################################

    end {

        # restore powershell window focus if requested
        if ($RestoreFocus) {

            # get reference to powershell main window
            $powerShellWindow = GenXdev.Windows\Get-PowershellMainWindow

            # restore focus to powershell window if it exists
            if ($null -ne $powerShellWindow) {

                # wait briefly before restoring focus
                $null = [System.Threading.Thread]::Sleep(500)

                # show and bring powershell window to foreground
                $null = $powerShellWindow.Show()
                $null = $powerShellWindow.SetForeground()

                # ensure powershell window receives focus
                $null = GenXdev.Windows\Set-ForegroundWindow `
                    ($powerShellWindow.Handle)
            }
        }
    }
}
################################################################################
