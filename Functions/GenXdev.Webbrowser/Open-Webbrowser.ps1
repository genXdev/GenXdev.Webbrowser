###############################################################################

<#
.SYNOPSIS
Opens one or more webbrowser instances.

.DESCRIPTION
Opens one or more webbrowsers in a configurable manner, using commandline
switches to control window position, size, and browser-specific features.

.PARAMETER Url
The URL or URLs to open in the browser. Can be provided via pipeline.

.PARAMETER Private
Opens in incognito/private browsing mode.

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

.PARAMETER AcceptLang
Sets browser accept-lang HTTP header.

.PARAMETER RestoreFocus
Restores PowerShell window focus after opening browser.

.PARAMETER NewWindow
Creates new browser window instead of reusing existing one.

.PARAMETER PassThru
Returns browser process object.

.PARAMETER Force
Forces debugging port enabled, stopping existing browser processes if needed.

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
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in incognito/private browsing mode"
        )]
        [Alias("incognito", "inprivate")]
        [switch] $Private,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force enable debugging port, stopping existing browsers if needed"
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
            HelpMessage = "Opens in Microsoft Edge or Google Chrome, depending on what the default browser is"
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
        [Alias("m", "mon")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The monitor to use, 0 = default, -1 is discard, -2 = Configured secondary monitor, defaults to `Global:DefaultSecondaryMonitor or 2 if not found"
        )]
        [int] $Monitor = -2,

        ###############################################################################
        [Alias("fs", "f")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in fullscreen mode"
        )]
        [switch] $FullScreen,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial width of the webbrowser window"
        )]
        [int] $Width = -1,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial height of the webbrowser window"
        )]
        [int] $Height = -1,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial X position of the webbrowser window"
        )]
        [int] $X = -999999,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial Y position of the webbrowser window"
        )]
        [int] $Y = -999999,

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
        [Alias("lang", "locale")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Set the browser accept-lang http header"
        )]
        [string] $AcceptLang = $null,

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
            HelpMessage = "Don't re-use existing browser window, instead, create a new one"
        )]
        [switch] $NewWindow,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Returns a [System.Diagnostics.Process] object of the browserprocess"
        )]
        [switch] $PassThru
    )

    begin {
        $AllScreens = @([WpfScreenHelper.Screen]::AllScreens | ForEach-Object { $PSItem });

        Write-Verbose "Open-Webbrowser monitor = $Monitor, Urls=$($Url | ConvertTo-Json)"

        [bool] $UrlSpecified = $true;

        # what if no url is specified?
        if (($null -eq $Url) -or ($Url.Length -lt 1)) {

            $UrlSpecified = $false;

            # show the help page from github
            $Url = @("https://powershell.genxdev.net/")
        }
        else {

            $Url = $($Url | ForEach-Object {

                    $NewUrl = $PSItem.Trim(" `"'".ToCharArray());
                    $filePath = $NewUrl
                    try {
                        $filePath = (GenXdev.FileSystem\Expand-Path $NewUrl);
                    }
                    catch {

                    }

                    if ([IO.File]::Exists($filePath)) {

                        $NewUrl = "file://$([Uri]::EscapeUriString($filePath.Replace("\", "/")))"
                    }

                    $NewUrl
                }
            );
        }

        # reference powershell main window
        $PowerShellWindow = Get-PowershellMainWindow

        # get a list of all available/installed modern webbrowsers
        $Browsers = Get-Webbrowser

        # get the configured default webbrowser
        $DefaultBrowser = Get-DefaultWebbrowser

        # reference the main monitor
        $Screen = [WpfScreenHelper.Screen]::PrimaryScreen;
        $AllScreens = @([WpfScreenHelper.Screen]::AllScreens | ForEach-Object { $PSItem });

        # reference the requested monitor
        if ($Monitor -eq 0) {

            Write-Verbose "Choosing primary monitor, because default monitor requested using -Monitor 0"
        }
        else {
            if ($Monitor -eq -2 -and $Global:DefaultSecondaryMonitor -is [int] -and $Global:DefaultSecondaryMonitor -ge 0) {

                Write-Verbose "Picking monitor #$((($Global:DefaultSecondaryMonitor-1) % $AllScreens.Length)) as secondary (requested with -monitor -2) set by `$Global:DefaultSecondaryMonitor"
                $Screen = $AllScreens[($Global:DefaultSecondaryMonitor - 1) % $AllScreens.Length];
            }
            elseif ($Monitor -eq -2 -and (-not ($Global:DefaultSecondaryMonitor -is [int] -and $Global:DefaultSecondaryMonitor -ge 0)) -and ((Get-MonitorCount) -gt 1)) {

                Write-Verbose "Picking monitor #1 as default secondary (requested with -monitor -2), because `$Global:DefaultSecondaryMonitor not set"
                $Screen = $AllScreens[1];
            }
            elseif ($Monitor -ge 1) {

                Write-Verbose "Picking monitor #$(($Monitor - 1) % $AllScreens.Length) as requested by the -Monitor parameter"
                $Screen = $AllScreens[($Monitor - 1) % $AllScreens.Length]
            }
            else {

                Write-Verbose "Picking monitor #1 (same as PowerShell), because no monitor specified"
                $Screen = [WpfScreenHelper.Screen]::FromPoint(@{X = $PowerShellWindow[0].Position().X; Y = $PowerShellWindow[0].Position().Y });
            }
        }
        # remember
        [bool] $HavePositioning = ($Monitor -ge 0 -or $Monitor -eq -2) -or ($Left -or $Right -or $Top -or $Bottom -or $Centered -or (($X -is [int]) -and ($X -gt -999999)) -or (($Y -is [int]) -and ($Y -gt -999999))) -and -not $FullScreen;

        # init window position
        # '-X' parameter not supplied?
        if (($X -le -999999) -or ($X -isnot [int])) {

            $X = $Screen.WorkingArea.X;
        }
        else {

            if ($Monitor -ge 0) {

                $X = $Screen.WorkingArea.X + $X;
            }
        }

        # '-Y' parameter not supplied?
        if (($Y -le -999999) -or ($Y -isnot [int])) {

            $Y = $Screen.WorkingArea.Y;
        }
        else {

            if ($Monitor -ge 0) {

                $Y = $Screen.WorkingArea.Y + $Y;
            }
        }

        $State = @{
            existingWindow    = $false
            hadVisibleBrowser = $false
            Browser           = $null
            IsDefaultBrowser  = ((-not $All) -and ((-not $Chromium) -or ($DefaultBrowser.Name -like "*chrome*") -or ($DefaultBrowser.Name -like "*edge*")) -and ((-not $Chrome) -or ($DefaultBrowser.Name -like "*chrome*")) -and ((-not $Edge) -or ($DefaultBrowser.Name -like "*edge*")) -and ((-not $Firefox) -or ($DefaultBrowser.Name -like "*firefox*")))
            FirstProcess      = $null
            PositioningDone   = $false
            BrowserWindow     = $null
        };

        $UseStartProcess = (-not ($HavePositioning -or $FullScreen)) -and $State.IsDefaultBrowser

        if ($HavePositioning -or $FullScreen) {

            $WidthProvided = ($Width -ge 0) -and ($Width -is [int]);
            $heightProvided = ($Height -ge 0) -and ($Height -is [int]);

            # '-Width' parameter not supplied?
            if ($WidthProvided -eq $false) {

                $Width = $Screen.WorkingArea.Width;
            }

            # '-Height' parameter not supplied?
            if ($HeightProvided -eq $false) {

                $Height = $Screen.WorkingArea.Height;
            }

            # setup exact window position and size
            if ($Left -eq $true) {

                $X = $Screen.WorkingArea.X;

                if ($WidthProvided -eq $false) {

                    $Width = [Math]::Min($Screen.WorkingArea.Width / 2, $Width);
                }
                if ($HeightProvided -eq $false) {

                    $Height = [Math]::Min($Screen.WorkingArea.Height, $Height);
                }
                $Y = $Screen.WorkingArea.Y;

                return;
            }

            if ($Right -eq $true) {

                if ($WidthProvided -eq $false) {

                    $Width = [Math]::Min($Screen.WorkingArea.Width / 2, $Width);
                }

                $X = $Screen.WorkingArea.X + $Screen.WorkingArea.Width - $Width;
                $Y = $Screen.WorkingArea.Y + [Math]::Round(($screen.WorkingArea.Height - $Height) / 2, 0);
                if ($HeightProvided -eq $false) {

                    $Height = [Math]::Min($Screen.WorkingArea.Height, $Height);
                }
                $Y = $Screen.WorkingArea.Y;
                return;
            }

            if ($Top -eq $true) {

                $Y = $Screen.WorkingArea.Y;

                if ($HeightProvided -eq $false) {

                    $Height = [Math]::Min($Screen.WorkingArea.Height / 2, $Height);
                    $X = $Screen.WorkingArea.X;
                }
                $Width = $Screen.WorkingArea.Width;
                $X = $Screen.WorkingArea.X;
                return;
            }

            if ($Bottom -eq $true) {

                if ($HeightProvided -eq $false) {

                    $Height = [Math]::Min($Screen.WorkingArea.Height / 2, $Height);
                }

                $Width = $Screen.WorkingArea.Width;
                $Y = $Screen.WorkingArea.Y + $Screen.WorkingArea.Height - $Height;
                $X = $Screen.WorkingArea.X;
                return;
            }

            if ($Centered -eq $true) {

                if ($HeightProvided -eq $false) {

                    $Height = [Math]::Round([Math]::Min($Screen.WorkingArea.Height * 0.8, $Height), 0);
                }

                if ($WidthProvided -eq $false) {

                    $Width = [Math]::Round([Math]::Min($Screen.WorkingArea.Width * 0.8, $Width), 0);
                }

                $X = $Screen.WorkingArea.X + [Math]::Round(($screen.WorkingArea.Width - $Width) / 2, 0);
                $Y = $Screen.WorkingArea.Y + [Math]::Round(($screen.WorkingArea.Height - $Height) / 2, 0);

                return;
            }
        }
    }

    process {

        function enforceMinimumDelays($browser) {

            if ($HavePositioning -eq $false) {

                return;
            }

            $last = (Get-Variable -Scope Global -Name "_LastClose$($Browser.Name)" -ErrorAction SilentlyContinue);

            if (($null -ne $last) -and ($last.Value -is [DateTime])) {

                $now = [DateTime]::UtcNow;

                if ($now - $last.Value -lt [System.TimeSpan]::FromSeconds(1)) {

                    [System.Threading.Thread]::Sleep(200) | Out-Null
                }
            }
        }

        function constructArgumentList($browser, $CurrentUrl, $State) {

            # initialize an empty argument list for the webbrowser commandline
            $ArgumentList = @();

            ###############################################################################

            if ($browser.Name -like "*Firefox*") {

                # set default commandline parameters
                $ArgumentList = @();

                if (($Width -is [int]) -and ($Width -gt 0) -and ($Height -is [int]) -and ($Height -gt 0)) {

                    $ArgumentList = $ArgumentList + @("-width", $Width, "-height", $Height)
                }

                # '-RestoreFocus' parameter supplied'?
                if ($RestoreFocus -ne $true) {

                    # set commandline argument
                    $ArgumentList = $ArgumentList + @("-foreground")
                }

                # '-NoBrowserExtensions' parameter supplied?
                if ($NoBrowserExtensions -eq $true) {

                    $ArgumentList = $ArgumentList + @("-safe-mode");
                }

                # '-DisablePopupBlocker' parameter supplied?
                if ($DisablePopupBlocker -eq $true) {

                    $ArgumentList = $ArgumentList + @("-disable-popup-blocking");
                }

                # '-AcceptLang' parameter supplied?
                if ($null -ne $AcceptLang) {

                    $ArgumentList = $ArgumentList + @("--lang", $AcceptLang);
                }

                # '-Private' parameter supplied'?
                if ($Private -eq $true) {

                    # set commandline arguments
                    $ArgumentList = $ArgumentList + @("-private-window", $CurrentUrl)
                }
                else {

                    # '-ApplicationMode' parameter supplied?
                    if ($ApplicationMode -eq $true) {

                        Write-Warning "Firefox does not support -ApplicationMode at this time"

                        Approve-FirefoxDebugging

                        # set commandline argument
                        $ArgumentList = $ArgumentList + @("--ssb", $CurrentUrl)
                    }
                    else {

                        # '-NewWindow' parameter supplied'?
                        if ((-not $State.PositioningDone) -and ($NewWindow -eq $true)) {

                            # set commandline argument
                            $ArgumentList = $ArgumentList + @("--new-window", $CurrentUrl)
                        }
                        else {

                            # set commandline argument
                            $ArgumentList = $ArgumentList + @("-url", $CurrentUrl)
                        }
                    }
                }
            }
            else {
                ###############################################################################

                if ($browser.Name -like "*Edge*" -or $browser.Name -like "*Chrome*") {

                    # get the right debugging tcp port for this browser
                    $port = Get-ChromiumRemoteDebuggingPort -Chrome:$Chrome -Edge:$Edge

                    # set default commandline parameters
                    # https://peter.sh/experiments/chromium-command-line-switches/
                    # https://stackoverflow.com/questions/51563287/how-to-make-chrome-always-launch-with-remote-debugging-port-flag
                    $ArgumentList = $ArgumentList + @(
                        "--disable-infobars",
                        # "--enable-automation",
                        "--hide-crash-restore-bubble",
                        "--no-first-run",
                        "--disable-session-crashed-bubble",
                        "--disable-crash-reporter",
                        "--no-default-browser-check",
                        "--disable-restore-tabs",
                        "--remote-allow-origins=*",
                        "--remote-debugging-port=$port"
                    )

                    if (($Width -is [int]) -and ($Width -gt 0) -and ($Height -is [int]) -and ($Height -gt 0)) {

                        $ArgumentList = $ArgumentList + @("--window-size=$Width,$Height");
                    }

                    $ArgumentList = $ArgumentList + @("--window-position=$X,$Y");

                    # '-NoBrowserExtensions' parameter supplied?
                    if ($NoBrowserExtensions -eq $true) {

                        $ArgumentList = $ArgumentList + @("--disable-extensions");
                    }

                    # disable popup blocker
                    if ($DisablePopupBlocker -eq $true) {

                        $ArgumentList = $ArgumentList + @("--disable-popup-blocking");
                    }

                    # '-AcceptLang' parameter supplied?
                    if ($null -ne $AcceptLang) {

                        $ArgumentList = $ArgumentList + @("--accept-lang=$AcceptLang");
                    }

                    # '-Private' parameter supplied'?
                    if ($Private -eq $true) {

                        # force new window
                        $NewWindow = $true;

                        if ($browser.Name -like "*Edge*") {

                            # set commandline argument
                            $ArgumentList = $ArgumentList + @("-InPrivate")
                        }
                        else {
                            # set commandline argument
                            $ArgumentList = $ArgumentList + @("--incognito")
                        }
                    }

                    # '-NewWindow' parameter supplied'?
                    if ((-not $State.PositioningDone) -and ($NewWindow -eq $true)) {

                        # set commandline argument
                        $ArgumentList = $ArgumentList + @("--new-window") + @("--force-launch-browser");
                    }

                    # '-Fullscreen' parameter supplied'?
                    $ArgumentList = $ArgumentList + @("--start-maximized")
                    #hier
                    # if ($FullScreen -eq $true) {

                    #     # set commandline argument
                    #     $ArgumentList = $ArgumentList + @("--start-fullscreen")
                    # }
                    # else {
                    #     $ArgumentList = $ArgumentList + @("--start-maximized")
                    # }

                    # '-ApplicationMode' parameter supplied?
                    if ($ApplicationMode -eq $true) {

                        $ArgumentList = $ArgumentList + @("--app=$CurrentUrl");
                    }
                    else {
                        # Add Url to commandline arguments
                        $ArgumentList = $ArgumentList + @($CurrentUrl)
                    }
                }
                else {
                    ###############################################################################

                    # Default browser
                    if ($Private -eq $true) {

                        return;
                    }

                    # Add Url to commandline arguments
                    $ArgumentList = @($CurrentUrl);
                }
            }

            $ArgumentList
        }

        function findProcess($browser, $process, $State) {

            $State.existingWindow = $false;
            $window = @()
            do {

                try {
                    # did it only signal an already existing webbrowser instance, to create a new tab,
                    # and did it then exit?
                    # if (($null -eq $process) -or ($process.HasExited)) {

                    [System.Threading.Thread]::Sleep(100) | Out-Null;

                    # find the process
                    $processesNew = @(Get-Process ([IO.Path]::GetFileNameWithoutExtension($browser.Path)) -ErrorAction SilentlyContinue |
                        Where-Object -Property Path -EQ $browser.Path |
                        Where-Object -Property MainWindowHandle -NE 0 |
                        Sort-Object { $PSItem.StartTime } -Descending |
                        Select-Object -First 1)

                    # not found?
                    if (($processesNew.Length -eq 0) -or ($null -eq $processesNew[0])) {

                        Write-Verbose "No process found, retrying.."
                        $window = @();

                        [System.Threading.Thread]::Sleep(80) | Out-Null;
                    }
                    else {

                        Write-Verbose "Found new process"

                        # get window helper utility for the mainwindow of the process
                        $State.existingWindow = $State.hadVisibleBrowser;
                        $process = $processesNew[0];
                        $window = [GenXdev.Helpers.WindowObj]::GetMainWindow($process, 1, 80);
                        break;
                    }
                    # }
                    # else {

                    #     Write-Verbose "Process still running"
                    #     # get window helper utility for the mainwindow of the process
                    #     $window = [GenXdev.Helpers.WindowObj]::GetMainWindow($process, 1, 80);
                    #     break;
                    # }
                }
                catch {
                    Write-Verbose "Error: $($_.Exception.Message)"
                    $window = @()
                    [System.Threading.Thread]::Sleep(100) | Out-Null
                }
            } while (($i++ -lt 50) -and ($window.length -le 0));

            @{
                Process = $process
                Window  = $window
            }
        }

        function open($browser, $CurrentUrl, $State) {

            Write-Verbose "open()"

            $State.IsDefaultBrowser = $browser -eq $DefaultBrowser

            enforceMinimumDelays $browser
            ###############################################################################

            $StartBrowser = $true;
            $State.hadVisibleBrowser = $false;
            $process = $null;

            # find any existing  process
            $prcBefore = @(Get-Process ([IO.Path]::GetFileNameWithoutExtension($browser.Path)) -ErrorAction SilentlyContinue) |
            Where-Object -Property Path -EQ $browser.Path |
            Where-Object -Property MainWindowHandle -NE 0 |
            Sort-Object { $PSItem.StartTime } -Descending |
            Select-Object -First 1

            #found?
            if ($State.PositioningDone -or (($prcBefore.Length -ge 1) -and ($null -ne $prcBefore[0]))) {

                Write-Verbose "Found existing webbrowser window"
                $State.hadVisibleBrowser = $true;
            }

            # no url specified?
            if ((-not $NewWindow) -and (-not ($HavePositioning -or $FullScreen)) -and (-not $UrlSpecified)) {

                if ($State.hadVisibleBrowser) {

                    Write-Verbose "No url specified, found existing webbrowser window"
                    $StartBrowser = $false;
                    $process = if ($State.FirstProcess) { $State.FirstProcess } else { $prcBefore[0] }
                }
            }

            if ($StartBrowser) {

                if ($Force) {

                    try {
                        $a = Select-WebbrowserTab -Chrome:$Chrome -Edge:$Edge
                    }
                    catch {
                        $a = @()
                    }

                    if ($a.length -eq 0 -or ($a -is [string])) {

                        Write-Verbose "No browser with open debugger port found, closing all browser instances and starting a new one"
                        Get-Process -Name ([IO.Path]::GetFileNameWithoutExtension($Browser.Path)) -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue | Out-Null
                    }
                }

                $currentProcesses = @((Get-Process -Name ([IO.Path]::GetFileNameWithoutExtension($Browser.Path)) -ErrorAction SilentlyContinue))
                if ($currentProcesses.Count -eq 0) {

                    $NewWindow = $false;
                }

                # get the browser dependend argument list
                $ArgumentList = constructArgumentList $browser $CurrentUrl $State

                # log
                Write-Verbose "$($browser.Name) --> $($ArgumentList | ConvertTo-Json)"

                # start process
                $process = Start-Process -FilePath ($browser.Path) -ArgumentList $argumentList -PassThru

                # wait a little
                $process.WaitForExit(200) | Out-Null;
            }

            ###############################################################################

            if ($null -eq $process) {

                Write-Warning "Could not start browser $($browser.Name)"
                return;
            }

            ###############################################################################

            # nothing to do anymore? then don't waste time on positioning the window
            if ((-not $PassThru) -and ((-not ($HavePositioning -or ($FullScreen -and -not $state.PositioningDone))) -or $State.PositioningDone)) {

                Write-Verbose "No positioning required, done.."
                return;
            }

            ###############################################################################

            if ($PassThru) {

                if (($State.PositioningDone -or ((-not $FullScreen) -and (-not $HavePositioning))) -and ($null -ne $State.FirstProcess) -and (-not $State.FirstProcess.HasExited) -and ($State.FirstProcess.MainWindowHandle -ne 0)) {

                    Write-Verbose "Returning first process"
                    Write-Output $State.FirstProcess
                    return;
                }

                if (($null -ne $process) -and (-not $process.HasExited) -and ($process.MainWindowHandle -ne 0)) {

                    Write-Verbose "Returning process"
                    Write-Output $process

                    if (-not $HavePositioning) {

                        return;
                    }
                }
            }

            # allow the browser to start-up, and update process handle if needed
            enforceMinimumDelays $browser
            $browserFound = findProcess $browser $process $State
            $process = $browserFound.Process
            $window = $browserFound.Window

            if (($PassThru -eq $true) -and ($null -ne $process)) {

                Write-Verbose "Returning process after process lookup"
                Write-Output $process
            }

            if ((-not ($HavePositioning -or ($FullScreen -and -not $state.PositioningDone))) -or $State.PositioningDone) {

                Write-Verbose "No positioning required, done.."
                return;
            }

            ###############################################################################
            $State.PositioningDone = $true;
            $State.FirstProcess = $process;
            ###############################################################################

            # have a handle to the mainwindow of the browser?
            if ($window.Length -eq 1) {

                ###############################################################################
                $State.BrowserWindow = $window[0];
                ###############################################################################

                Write-Verbose "Restoring and positioning browser window"

                # if maximized, restore window style
                if (-not $FullScreen) {

                    $null = $window[0].Show() | Out-Null
                    $null = $window[0].Restore() | Out-Null;
                }

                # move it to it's place
                $null = $window[0].Move($X, $Y, $Width, $Height)  | Out-Null
            }

            Start-Sleep 2 | Out-Null
        }

        ###############################################################################
        $index = -1;
        try {
            # start processing the Urls that we need to open
            foreach ($CurrentUrl in $Url) {

                $index++
                Write-Verbose "Opening $CurrentUrl"

                if ($UseStartProcess -or (($index -gt 0) -and ($State.IsDefaultBrowser))) {

                    Write-Verbose "Start-Process"

                    # open default browser
                    $process = Start-Process $CurrentUrl -PassThru

                    # need to return a process and this is the first non-positioning webbrowser launch?
                    if ($PassThru -and $UseStartProcess -and ($index -eq 0)) {

                        $browserFound = findProcess $DefaultBrowser $process $State

                        $process = $browserFound.Process
                        $window = $browserFound.Window

                        Write-Verbose "Returning process after Start-Process"
                        Write-Output $process
                    }

                    continue;
                }

                # '-All' parameter was supplied?
                if ($All -eq $true) {

                    # open for all browsers
                    $Browsers | ForEach-Object { open $PSItem $CurrentUrl }

                    continue;
                }
                # '-Chrome' parameter supplied?
                elseif ($Chrome -eq $true) {

                    # enumerate all browsers
                    $Browsers | ForEach-Object {

                        # found chrome?
                        if ($PSItem.Name -like "*Chrome*") {

                            # open it
                            open $PSItem $CurrentUrl $State
                        }
                    }
                }
                # '-Edge' parameter supplied?
                elseif ($Edge -eq $true) {

                    # enumerate all browsers
                    $Browsers | ForEach-Object {

                        # found Edge?
                        if ($PSItem.Name -like "*Edge*") {

                            # open it
                            open $PSItem $CurrentUrl $State
                        }
                    }
                }                # '-Chromium' parameter was supplied
                elseif ($Chromium -eq $true) {

                    # default browser already chrome or edge?
                    if (($DefaultBrowser.Name -like "*Chrome*") -or ($DefaultBrowser.Name -like "*Edge*")) {

                        # open default browser
                        open $DefaultBrowser $CurrentUrl $State
                        continue;
                    }

                    # enumerate all browsers
                    $Browsers | Sort-Object { $PSItem.Name } -Descending | ForEach-Object {

                        # found edge or chrome?
                        if (($PSItem.Name -like "*Chrome*") -or ($PSItem.Name -like "*Edge*")) {

                            # open it
                            open $PSItem $CurrentUrl $State
                        }
                    }
                }

                # '-Firefox' parameter supplied?
                if ($Firefox -eq $true) {

                    # enumerate all browsers
                    $Browsers | ForEach-Object {

                        # found Firefox?
                        if ($PSItem.Name -like "*Firefox*") {

                            # open it
                            open $PSItem $CurrentUrl $State
                        }
                    }
                }

                # no specific browser requested?
                if (($Chromium -ne $true) -and ($Chrome -ne $true) -and ($Edge -ne $true) -and ($Firefox -ne $true)) {

                    # open default browser
                    open $DefaultBrowser $CurrentUrl $State
                }
            }
        }
        finally {

            # needs to be set fullscreen?
            if ($FullScreen -eq $true) {

                Write-Verbose "Setting fullscreen"

                if ($null -ne $State.BrowserWindow) {

                    Write-Verbose "Changing focus to browser window"

                    try { $State.BrowserWindow.Maximize() | Out-Null; $State.BrowserWindow.SetForeground() | Out-Null }
                    catch { }
                    $tt = 0;
                    $focusedWindowProcess = Get-CurrentFocusedProcess
                    while (($tt++ -lt 20) -and (
                        ($null -eq $focusedWindowProcess) -or
                        ($focusedWindowProcess.MainWindowHandle -ne $State.BrowserWindow.Handle))) {

                        Write-Verbose "have browser window, sleeping 500ms"
                        [System.Threading.Thread]::Sleep(500) | Out-Null

                        try { $State.BrowserWindow.Maximize() | Out-Null; $State.BrowserWindow.SetForeground() | Out-Null }
                        catch { }
                        Set-ForegroundWindow ($State.BrowserWindow.Handle) | Out-Null

                        $focusedWindowProcess = Get-CurrentFocusedProcess
                    }
                }
                else {
                    Write-Verbose "Setting fullscreen without having reference to browser window"
                    $tt = 0;
                    $focusedWindowProcess = Get-CurrentFocusedProcess
                    $powershellWindow = Get-PowershellMainWindow
                    while (($tt++ -lt 20) -and (
                        ($null -eq $focusedWindowProcess) -or ($null -eq $PowerShellWindow) -or
                        ($focusedWindowProcess.MainWindowHandle -ne $PowerShellWindow.Handle))) {
                        Write-Verbose "no browser window, sleeping 500ms"
                        [System.Threading.Thread]::Sleep(500) | Out-Null

                        $focusedWindowProcess = Get-CurrentFocusedProcess
                        $powershellWindow = Get-PowershellMainWindow
                    }
                }

                if ((Get-CurrentFocusedProcess).MainWindowHandle -ne (Get-PowershellMainWindow).Handle) {
                    try {

                        # send F11
                        $helper = New-Object -ComObject WScript.Shell;
                        $null = $helper.sendKeys("{F11}");
                        Write-Verbose "Sending F11"
                        [System.Threading.Thread]::Sleep(500) | Out-Null
                    }
                    catch {

                    }
                }
            }
        }
    }

    end {

        if ($RestoreFocus) {

            # restore it
            $PowerShellWindow = Get-PowershellMainWindow

            if ($null -ne $PowerShellWindow) {

                # wait a little
                [System.Threading.Thread]::Sleep(500) | Out-Null

                $null = $PowerShellWindow.Show() | Out-Null;
                $null = $PowerShellWindow.SetForeground() | Out-Null;

                Set-ForegroundWindow ($PowerShellWindow.Handle) | Out-Null;
            }
        }
    }
}
