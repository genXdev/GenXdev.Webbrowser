###############################################################################
<#
.SYNOPSIS
Returns the configured current webbrowser

.DESCRIPTION
Returns an object describing the configured current webbrowser for the current-user.

.EXAMPLE
PS C:\> & (Get-DefaultWebbrowser).Path https://www.github.com/

PS C:\> Get-DefaultWebbrowser | Format-List

.NOTES
Requires the Windows 10+ Operating System
#>
function Get-DefaultWebbrowser {

    [CmdletBinding()]

    param()

    if (!(Test-Path HKCU:\)) {

        New-PSDrive -Name HKCU -PSProvider Registry -Root HKEY_CURRENT_USER | Out-Null
    }

    if (!(Test-Path HKLM:\)) {

        New-PSDrive -Name HKLM -PSProvider Registry -Root HKEY_LOCAL_MACHINE | Out-Null
    }

    $UrlHandlerId = Get-ItemProperty HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice | Select-Object -ExpandProperty ProgId

    foreach ($item in (Get-ChildItem HKLM:\SOFTWARE\WOW6432Node\Clients\StartMenuInternet)) {

        $root = "HKLM:\SOFTWARE\WOW6432Node\Clients\StartMenuInternet\$($item.PSChildName)"

        if ((Test-Path "$root\shell\open\command") -and (Test-Path "$root\Capabilities\URLAssociations") -and ((Get-ItemProperty "$root\Capabilities\URLAssociations" | Select-Object -ExpandProperty https) -eq $UrlHandlerId)) {

            @{
                Name        = (Get-ItemProperty "$root\Capabilities" | Select-Object -ExpandProperty ApplicationName);
                Description = (Get-ItemProperty "$root\Capabilities" | Select-Object -ExpandProperty ApplicationDescription);
                Icon        = (Get-ItemProperty "$root\Capabilities" | Select-Object -ExpandProperty ApplicationIcon);
                Path        = (Get-ItemProperty "$root\shell\open\command" | Select-Object -ExpandProperty "(default)").Trim("`"");
            }
            return;
        }
    }
}
###############################################################################

<#
.SYNOPSIS
Returns a collection of installed modern webbrowsers

.DESCRIPTION
Returns a collection of objects each describing a installed modern webbrowser

.EXAMPLE
PS C:\> Get-Webbrowser | Foreach-Object { & $PSItem.Path https://www.github.com/ }

PS C:\> Get-Webbrowser | select Name, Description | Format-Table

PS C:\> Get-Webbrowser | select Name, Path | Format-Table

.NOTES
Requires the Windows 10+ Operating System
#>
function Get-Webbrowser {

    [CmdletBinding()]

    param()

    if (!(Test-Path HKCU:\)) {

        New-PSDrive -Name HKCU -PSProvider Registry -Root HKEY_CURRENT_USER | Out-Null
    }

    if (!(Test-Path HKLM:\)) {

        New-PSDrive -Name HKLM -PSProvider Registry -Root HKEY_LOCAL_MACHINE | Out-Null
    }

    $UrlHandlerId = Get-ItemProperty HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice | Select-Object -ExpandProperty ProgId

    foreach ($item in (Get-ChildItem HKLM:\SOFTWARE\WOW6432Node\Clients\StartMenuInternet)) {

        $root = "HKLM:\SOFTWARE\WOW6432Node\Clients\StartMenuInternet\$($item.PSChildName)"
        if ((Test-Path "$root\shell\open\command") -and (Test-Path "$root\Capabilities")) {

            @{
                Name             = (Get-ItemProperty "$root\Capabilities" | Select-Object -ExpandProperty ApplicationName);
                Description      = (Get-ItemProperty "$root\Capabilities" | Select-Object -ExpandProperty ApplicationDescription);
                Icon             = (Get-ItemProperty "$root\Capabilities" | Select-Object -ExpandProperty ApplicationIcon);
                Path             = (Get-ItemProperty "$root\shell\open\command" | Select-Object -ExpandProperty "(default)").Trim("`"");
                IsDefaultBrowser = ((Get-ItemProperty "$root\Capabilities\URLAssociations" | Select-Object -ExpandProperty https) -eq $UrlHandlerId);
            }
        }
    }
}

###############################################################################

<#
.SYNOPSIS
Opens one or more webbrowser instances

.DESCRIPTION
Opens one or more webbrowsers in a configurable manner, using commandline switches

.PARAMETER Url
The url to open

.PARAMETER Private
Opens in incognito-/in-private browsing- mode

.PARAMETER Edge
Open in Microsoft Edge --> -e

.PARAMETER Chrome
Open in Google Chrome --> -ch

.PARAMETER Chromium
Open in Microsoft Edge or Google Chrome, depending on what the default browser is --> -c

.PARAMETER Firefox
Open in Firefox --> -ff

.PARAMETER All
Open in all registered modern browsers

.PARAMETER Monitor
The monitor to use, 0 = default, -1 is discard, -2 = Configured secondary monitor, defaults to `Global:DefaultSecondaryMonitor or 2 if not found --> -m, -mon

.PARAMETER FullScreen
Open in fullscreen mode --> -fs

.PARAMETER Width
The initial width of the webbrowser window

.PARAMETER Height
The initial height of the webbrowser window

.PARAMETER X
The initial X position of the webbrowser window

.PARAMETER Y
The initial Y position of the webbrowser window

.PARAMETER Left
Place browser window on the left side of the screen

.PARAMETER Right
Place browser window on the right side of the screen

.PARAMETER Top
Place browser window on the top side of the screen

.PARAMETER Bottom
Place browser window on the bottom side of the screen

.PARAMETER Centered
Place browser window in the center of the screen

.PARAMETER ApplicationMode
Hide the browser controls --> -a, -app, -appmode

.PARAMETER NoBrowserExtensions
Prevent loading of browser extensions --> -de, -ne

.PARAMETER AcceptLang
Set the browser accept-lang http header

.PARAMETER RestoreFocus
Restore PowerShell window focus --> -bg

.PARAMETER NewWindow
Don't re-use existing browser window, instead, create a new one -> nw

.PARAMETER PassThru
Returns a [System.Diagnostics.Process] object of the browserprocess

.PARAMETER Force
Enforced that the debugging port is enabled, even if that means stopping all already opened browser processes

.EXAMPLE

url from parameter
PS C:\> Open-Webbrowser -Chrome -Left -Top -Url "https://genxdev.net/"

urls from pipeline
PS C:\> @("https://genxdev.net/", "https://github.com/genXdev/") | Open-Webbrowser

re-position already open window to primary monitor on right side
PS C:\> Open-Webbrowser -Monitor 0 -right

re-position already open window to secondary monitor, full screen
PS C:\> Open-Webbrowser -Monitor 0

re-position already open window to secondary monitor, left top
PS C:\> Open-Webbrowser -Monitor 0 -Left -Top
PS C:\> wb -m 0 -left -top

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
    [Alias("wb")]

    param(
        ###############################################################################

        [Alias("Value", "Uri", "FullName", "Website", "WebsiteUrl")]
        [parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "The url to open",
            ValueFromPipeline,
            ValueFromPipelineByPropertyName = $false,
            ValueFromRemainingArguments = $false
        )]
        [string[]] $Url,
        ###############################################################################

        [Alias("incognito", "inprivate")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Opens in incognito-/in-private browsing- mode"
        )]
        [switch] $Private,
        ###############################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Enforced that the debugging port is enabled, even if that means stopping all already opened browser processes"
        )]
        [switch] $Force,
        ###############################################################################

        [Alias("e")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Opens in Microsoft Edge"
        )]
        [switch] $Edge,
        ###############################################################################

        [Alias("ch")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Opens in Google Chrome"
        )]
        [switch] $Chrome,
        ###############################################################################

        [Alias("c")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Opens in Microsoft Edge or Google Chrome, depending on what the default browser is"
        )]
        [switch] $Chromium,
        ###############################################################################

        [Alias("ff")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Opens in Firefox"
        )]
        [switch] $Firefox,
        ###############################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = "Opens in all registered modern browsers"
        )]
        [switch] $All,
        ###############################################################################

        [Alias("m", "mon")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "The monitor to use, 0 = default, -1 is discard, -2 = Configured secondary monitor, defaults to `Global:DefaultSecondaryMonitor or 2 if not found"
        )]
        [int] $Monitor = -2,
        ###############################################################################

        [Alias("fs", "f")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Opens in fullscreen mode"
        )]
        [switch] $FullScreen,
        ###############################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = "The initial width of the webbrowser window"
        )]
        [int] $Width = -1,
        ###############################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = "The initial height of the webbrowser window"
        )]
        [int] $Height = -1,
        ###############################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = "The initial X position of the webbrowser window"
        )]
        [int] $X = -999999,
        ###############################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = "The initial Y position of the webbrowser window"
        )]
        [int] $Y = -999999,
        ###############################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the left side of the screen"
        )]
        [switch] $Left,
        ###############################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the right side of the screen"
        )]
        [switch] $Right,
        ###############################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the top side of the screen"
        )]
        [switch] $Top,
        ###############################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the bottom side of the screen"
        )]
        [switch] $Bottom,
        ###############################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window in the center of the screen"
        )]
        [switch] $Centered,
        ###############################################################################

        [Alias("a", "app", "appmode")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Hide the browser controls"
        )]
        [switch] $ApplicationMode,
        ###############################################################################

        [Alias("de", "ne", "NoExtensions")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Prevent loading of browser extensions"
        )]
        [switch] $NoBrowserExtensions,

        ###############################################################################
        [Alias("lang", "locale")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Set the browser accept-lang http header"
        )]
        [string] $AcceptLang = $null,
        ###############################################################################

        [Alias("bg")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Restore PowerShell window focus"
        )]
        [switch] $RestoreFocus,
        ###############################################################################

        [Alias("nw", "new")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Don't re-use existing browser window, instead, create a new one"
        )]
        [switch] $NewWindow,
        ###############################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = "Returns a [System.Diagnostics.Process] object of the browserprocess"
        )]
        [switch] $PassThru
    )

    Begin {

        $window = @();
        $AllScreens = @([WpfScreenHelper.Screen]::AllScreens | ForEach-Object { $PSItem });

        Write-Verbose "Open-Webbrowser monitor = $Monitor, Urls=$($Url | ConvertTo-Json)"

        [bool] $UrlSpecified = $true;

        # what if no url is specified?
        if (($null -eq $Url) -or ($Url.Length -lt 1)) {

            $UrlSpecified = $false;

            # show the help page from github
            $Url = @("https://github.com/genXdev/GenXdev.Webbrowser/blob/main/README.md#Open-Webbrowser")
        }
        else {

            $Url = $($Url | ForEach-Object {

                    $NewUrl = $PSItem.Trim(" `"'".ToCharArray());
                    $filePath = $NewUrl
                    try {
                        $filePath = (Expand-Path $NewUrl);
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
            if ($heightProvided -eq $false) {

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
                    if ($browser.Name -like "*Edge*") {

                        $port = Get-EdgeRemoteDebuggingPort
                    }
                    else {
                        $port = Get-ChromeRemoteDebuggingPort
                    }

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

                    $a = Select-WebbrowserTab -Chrome:$Chrome -Edge:$Edge

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
            [int] $i = 0;
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

                    $window[0].Show() | Out-Null
                    $window[0].Restore() | Out-Null;
                }

                # move it to it's place
                $window[0].Move($X, $Y, $Width, $Height)  | Out-Null
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
                        $helper.sendKeys("{F11}");
                        Write-Verbose "Sending F11"
                        [System.Threading.Thread]::Sleep(500) | Out-Null
                    }
                    catch {

                    }
                }
            }

            if ($RestoreFocus) {

                # restore it
                $PowerShellWindow = Get-PowershellMainWindow

                if ($null -ne $PowerShellWindow) {

                    # wait a little
                    [System.Threading.Thread]::Sleep(500) | Out-Null

                    $PowerShellWindow.Show() | Out-Null;
                    $PowerShellWindow.SetForeground() | Out-Null;

                    Set-ForegroundWindow ($PowerShellWindow.Handle) | Out-Null;
                }
            }
        }
    }
}

###############################################################################

<#
.SYNOPSIS
Closes one or more webbrowser instances

.DESCRIPTION
Closes one or more webbrowser instances in a selective manner, using commandline switches

.PARAMETER Edge
Closes Microsoft Edge --> -e

.PARAMETER Chrome
Closes Google Chrome --> -ch

.PARAMETER Chromium
Closes Microsoft Edge or Google Chrome, depending on what the default browser is --> -c

.PARAMETER Firefox
Closes Firefox --> -ff

.PARAMETER All
Closes all registered modern browsers -> -a

.PARAMETER IncludeBackgroundProcesses
Closes all instances of the webbrowser, including background tasks and services

.EXAMPLE
PS C:\> Close-Webbrowser -Chrome

PS C:\> Close-Webbrowser -Chrome -FireFox

PS C:\> Close-Webbrowser -All

PS C:\> wbc -a

.NOTES
Requires the Windows 10+ Operating System
#>
function Close-Webbrowser {

    [CmdletBinding()]
    [Alias("wbc")]

    param(
        ###############################################################################

        [Alias("e")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Closes Microsoft Edge"
        )]
        [switch] $Edge,
        ###############################################################################

        [Alias("ch")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Closes Google Chrome"
        )]
        [switch] $Chrome,
        ###############################################################################

        [Alias("c")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Closes Microsoft Edge or Google Chrome, depending on what the default browser is"
        )]
        [switch] $Chromium,
        ###############################################################################

        [Alias("ff")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Closes Firefox"
        )]
        [switch] $Firefox,
        ###############################################################################

        [Alias("a")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Closes all registered modern browsers"
        )]
        [switch] $All,
        ###############################################################################

        [Alias("bg", "Force")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Closes all instances of the webbrowser, including background tasks and services"
        )]
        [switch] $IncludeBackgroundProcesses
    )

    # get a list of all available/installed modern webbrowsers
    $Browsers = Get-Webbrowser

    # get the configured default webbrowser
    $DefaultBrowser = Get-DefaultWebbrowser

    function close($browser) {

        if ($null -eq $browser) { return; }

        # find all running processes of this browser
        Get-Process -Name ([IO.Path]::GetFileNameWithoutExtension($browser.Path)) -ErrorAction SilentlyContinue | ForEach-Object -ErrorAction SilentlyContinue {

            # reference next process
            $P = $PSItem;

            # '-IncludeBackgroundProcesses' parameter supplied?
            if ($IncludeBackgroundProcesses -ne $true) {

                # this browser process has no main window?
                if ($PSItem.MainWindowHandle -eq 0) {

                    # continue to next process
                    return;
                }

                # get handle to main window
                [GenXdev.Helpers.WindowObj]::GetMainWindow($PSItem) | ForEach-Object -ErrorAction SilentlyContinue {

                    $startTime = [DateTime]::UtcNow;
                    # send a WM_Close message
                    $PSItem.Close() | Out-Null;

                    do {

                        # wait a little
                        [System.Threading.Thread]::Sleep(20);

                    } while (!$p.HasExited -and [datetime]::UtcNow - $startTime -lt [System.TimeSpan]::FromSeconds(4))

                    if ($P.HasExited) {

                        Set-Variable -Scope Global -Name "_LastClose$($Browser.Name)" -Value ([DateTime]::UtcNow.AddSeconds(-1));
                        return;
                    }
                }
            }

            try {
                $PSItem.Kill();
                Set-Variable -Scope Global -Name "_LastClose$($Browser.Name)" -Value ([DateTime]::UtcNow);
            }
            catch {
                [GenXdev.Helpers.WindowObj]::GetMainWindow($PSItem) | ForEach-Object -ErrorAction SilentlyContinue {

                    $PSItem.Close();
                }
            }
        }
    }

    # '-All' parameter was supplied?
    if ($All -eq $true) {

        # enumerate all browsers
        $Browsers | ForEach-Object {

            close($PSItem)
        }

        return;
    }

    # '-Chromium' parameter was supplied
    if ($Chromium -eq $true) {

        # default browser already chrome or edge?
        if (($DefaultBrowser.Name -like "*Chrome*") -or ($DefaultBrowser.Name -like "*Edge*")) {

            close($DefaultBrowser);
            return;
        }

        # enumerate all browsers
        $Browsers | Sort-Object { $PSItem.Name } -Descending | ForEach-Object {

            if (($PSItem.Name -like "*Chrome*") -or ($PSItem.Name -like "*Edge*")) {

                close($PSItem);
                return;
            }
        }
    }

    # '-Chrome' parameter supplied?
    if ($Chrome -eq $true) {

        # enumerate all browsers
        $Browsers | ForEach-Object {

            # found Chrome?
            if ($PSItem.Name -like "*Chrome*") {

                close($PSItem);
                return;
            }
        }
    }

    # '-Edge' parameter supplied?
    if ($Edge -eq $true) {

        # enumerate all browsers
        $Browsers | ForEach-Object {

            # found Edge?
            if ($PSItem.Name -like "*Edge*") {

                close($PSItem);
                return;
            }
        }
    }

    # '-Firefox' parameter supplied?
    if ($Firefox -eq $true) {

        # enumerate all browsers
        $Browsers | ForEach-Object {

            # found Firefox?
            if ($PSItem.Name -like "*Firefox*") {

                close($PSItem);
                return;
            }
        }
    }

    # no specific browser requested?
    if (($Chromium -ne $true) -and ($Chrome -ne $true) -and ($Edge -ne $true) -and ($Firefox -ne $true)) {

        # open default browser
        close($DefaultBrowser);
    }
}
###############################################################################

<#
.SYNOPSIS
Selects a webbrowser tab

.DESCRIPTION
Selects a webbrowser tab for use by the Cmdlets 'Invoke-WebbrowserEvaluation -> et, eval', 'Close-WebbrowserTab -> ct' and others

.PARAMETER id
When '-Id' is not supplied, a list of available webbrowser tabs is shown, where the right value can be found

.PARAMETER Name
Selects the first entry that contains given name in its url

.PARAMETER Edge
Force to use 'Microsoft Edge' webbrowser for selection

.PARAMETER Chrome
Force to use 'Google Chrome' webbrowser for selection

.PARAMETER ByReference
Select tab using reference obtained with Get-ChromiumSessionReference

.EXAMPLE
PS C:\> Select-WebbrowserTab
PS C:\> Select-WebbrowserTab 3
PS C:\> Select-WebbrowserTab -Chrome 14
PS C:\> st -ch 14

.NOTES
Requires the Windows 10+ Operating System
#>
function Select-WebbrowserTab {

    [CmdletBinding(
        DefaultParameterSetName = "normal"
    )]

    [Alias("st", "Select-BrowserTab")]

    param (
        ###############################################################################

        [parameter(Mandatory = $false, Position = 0,
            HelpMessage = "When '-Id' is not supplied, a list of available webbrowser tabs is shown, where the right value can be found")]

        [ValidateRange(0, [int]::MaxValue)]
        [int] $id = -1,
        ###############################################################################

        [parameter(Mandatory, ParameterSetName = "byName", Position = 0,
            HelpMessage = 'Selects the first entry that contains given name in its url')]
        [string] $Name = $null,
        ###############################################################################

        [Alias("e")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Select in Microsoft Edge"
        )]
        [switch] $Edge,
        ###############################################################################

        [Alias("ch")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Select in Google Chrome"
        )]
        [switch] $Chrome,
        ###############################################################################

        [Alias("r")]
        [parameter(
            ParameterSetName = "byreference",
            Mandatory,
            HelpMessage = "Select tab using reference obtained with Get-ChromiumSessionReference"
        )]
        [HashTable] $ByReference = $null,
        ###############################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = "Forces a restart of the webbrowser if needed"
        )]
        [switch] $Force
    )

    if ($null -ne $ByReference) {

        $Port = $ByReference.Port;
    }
    else {

        if ($Global:Data -isnot [HashTable]) {

            $globalData = @{}
            Set-Variable -Name "Data" -Value $globalData -Scope Global
        }
        else {

            $globalData = $Global:Data;
        }

        # init
        if ($Edge -eq $true) {

            $port = Get-EdgeRemoteDebuggingPort

            # if (!(Test-Connection -TcpPort $port 127.0.0.1 -TimeoutSeconds 1)) {

            #     Open-Webbrowser -Edge -FullScreen

            #     Start-Sleep 2
            # }
        }
        else {
            if ($Chrome -eq $true) {

                $port = Get-ChromeRemoteDebuggingPort

                # if (!(Test-Connection -TcpPort $port 127.0.0.1 -TimeoutSeconds 1)) {

                #     Open-Webbrowser -Chrome -FullScreen

                #     Start-Sleep 2
                # }
            }
            else {

                $port = Get-ChromiumRemoteDebuggingPort

                # if (!(Test-Connection -TcpPort $port 127.0.0.1 -TimeoutSeconds 1)) {

                #     Open-Webbrowser -Chromium -FullScreen

                #     Start-Sleep 2
                # }
            }
        }
    }
    function showList() {
        $i = 0;
        $Global:chromeSessions | ForEach-Object -Process {

            if ([String]::IsNullOrWhiteSpace($PSItem.url) -eq $false) {
                $b = " ";
                if ($PSItem.webSocketDebuggerUrl -eq $Global:chromeSession.webSocketDebuggerUrl) {

                    $b = "*";
                }

                $Url = $PSItem.url;

                if ($PSItem.url.startsWith("chrome-extension:") -or $PSItem.url.contains("/offline/")) {

                    $Url = "chrome-extension: ($($PSItem.title))";
                }

                "{`"id`":$i,`"A`":`"$b`",`"url`":$([GenXdev.Helpers.Serialization]::ToJson($Url))}" | ConvertFrom-Json
                $i = $i + 1;
            }
        }
    }

    if ($Global:chrome -isnot [GenXdev.Helpers.Chromium] -or $Global:chrome.Port -ne $port) {

        Write-Verbose "Creating new chromium automation object"
        $c = New-Object "GenXdev.Helpers.Chromium" @("http://localhost:$port")
        Set-Variable -Name chrome -Value $c -Scope Global
    }

    Set-Variable -Name CurrentChromiumDebugPort -Value $Port -Scope Global

    if (($null -eq $ByReference -and $id -lt 0) -or ![string]::IsNullOrWhiteSpace($name)) {

        if ([string]::IsNullOrWhiteSpace($name)) {

            Write-Verbose "No ID parameter specified"
        }
        try {
            $s = $Global:chrome.GetAvailableSessions();
        }
        Catch {

            if ($Force -and ($null -eq $ByReference)) {

                Close-Webbrowser -Chrome:$Chrome -Edge:$Edge -Force -Chromium

                if ([string]::IsNullOrWhiteSpace($Name)) {

                    Open-Webbrowser -Chrome:$Chrome -Edge:$Edge -Force -Chromium
                    return (Select-WebbrowserTab @PSBoundParameters)
                }
                else {

                    Open-Webbrowser -Chrome:$Chrome -Edge:$Edge -Force -Url $Name -Chromium
                    return (Select-WebbrowserTab @PSBoundParameters)
                }
            }
            else {

                if ($Global:Host.Name.Contains("Visual Studio")) {

                    "Webbrowser has not been opened yet, press F5 to start debugging first.."
                }
                else {
                    "Webbrowser has not been opened yet, use Open-Webbrowser --> wb to start a browser with debugging enabled.."
                }

                Set-Variable -Name chromeSessions -Value @() -Scope Global
                Set-Variable -Name chrome -Value $null -Scope Global

                return;
            }
        }

        $list = New-Object 'System.Collections.Generic.List[GenXdev.Helpers.RemoteSessionsResponse]'
        $s | ForEach-Object {

            if (
            (![string]::IsNullOrWhiteSpace($name) -and ($PSItem.url -notlike "$name")) -or
            ([string]::IsNullOrWhiteSpace($name) -and (
                    $PSItem.url.startsWith("chrome-extension:") -or
                    $PSItem.url.startsWith("devtools") -or
                    $PSItem.url.contains("/offline/") -or
                    $PSItem.url.startsWith("https://cdn.") -or
                    $PSItem.url.contains("edge:")))) {

                return;
            }

            $list.Add($PSItem)
        };
        $s = $list;

        Set-Variable -Name chromeSessions -Value $s -Scope Global
        Write-Verbose "Sessions set, length= $($Global:chromeSessions.count)"

        [int] $id = 0;
        while (
                ($id -lt ($s.Count - 1)) -and (
                (![string]::IsNullOrWhiteSpace($name) -and ($s[$id].url -notlike "$name")) -or
                ([string]::IsNullOrWhiteSpace($name) -and (
                    $s[$id].url.startsWith("chrome-extension:") -or
                    $s[$id].url.startsWith("devtools") -or
                    $s[$id].url.contains("/offline/") -or
                    $s[$id].url.startsWith("https://cdn.") -or
                    $s[$id].url.contains("edge:"))))) {

            Write-Verbose "skipping $($s[$id].url)"

            $id = $id + 1;
        }

        $id = [Math]::Min($id, $s.Count - 1);
        if ($id -lt $s.Count) {

            $Global:chrome.SetActiveSession($s[$id].webSocketDebuggerUrl);
            Set-Variable -Name chromeSession -Value $s[$id] -Scope Global
            Write-Verbose "Session set: $($Global:chromeSession)"
        }
    }
    else {

        if ($null -eq $ByReference) {

            $s = $Global:chromeSessions;

            "$($id)" | Write-Verbose

            if ($id -ge $s.Count) {

                $s = $Global:chrome.GetAvailableSessions();
                Set-Variable -Name chromeSessions -Value $s -Scope Global
                Write-Verbose "Sessions set, length= $($Global:chromeSessions.count)"

                showList

                throw "Session expired, select new session with cmdlet: Select-WebbrowserTab --> st"
            }

            $Global:chrome.SetActiveSession($s[$id].webSocketDebuggerUrl);
            Set-Variable -Name chromeSession -Value $s[$id] -Scope Global

            try {
                $s = $Global:chrome.GetAvailableSessions();
            }
            catch {
                throw "Session expired, select new session with cmdlet: Select-WebbrowserTab --> st"
            }
            Set-Variable -Name chromeSessions -Value $s -Scope Global
            Write-Verbose "Sessions set, length= $($Global:chromeSessions.count)"

            $debugUri = $Global:chromeSession.webSocketDebuggerUrl;
        }
        else {

            try {
                $s = $Global:chrome.GetAvailableSessions();
            }
            catch {
                throw "Session expired, select new session with cmdlet: Select-WebbrowserTab --> st"
            }

            $debugUri = $ByReference.debugUri;
        }

        $found = $false;

        $s | ForEach-Object -Process {
            if ($PSItem.webSocketDebuggerUrl -eq $debugUri) {
                $found = $true;

                $Global:chrome.SetActiveSession($PSItem.webSocketDebuggerUrl);
                Set-Variable -Name chromeSession -Value $PSItem -Scope Global
            }
        }

        if ($found -eq $false) {

            if ($null -eq $ByReference) {

                showList
            }

            throw "Session expired, select new session with cmdlet: Select-WebbrowserTab --> st"
        }
    }

    if ($null -eq $ByReference) {

        showList
    }
}
###############################################################################

<#
.SYNOPSIS
Runs one or more scripts inside a selected webbrowser tab.

.DESCRIPTION
Runs one or more scripts inside a selected webbrowser tab.
You can access 'data' object from within javascript, to synchronize data between PowerShell and the Webbrowser

.Parameter Scripts
A string containing javascript, a url or a file reference to a javascript file

.Parameter Inspect
Will cause the developer tools of the webbrowser to break, before executing the scripts, allowing you to debug it

.Parameter AsJob
Will execute the evaluation as a new background job.

.EXAMPLE
PS C:\>

Invoke-WebbrowserEvaluation "document.title = 'hello world'"
.EXAMPLE
PS C:\>

# Synchronizing data
Select-WebbrowserTab -Force;
$Global:Data = @{ files= (Get-ChildItem *.* -file | % FullName)};

[int] $number = Invoke-WebbrowserEvaluation "

    document.body.innerHTML = JSON.stringify(data.files);
    data.title = document.title;
    return 123;
";

Write-Host "
    Document title : $($Global:Data.title)
    return value   : $Number
";
.EXAMPLE
PS C:\>

# Support for promises
Select-WebbrowserTab -Force;
Invoke-WebbrowserEvaluation "
    let myList = [];
    return new Promise((resolve) => {
        let i = 0;
        let a = setInterval(() => {
            myList.push(++i);
            if (i == 10) {
                clearInterval(a);
                resolve(myList);
            }
        }, 1000);
    });
"
.EXAMPLE
PS C:\>

# Support for promises and more

# this function returns all rows of all tables/datastores of all databases of indexedDb in the selected tab
# beware, not all websites use indexedDb, it could return an empty set

Select-WebbrowserTab -Force;
Set-WebbrowserTabLocation "https://www.youtube.com/"
Start-Sleep 3
$AllIndexedDbData = Invoke-WebbrowserEvaluation "

    // enumerate all indexedDB databases
    for (let db of await indexedDB.databases()) {

        // request to open database
        let openRequest = await indexedDB.open(db.name);

        // wait for eventhandlers to be called
        await new Promise((resolve,reject) => {
            openRequest.onsuccess = resolve;
            openRequest.onerror = reject
        });

        // obtain reference
        let openedDb = openRequest.result;

        // initialize result
        let result = { DatabaseName: db.name, Version: db.version, Stores: [] }

        // itterate object store names
        for (let i = 0; i < openedDb.objectStoreNames.length; i++) {

            // reference
            let storeName = openedDb.objectStoreNames[i];

            // start readonly transaction
            let tr = openedDb.transaction(storeName);

            // get objectstore handle
            let store = tr.objectStore(storeName);

            // request all data
            let getRequest = store.getAll();

            // await result
            await new Promise((resolve,reject) => {
                getRequest.onsuccess = resolve;
                getRequest.onerror = reject;
            });

            // add result
            result.Stores.push({ StoreName: storeName, Data: getRequest.result});
        }

        // stream this database contents to the PowerShell pipeline, and continue
        yield result;
    }
";

$AllIndexedDbData | Out-Host

.EXAMPLE
PS C:\>

# Support for yielded pipeline results
Select-WebbrowserTab -Force;
Invoke-WebbrowserEvaluation "

    for (let i = 0; i < 10; i++) {

        await (new Promise((resolve) => setTimeout(resolve, 1000)));

        yield i;
    }
";
.EXAMPLE
PS C:\> Get-ChildItem *.js | Invoke-WebbrowserEvaluation -Edge
.EXAMPLE
PS C:\> ls *.js | et -e
.NOTES
Requires the Windows 10+ Operating System
#>
function Invoke-WebbrowserEvaluation {

    [Alias("Eval", "et")]

    param(
        ###############################################################################

        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = "A string containing javascript, a url or a file reference to a javascript file",
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)
        ]
        [Alias('FullName')]
        [object[]] $Scripts,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Will cause the developer tools of the webbrowser to break, before executing the scripts, allowing you to debug it",
            ValueFromPipeline = $false)
        ]
        [switch] $Inspect,
        ###############################################################################

        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $false
        )]
        [switch] $AsJob,
        ###############################################################################

        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $false
        )]
        [switch] $NoAutoSelectTab,
        ###############################################################################

        [Alias("e")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Select in Microsoft Edge"
        )]
        [switch] $Edge,
        ###############################################################################

        [Alias("ch")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Select in Google Chrome"
        )]
        [switch] $Chrome
        ###############################################################################

    )

    Begin {

        $reference = $null;
        try {
            $reference = Get-ChromiumSessionReference
        }
        catch {
            if ($NoAutoSelectTab -eq $true) {

                throw $PSItem.Exception
            }

            Select-WebbrowserTab -Chrome:$Chrome -Edge:$Edge | Out-Null
            $reference = Get-ChromiumSessionReference
            $startTime = [DateTime]::UtcNow
        }
    }

    Process {

        Write-Verbose "Processing.."

        # enumerate provided scripts
        foreach ($js in $Scripts) {

            $scriptBlock = {

                param($js, $reference, $AsJob, $Inspect, $Chrome, $Edge)

                try {
                    Set-Variable -Name "Data" -Value $reference.data -Scope Global

                    Select-WebbrowserTab -ByReference $reference -Chrome:$Chrome -Edge:$Edge

                    # is it a file reference?
                    if (($js -is [IO.FileInfo]) -or (($js -is [System.String]) -and [IO.File]::Exists($js))) {

                        # comming from Get-ChildItem command?
                        if ($js -is [IO.FileInfo]) {

                            # make it a string
                            $js = $js.FullName;
                        }

                        # it's a string with a path, load the content
                        $js = [IO.File]::ReadAllText($js, [System.Text.Encoding]::UTF8)
                    }
                    else {

                        # make it a string, if it isn't yet
                        if ($js -isnot [System.String] -or [string]::IsNullOrWhiteSpace($js)) {

                            $js = "$js";
                        }

                        if ([string]::IsNullOrWhiteSpace($js) -eq $false) {

                            [Uri] $uri = $null;
                            $isUri = (

                                [Uri]::TryCreate("$js", "absolute", [ref] $uri) -or (
                                    $js.ToLowerInvariant().StartsWith("www.") -and
                                    [Uri]::TryCreate("http://$js", "absolute", [ref] $uri)
                                )
                            ) -and $uri.IsWellFormedOriginalString() -and $uri.Scheme -like "http*";

                            if ($IsUri) {
                                Write-Verbose "is Uri"
                                $httpResult = Invoke-WebRequest -Uri $Js

                                if ($httpResult.StatusCode -eq 200) {

                                    $type = "text/javascript";

                                    if ($httpResult.Content -Match "[`r`n\s`t;,]import ") {

                                        $type = "module";
                                    }
                                    $ScriptHash = [GenXdev.Helpers.Hash]::FormatBytesAsHexString(
                                        [GenXdev.Helpers.Hash]::GetSha256BytesOfString($httpResult.Content));
                                    $js = "
                                    let scripts = document.getElementsByTagName('script');
                                    for (let i = 0; i < scripts.length; i++) {

                                        let script = scripts[i];
                                        if (!!script && typeof script.getAttribute === 'function' && script.getAttribute('data-hash') === '$scriptHash') {
                                            return;
                                        }
                                    }
                                    let scriptTag = document.createElement('script');
                                    let scriptLoaded = false;
                                    let loaded = () => {  };

                                    scriptTag.innerHTML = $(($httpResult.Content | ConvertTo-Json));
                                    scriptTag.setAttribute('type', '$type');
                                    scriptTag.setAttribute('data-hash', '$ScriptHash');
                                    let head = document.getElementsByTagName('head')[0];
                                    if (!head) {
                                        head = document.createElement('head');
                                        document.appendChild(head);
                                    }
                                    head.appendChild(scriptTag);
                                ";
                                }
                                else {

                                    throw "Downloading script '$js' resulted in http statuscode $($HttpResult.StatusCode) - $($HttpResult.StatusDescription)"
                                }
                            }
                        }
                    }

                    # '-Inspect' parameter provided?
                    if ($Inspect -eq $true) {

                        # invoke a debug break-point
                        $js = "debugger;`r`n$js"
                    }

                    Write-Verbose "Processing: `r`n$($js.Trim())"

                    # convert data object to json, and then again to make it a json string
                    $json = ($reference.data | ConvertTo-Json -Compress -Depth 100 | ConvertTo-Json -Compress -Depth 100);

                    # init result
                    $result = $null;
                    $ScriptHash = [GenXdev.Helpers.Hash]::FormatBytesAsHexString(
                        [GenXdev.Helpers.Hash]::GetSha256BytesOfString($js));

                    $js = "
            (function(data) {

                let resultData = window['iwae$ScriptHash'] || {

                    started: false,
                    done: false,
                    success: true,
                    data: data,
                    returnValues: []
                }

                window['iwae$ScriptHash'] = resultData;

                function catcher(e) {

                    let resultData = window['iwae$ScriptHash'];
                    resultData.success = false;
                    resultData.done = true;
                    try {
                        resultData.returnValue = JSON.stringify(e);
                    }
                    catch (e2) {

                        resultData.returnValue = e+'';
                    }
                }

                if (!resultData.started) {

                    resultData.started = true;

                    try {

                        eval($("

                        (async () => {
                            let result;
                            try {

                                result = (async function*() { $js })();

                                let resultCount = 0;
                                let resultValue;
                                do {
                                    resultValue = await result.next();

                                    if (resultValue.value instanceof Promise) {

                                        resultValue.value = await resultValue.value;
                                    }

                                    let resultData = window['iwae$ScriptHash']

                                    if (resultCount++ === 0 && resultValue.done) {

                                        resultData.returnValue = resultValue.value;
                                    }
                                    else {
                                        if (!resultValue.done) {

                                            resultData.returnValues.push(resultValue.value);
                                        }
                                    }
                                } while (!resultValue.done)

                                let resultData = window['iwae$ScriptHash']
                                resultData.done = true;
                                resultData.success = true;
                            }
                            catch (e) {

                                catcher(e);
                            }
                        })()

                        " | ConvertTo-Json -Compress -Depth 100));
                    }
                    catch(e) {

                        catcher(e);
                    }
                }

                if (resultData.done) {

                    delete window['iwae$ScriptHash'];
                }

                if (!$($AsJob.ToString().ToLowerInvariant())) {

                    let clone = JSON.parse(JSON.stringify(resultData));
                    resultData.returnValues = [];

                    return clone;
                }
                return resultData;

            })(JSON.parse($json));
        ";
                    try {

                        [int] $pollCount = 0;
                        do {
                            # de-serialize outputed result object
                            $reference = Get-ChromiumSessionReference
                            $json = $Global:chrome.eval($js, 0);
                            if ([string]::IsNullOrWhiteSpace($json)) {

                                if ([datetime]::UtcNow - $startTime -gt [System.TimeSpan]::FromSeconds(120)) {

                                    throw "No response from browser"
                                }

                                Write-Verbose "Empty response from browser, retrying.."
                                continue;
                            }

                            Write-Verbose "Got responses: $json"

                            $result = ($json | ConvertFrom-Json).result;

                            Write-Verbose "Got results: $($result | ConvertTo-Json -Compress -Depth 100)"

                            # all good?
                            if ($result -is [Object]) {

                                $startTime = [DateTime]::UtcNow

                                # get actual returned value
                                $result = $result.result;

                                # present?
                                if ($result -is [Object]) {

                                    # there was an exception thrown?
                                    if ($result.subtype -eq "error") {

                                        # re-throw
                                        throw $result;
                                    }

                                    $result = $result.value;

                                    # got a data object?
                                    if ($result.data -is [PSObject]) {

                                        # initialize
                                        $reference.data = @{}

                                        # enumerate properties
                                        $result.data |
                                        Get-Member -ErrorAction SilentlyContinue |
                                        Where-Object -Property MemberType -Like *Property* |
                                        ForEach-Object -ErrorAction SilentlyContinue {

                                            # set in a case-sensitive manner
                                            $reference.data."$($PSItem.Name)" = $result.data."$($PSItem.Name)"
                                        }

                                        Set-Variable -Name "Data" -Value ($reference.data) -Scope Global
                                    }
                                }
                            }

                            $pollCount++;

                            if ($AsJob -ne $true) {

                                $result.returnValues | Write-Output
                                $result.returnValues = @();
                            }

                        } while (!$result.done -and (-not [Console]::KeyAvailable));

                        if ($AsJob -ne $true) {

                            # result indicate an exception thrown?
                            if ($result.success -eq $false) {

                                if ($result.returnValue -is [string]) {

                                    # re-throw
                                    throw $result.returnValue;
                                }

                                throw "An unknown script parsing error occured";
                            }
                        }
                    }
                    Catch {
                        Write-Error $PSItem

                        $result = $null
                    }

                    if ($AsJob -eq $true) {

                        Write-Output $result;
                    }
                    else {

                        Write-Output $result.returnValue;
                    }

                }
                Catch {

                    throw "
                        $($PSItem.Exception) $($PSItem.InvocationInfo.PositionMessage)
                        $($PSItem.InvocationInfo.Line)
                    "
                }
            }

            if ($AsJob -eq $true) {

                Start-Job -InitializationScript { Import-Module GenXdev.Webbrowser } -ScriptBlock $scriptBlock -ArgumentList @($js, $reference, $true, ($Inspect -eq $true), ($Chrome -eq $true), ($Edge -eq $true));
            }
            else {

                Invoke-Command -ScriptBlock $scriptBlock -ArgumentList @($js, $reference, $false, ($Inspect -eq $true), ($Chrome -eq $true), ($Edge -eq $true));
            }
        }
    }

    End {

    }
}

###############################################################################
###############################################################################

<#
.SYNOPSIS
Navigates current selected tab to specified url

.DESCRIPTION
Navigates current selected tab to specified url

.PARAMETER Url
The Url the browsertab should navigate too

.EXAMPLE
PS C:\> Set-WebbrowserTabLocation "https://github.com/microsoft"

.NOTES
Requires the Windows 10+ Operating System
#>
function Set-WebbrowserTabLocation {

    [Alias("lt", "Nav")]

    param (
        [parameter(
            Mandatory,
            Position = 0,
            HelpMessage = "The Url the browsertab should navigate too"
        )]
        [string] $Url,

        ###############################################################################

        [Alias("e")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Select in Microsoft Edge"
        )]
        [switch] $Edge,

        ###############################################################################

        [Alias("ch")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Select in Google Chrome"
        )]
        [switch] $Chrome
    )

        Invoke-WebbrowserEvaluation "setTimeout(function() { document.location = $($Url | ConvertTo-Json -Compress -Depth 1);}, 1000); return;" -Chrome:$Chrome -Edge:$Edge
}

###############################################################################

<#
.SYNOPSIS
Invokes a script in the current selected webbrowser tab to maximize the video player

.DESCRIPTION
Invokes a script in the current selected webbrowser tab to maximize the video player
#>
function Set-BrowserVideoFullscreen {

    [CmdletBinding()]
    [Alias("fsvideo")]

    param()

    Invoke-WebbrowserEvaluation "window.video = document.getElementsByTagName('video')[0]; video.setAttribute('style','position:fixed;left:0;top:0;bottom:0;right:0;z-index:10000;width:100vw;height:100vh'); document.body.appendChild(video);document.body.setAttribute('style', 'overflow:hidden');"
}

###############################################################################

<#
.SYNOPSIS
Closes the currently selected webbrowser tab

.DESCRIPTION
Closes the currently selected webbrowser tab

.EXAMPLE
PS C:\> Close-WebbrowserTab

PS C:\> st; ct;

.NOTES
Requires the Windows 10+ Operating System
#>
function Close-WebbrowserTab {

    [Alias("ct", "CloseTab")]

    param (
    )

    try {
        Get-ChromiumSessionReference | Out-Null
    }
    catch {
        Select-WebbrowserTab | Out-Null
    }

    "Closing '$($Global:chromeSession.title)' - $($Global:chromeSession.url)"

    Invoke-WebbrowserEvaluation "window.close()" -ErrorAction SilentlyContinue | Out-Null

}

###############################################################################

<#
.SYNOPSIS
Will open an url into three different browsers + a incognito window, with a window mosaic layout

.DESCRIPTION
Will open an url into three different browsers + a incognito window, with a window mosaic layout

.PARAMETER Url
Url to open

.EXAMPLE
Show-WebsiteInallBrowsers "https://www.google.com/"

.NOTES
Requires the Windows 10+ Operating System

To actually see four windows, you need Google Chrome, Firefox and Microsoft Edge installed
#>
function Show-WebsiteInAllBrowsers {

    [CmdletBinding()]
    [Alias("Show-UrlInAllBrowsers")]

    param(

        [parameter(
            Mandatory,
            Position = 0
        )]

        [string] $Url

    )

    Open-Webbrowser -Chrome -Left -Top -Url $Url;
    Open-Webbrowser -Edge -Left -Bottom -Url $Url
    Open-Webbrowser -Firefox -Right -Top -Url $Url;
    Open-Webbrowser -Private -Right -Bottom -Url $Url;
}

###############################################################################

<#
.SYNOPSIS
Updates all browser shortcuts for current user, to enable the remote debugging port by default

.DESCRIPTION
Updates all browser shortcuts for current user, to enable the remote debugging port by default

.NOTES
Requires the Windows 10+ Operating System
#>
function Set-RemoteDebuggerPortInBrowserShortcuts {

    [CmdletBinding()]

    param()

    function removePreviousParam([string] $params) {

        $i = $params.indexOf("--remote-debugging-port=");

        while ($i -ge 0) {

            $params = $params.Substring(0, $i).Trim() + " " + $params.Substring($i + 25).Trim();

            while ($params.Length -ge 0 -and "012345679".IndexOf($params.Substring(0, 1)) -ge 0) {

                if ($params.length -ge 1) {

                    $params = $params.Substring(1);
                }
                else {
                    $params = "";
                }
            }

            $i = $params.indexOf("--remote-debugging-port=");
        }

        return $params;
    }

    [int] $port = (Get-ChromeRemoteDebuggingPort)
    $param = " --remote-allow-origins=* --remote-debugging-port=$port";
    $shell = New-Object -COM WScript.Shell
    @(
        "$Env:AppData\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Google Chrome.lnk",
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk",
        [IO.Path]::Combine((Get-KnownFolderPath StartMenu), "Google Chrome.lnk"),
        [IO.Path]::Combine((Get-KnownFolderPath Desktop), "Google Chrome.lnk")

    ) | ForEach-Object {

        Get-ChildItem $PSItem -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object -ErrorAction SilentlyContinue {
            try {

                $shortcut = $shell.CreateShortcut($PSItem.FullName);
                $shortcut.Arguments = $shortcut.Arguments.replace("222", "").Trim();
                $shortcut.Arguments = "$(removePreviousParam $shortcut.Arguments) $param".Trim()

                $shortcut.Save();
            }
            catch {

                Write-Verbose $PSItem
            }
        }
    }

    $port = (Get-EdgeRemoteDebuggingPort)
    $param = " --remote-allow-origins=* --remote-debugging-port=$port";
    $shell = New-Object -COM WScript.Shell
    @(
        "$Env:AppData\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Microsoft Edge.lnk",
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk",
        [IO.Path]::Combine((Get-KnownFolderPath StartMenu), "Microsoft Edge.lnk"),
        [IO.Path]::Combine((Get-KnownFolderPath Desktop), "Microsoft Edge.lnk")

    ) | ForEach-Object {

        Get-ChildItem $PSItem -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object -ErrorAction SilentlyContinue {
            try {

                $shortcut = $shell.CreateShortcut($PSItem.FullName);
                $shortcut.Arguments = "$(removePreviousParam $shortcut.Arguments.Replace($param, '').Trim())$param"

                $shortcut.Save();
            }
            catch {

                Write-Verbose $PSItem
            }
        }
    }

    # C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe    Set-ItemProperty -Path "HKlm:\Software\Classes\MSEdgeHTM\shell\open\command" -Name "(Default)" -Value "`"${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe`" --single-argument --remote-allow-origins=* --single-argument --remote-debugging-port=$port --single-argument %1"
}

###############################################################################

function Get-ChromeRemoteDebuggingPort {

    [CmdletBinding()]

    param()

    [int] $Port = 0;

    if (![int]::TryParse("$Global:ChromeDebugPort", [ref] $port)) {

        $Port = 9222;
    }

    Set-Variable -Name ChromeDebugPort -Value $Port -Scope Global

    return $Port;
}
###############################################################################

<#
.SYNOPSIS
Returns the configured remote debugging port for Microsoft Edge

.DESCRIPTION
Returns the configured remote debugging port for Microsoft Edge

.NOTES
Use $Global:EdgeDebugPort to override default value of 9223
#>
function Get-EdgeRemoteDebuggingPort {

    [CmdletBinding()]

    param()

    [int] $Port = 0;

    if (![int]::TryParse($Global:EdgeDebugPort, [ref] $port)) {

        $Port = 9223;
    }

    Set-Variable -Name EdgeDebugPort -Value $Port -Scope Global

    return $Port;
}
###############################################################################

<#
.SYNOPSIS
Returns the configured remote debugging port for Google Chrome

.DESCRIPTION
Returns the configured remote debugging port for Google Chrome

.NOTES
Use $Global:EdgeDebugPort to override default value of 9222
#>
function Get-ChromeRemoteDebuggingPort {

    [CmdletBinding()]

    param()

    [int] $Port = 0;

    if (![int]::TryParse($Global:ChromeDebugPort, [ref] $port)) {

        $Port = 9222;
    }

    Set-Variable -Name ChromeDebugPort -Value $Port -Scope Global
    return $Port;
}
###############################################################################

<#
.SYNOPSIS
Returns the configured remote debugging port for Microsoft Edge or Google Chrome, which ever is the default browser

.DESCRIPTION
Returns the configured remote debugging port for Microsoft Edge or Google Chrome, which ever is the default browser
#>
function Get-ChromiumRemoteDebuggingPort {

    [CmdletBinding()]

    param()

    $DefaultBrowser = Get-DefaultWebbrowser;

    if (($null -eq $DefaultBrowser) -or ($DefaultBrowser.Name -like "* Edge*")) {

        Get-EdgeRemoteDebuggingPort;
        return;
    }

    Get-ChromeRemoteDebuggingPort;
}

###############################################################################

<#
.SYNOPSIS
Changes firefox settings to enable remotedebugging and app-mode startups of firefox

.DESCRIPTION
Changes firefox settings to enable remotedebugging and app-mode startups of firefox
#>
function Approve-FirefoxDebugging {

    [CmdletBinding()]

    param()

    try {
        Get-ChildItem "$Env:Appdata\Mozilla\Firefox\Profiles\prefs.js" -File -rec -ErrorAction SilentlyContinue | ForEach-Object -ErrorAction SilentlyContinue {

            $lines = [IO.File]::ReadAllLines($PSItem.FullName);

            $lines = $lines | ForEach-Object {

                if (!$PSItem.Contains("`"browser.ssb.enabled`"") -and !$PSItem.Contains("`"devtools.chrome.enabled`"") -and !$PSItem.Contains("`"devtools.debugger.remote-enabled`"") -and !$PSItem.Contains("`"devtools.debugger.prompt-connection`"")) {

                    $PSItem
                }
            }

            $lines = $lines + @(
                "user_pref(`"devtools.chrome.enabled`",true); ",
                "user_pref(`"devtools.debugger.remote-enabled`",true); ",
                "user_pref(`"devtools.debugger.prompt-connection`",false); "
                "user_pref(`"browser.ssb.enabled`",true); "
            )

            [IO.File]::WriteAllLines($PSItem.FullName, $lines);
        }
    }
    catch {

    }
}

###############################################################################

<#
.SYNOPSIS
Returns a reference that can be used with Select-WebbrowserTab -ByReference

.DESCRIPTION
Returns a reference that can be used with Select-WebbrowserTab -ByReference
This can be usefull when you want to evaluate the webbrowser inside a Job.
With this serializable reference, you can pass the webbrowser tab session reference on to the Job commandblock.
#>
function Get-ChromiumSessionReference {

    [CmdletBinding()]

    param()

    # initialize data hashtable
    if ($Global:Data -isnot [HashTable]) {

        $globalData = @{};
        Set-Variable -Name "Data" -Value $globalData -Scope Global
    }
    else {

        $globalData = $Global:Data;
    }

    # no session yet?
    if (($null -eq $Global:chromeSession) -or ($Global:chromeSession -isnot [GenXdev.Helpers.RemoteSessionsResponse])) {

        throw "Select session first with cmdlet: Select-WebbrowserTab -> st"
    }
    else {

        Write-Verbose "Found existing session: $(($Global:chromeSession | ConvertTo-Json -Depth 100))"
    }

    # get available tabs
    $s = $Global:chrome.GetAvailableSessions();

    # reference selected session
    $debugUri = $Global:chromeSession.webSocketDebuggerUrl;

    # find it in the most recent list
    $found = $false;
    $s | ForEach-Object -Process {

        if ($PSItem.webSocketDebuggerUrl -eq $debugUri) {

            $found = $true;
        }
    }

    # not found?
    if ($found -eq $false) {

        throw "Session expired, select new session with cmdlet: Select-WebbrowserTab -> st"
    }
    else {

        Write-Verbose "Session still active"
    }

    @{
        debugUri = $debugUri;
        port     = $Global:chrome.Port;
        data     = $globalData
    }
}

################################################################################

<#
.SYNOPSIS
Returns the outer HTML of DOM nodes matching the specified query selector in the current web browser tab.

.DESCRIPTION
Uses Invoke-WebbrowserEvaluation to execute a JavaScript script that performs a document.querySelectorAll with the specified query selector and returns the outer HTML of each found node.

.PARAMETER QuerySelector
The query selector string to use for selecting DOM nodes.

.EXAMPLE
PS C:\> Get-WebbrowserTabDomNodes -QuerySelector "div.classname"

.EXAMPLE
PS C:\> wl "div.classname"

.EXAMPLE
PS C:\> Get-WebbrowserTabDomNodes -QuerySelector "video" -ModifyScript "e.play()"

.EXAMPLE
PS C:\> wl video "e.pause()"

.EXAMPLE

.NOTES
Requires the Windows 10+ Operating System
#>
function Get-WebbrowserTabDomNodes {

    [CmdletBinding()]
    [Alias("wl")]

    param(
        [parameter(
            Mandatory,
            Position = 0,
            HelpMessage = "The query selector string to use for selecting DOM nodes"
        )]
        [string] $QuerySelector,

        [parameter(
            Mandatory = $false,
            Position = 1,
            ValueFromRemainingArguments,
            HelpMessage = "The script to modify the output of the query selector, executed in lamda function (e: HtmlNodeElement, i: index) "
        )]
        [string] $ModifyScript = ""
    )

    $script = @"
    let modifyScript = JSON.parse($(($ModifyScript || "") | ConvertTo-Json -Compress -Depth 100 | ConvertTo-Json -Compress));
    let querySelector = JSON.parse($(($QuerySelector || "") | ConvertTo-Json -Compress -Depth 100 | ConvertTo-Json -Compress));
    let nodes = document.querySelectorAll(querySelector);

    for (let i = 0; i < nodes.length; i++) {

        let node = nodes[i];

        if (!!modifyScript && modifyScript != "") {
            try {

                yield await (async function (e, i) {
                    return eval(modifyScript);
                })(node, i, nodes);
            }
            catch (e) {
                console.error(e);
            }
        }
        else {
            yield node.outerHTML;
        }
    }
"@

    Write-Verbose "executing: $script"
    Invoke-WebbrowserEvaluation -Scripts $script
}

################################################################################
################################################################################
<#
.SYNOPSIS
Returns all bookmarks from a browser

.DESCRIPTION
The `Export-BrowserBookmarks` cmdlet returns all bookmarks from  Microsoft Edge, Google Chrome, or Mozilla Firefox.

.PARAMETER Edge
Exports bookmarks from Microsoft Edge.

.PARAMETER Chrome
Exports bookmarks from Google Chrome.

.PARAMETER Firefox
Exports bookmarks from Mozilla Firefox.

.EXAMPLE
Export-BrowserBookmarks -OutputFile "C:\Bookmarks.csv" -Edge

This command exports bookmarks from Edge to the specified CSV file.

.NOTES
Requires access to the browser's bookmarks file. For Firefox, the SQLite module is needed to read from `places.sqlite`.
#>
function Get-BrowserBookmarks {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(Mandatory = $false, ParameterSetName = 'Chrome', HelpMessage = "Exports bookmarks from Google Chrome.")]
        [switch]$Chrome,

        [Parameter(Mandatory = $false, ParameterSetName = 'Edge', HelpMessage = "Exports bookmarks from Microsoft Edge.")]
        [switch]$Edge,

        [Parameter(Mandatory = $false, ParameterSetName = 'Firefox', HelpMessage = "Exports bookmarks from Mozilla Firefox.")]
        [switch]$Firefox
    )

    function Get-Bookmarks {
        param (
            [string]$BookmarksFilePath,
            [string]$RootFolderName,
            [string]$BrowserName
        )

        if (-Not (Test-Path $BookmarksFilePath)) {
            Write-Host "Bookmarks file not found at $BookmarksFilePath"
            return @()
        }

        $bookmarksContent = Get-Content -Path $BookmarksFilePath -Raw | ConvertFrom-Json
        $bookmarks = [System.Collections.Generic.List[object]]::new()

        function TraverseBookmarks {
            param (
                [pscustomobject]$Folder,
                [string]$ParentFolder = ""
            )

            foreach ($item in $Folder.children) {
                if ($item.type -eq "folder") {
                    TraverseBookmarks -Folder $item -ParentFolder ($ParentFolder + "\" + $item.name)
                }
                elseif ($item.type -eq "url") {
                    $bookmarks.Add([pscustomobject]@{
                            Name          = $item.name
                            URL           = $item.url
                            Folder        = $ParentFolder
                            DateAdded     = [DateTime]::FromFileTimeUtc([int64]$item.date_added)
                            DateModified  = if ($item.PSObject.Properties.Match('date_modified')) {
                                [DateTime]::FromFileTimeUtc([int64]$item.date_modified)
                            }
                            else {
                                $null
                            }
                            BrowserSource = $BrowserName
                        })
                }
            }
        }

        TraverseBookmarks -Folder $bookmarksContent.roots.bookmark_bar -ParentFolder "$RootFolderName\Bookmarks Bar"
        TraverseBookmarks -Folder $bookmarksContent.roots.other -ParentFolder "$RootFolderName\Other Bookmarks"
        TraverseBookmarks -Folder $bookmarksContent.roots.synced -ParentFolder "$RootFolderName\Synced Bookmarks"

        return $bookmarks
    }

    function Get-FirefoxBookmarks {
        param (
            [string]$PlacesFilePath,
            [string]$BrowserName
        )

        if (-Not (Test-Path $PlacesFilePath)) {
            Write-Host "Firefox places.sqlite file not found at $PlacesFilePath"
            return @()
        }

        $connectionString = "Data Source=$PlacesFilePath;Version=3;"
        $query = @"
            SELECT
                b.title,
                p.url,
                b.dateAdded,
                b.lastModified,
                f.title AS Folder
            FROM moz_bookmarks b
            JOIN moz_places p ON b.fk = p.id
            LEFT JOIN moz_bookmarks f ON b.parent = f.id
            WHERE b.type = 1
"@

        $bookmarks = @()

        try {

            $connection = New-Object System.Data.SQLite.SQLiteConnection($connectionString)
            $connection.Open()
            $command = $connection.CreateCommand()
            $command.CommandText = $query
            $reader = $command.ExecuteReader()

            while ($reader.Read()) {
                $bookmarks += [pscustomobject]@{
                    Name          = $reader["title"]
                    URL           = $reader["url"]
                    Folder        = $reader["Folder"]
                    DateAdded     = [DateTime]::FromFileTimeUtc($reader["dateAdded"])
                    DateModified  = [DateTime]::FromFileTimeUtc($reader["lastModified"])
                    BrowserSource = $BrowserName
                }
            }

            $reader.Close()
            $connection.Close()
        }
        catch {
            Write-Host "Error reading Firefox bookmarks: $PSItem"
        }

        return $bookmarks
    }

    # Ensure Expand-Path is available
    if (-not (Get-Command -Name Expand-Path -ErrorAction SilentlyContinue)) {
        Import-Module GenXdev.FileSystem
    }

    # Use Get-Webbrowser to determine installed browsers
    $installedBrowsers = Get-Webbrowser

    # If no browser is specified, use the default browser
    if (-not $Edge -and -not $Chrome -and -not $Firefox) {

        $defaultBrowser = Get-DefaultWebbrowser
        if ($defaultBrowser.Name -like '*Edge*') {
            $Edge = $true
        }
        elseif ($defaultBrowser.Name -like '*Chrome*') {
            $Chrome = $true
        }
        elseif ($defaultBrowser.Name -like '*Firefox*') {
            $Firefox = $true
        }
        else {
            Write-Host "Default browser is not Edge, Chrome, or Firefox."
            return
        }
    }

    if ($Edge) {

        $browser = $installedBrowsers | Where-Object { $PSItem.Name -like '*Edge*' }
        if (-not $browser) {
            Write-Host "Microsoft Edge is not installed."
            return
        }
        # Use the browser path to find the bookmarks file
        $bookmarksFilePath = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Microsoft\Edge\User Data\Default\Bookmarks'
        $rootFolderName = 'Edge'
        $bookmarks = Get-Bookmarks -BookmarksFilePath $bookmarksFilePath -RootFolderName $rootFolderName -BrowserName ($browser.Name)
    }
    elseif ($Chrome) {
        $browser = $installedBrowsers | Where-Object { $PSItem.Name -like '*Chrome*' }
        if (-not $browser) {
            Write-Host "Google Chrome is not installed."
            return
        }
        $bookmarksFilePath = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Google\Chrome\User Data\Default\Bookmarks'
        $rootFolderName = 'Chrome'
        $bookmarks = Get-Bookmarks -BookmarksFilePath $bookmarksFilePath -RootFolderName $rootFolderName -BrowserName ($browser.Name)
    }
    elseif ($Firefox) {
        $browser = $installedBrowsers | Where-Object { $PSItem.Name -like '*Firefox*' }
        if (-not $browser) {
            Write-Host "Mozilla Firefox is not installed."
            return
        }
        $profileFolderPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
        $profileFolder = Get-ChildItem -Path $profileFolderPath -Directory | Where-Object { $PSItem.Name -match '\.default-release$' } | Select-Object -First 1
        if ($null -eq $profileFolder) {
            Write-Host 'Firefox profile folder not found.'
            return
        }
        $placesFilePath = Join-Path -Path $profileFolder.FullName -ChildPath 'places.sqlite'
        $bookmarks = Get-FirefoxBookmarks -PlacesFilePath $placesFilePath -BrowserName ($browser.Name)
    }
    else {
        Write-Host 'Please specify either -Chrome, -Edge, or -Firefox switch.'
        return
    }

    $bookmarks
}
################################################################################
<#
.SYNOPSIS
Exports bookmarks from a browser to a json file.

.DESCRIPTION
The `Export-BrowserBookmarks` cmdlet exports bookmarks from Microsoft Edge, Google Chrome, or Mozilla Firefox into a json file.

.PARAMETER OutputFile
Specifies the path to the CSV file where the bookmarks will be saved.

.PARAMETER Edge
Exports bookmarks from Microsoft Edge.

.PARAMETER Chrome
Exports bookmarks from Google Chrome.

.PARAMETER Firefox
Exports bookmarks from Mozilla Firefox.

.EXAMPLE
Export-BrowserBookmarks -OutputFile "C:\Bookmarks.csv" -Edge

This command exports bookmarks from Edge to the specified CSV file.

.NOTES
Requires access to the browser's bookmarks file. For Firefox, the SQLite module is needed to read from `places.sqlite`.
#>
function Export-BrowserBookmarks {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(Mandatory, Position = 0, HelpMessage = "Specifies the path to the CSV file where the bookmarks will be saved.")]
        [string]$OutputFile,

        [Parameter(Mandatory = $false, ParameterSetName = 'Chrome', HelpMessage = "Exports bookmarks from Google Chrome.")]
        [switch]$Chrome,

        [Parameter(Mandatory = $false, ParameterSetName = 'Edge', HelpMessage = "Exports bookmarks from Microsoft Edge.")]
        [switch]$Edge,

        [Parameter(Mandatory = $false, ParameterSetName = 'Firefox', HelpMessage = "Exports bookmarks from Mozilla Firefox.")]
        [switch]$Firefox
    )

    # Expand the output file path
    $OutputFile = Expand-Path $OutputFile

    # Get the bookmarks from the specified browser
    $bookmarksArguments = @{}
    if ($Chrome) { $bookmarksArguments["Chrome"] = $true }
    if ($Edge) { $bookmarksArguments["Edge"] = $true }
    if ($Firefox) { $bookmarksArguments["Firefox"] = $true }

    Get-BrowserBookmarks @bookmarksArguments |
    ConvertTo-Json -Depth 100 |
    Set-Content -Path $OutputFile -Force
}

################################################################################
<#
.SYNOPSIS
Find bookmarks from a browser

.DESCRIPTION
The `Export-BrowserBookmarks` cmdlet exports bookmarks from Microsoft Edge, Google Chrome, or Mozilla Firefox into a json file.

.PARAMETER OutputFile
Specifies the path to the CSV file where the bookmarks will be saved.

.PARAMETER Edge
Exports bookmarks from Microsoft Edge.

.PARAMETER Chrome
Exports bookmarks from Google Chrome.

.PARAMETER Firefox
Exports bookmarks from Mozilla Firefox.

.EXAMPLE
Export-BrowserBookmarks -OutputFile "C:\Bookmarks.csv" -Edge

This command exports bookmarks from Edge to the specified CSV file.

.NOTES
Requires access to the browser's bookmarks file. For Firefox, the SQLite module is needed to read from `places.sqlite`.
#>
function Find-BrowserBookmarks {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [Alias("bookmarks")]

    param (
        [Alias("q", "Value", "Name", "Text", "Query")]
        [parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromRemainingArguments,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string[]] $Queries,
        ###############################################################################

        [Alias("e")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Select in Microsoft Edge"
        )]
        [switch] $Edge,
        ###############################################################################

        [Alias("ch")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Select in Google Chrome"
        )]
        [switch] $Chrome,
        ###############################################################################

        [Alias("ff")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Select in Firefox"
        )]
        [switch] $Firefox,
        ###############################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Maximum number of urls to open, default = 50"
        )]
        [int] $Count = 99999999,
        [parameter(
            Mandatory = $false,
            HelpMessage = "Returns the bookmarks as output"
        )]
        [switch] $PassThru
    )

    process {

        $bookmarksArguments = @{}
        if ($Chrome) { $bookmarksArguments["Chrome"] = $true };
        if ($Edge) { $bookmarksArguments["Edge"] = $true };
        if ($Firefox) { $bookmarksArguments["Firefox"] = $true };

        $bookmarks = Get-BrowserBookmarks @bookmarksArguments

        if (($null -eq $Queries) -or ($Queries.Length -eq 0)) {

            $bookmarks | Select-Object -First $Count
            return;
        }

        $Results = $Queries | ForEach-Object {

            $Q = $PSItem
            $bookmarks | Where-Object { (($PSItem.Folder -like "*$Q*") -or ($PSItem.Name -Like "*$Q*") -or ($PSItem.URL -Like "*$Q*")) } | ForEach-Object { $PSItem }
        } | Select-Object -First $Count;

        if ($PassThru) {

            $Results
        }
        else {

            $Results | ForEach-Object URL
        }
    }
}

################################################################################
<#
.SYNOPSIS
Find bookmarks from a browser

.DESCRIPTION
The `Export-BrowserBookmarks` cmdlet exports bookmarks from Microsoft Edge, Google Chrome, or Mozilla Firefox into a json file.

.PARAMETER OutputFile
Specifies the path to the CSV file where the bookmarks will be saved.

.PARAMETER Edge
Exports bookmarks from Microsoft Edge.

.PARAMETER Chrome
Exports bookmarks from Google Chrome.

.PARAMETER Firefox
Exports bookmarks from Mozilla Firefox.

.EXAMPLE
Export-BrowserBookmarks -OutputFile "C:\Bookmarks.csv" -Edge

This command exports bookmarks from Edge to the specified CSV file.

.NOTES
Requires access to the browser's bookmarks file. For Firefox, the SQLite module is needed to read from `places.sqlite`.
#>
function Open-BrowserBookmarks {

    [Alias("sites")]
    [CmdletBinding(DefaultParameterSetName = 'Default')]

    param (
        [Alias("q", "Value", "Name", "Text", "Query")]
        [parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromRemainingArguments,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string[]] $Queries,
        ###############################################################################

        [Alias("e")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Select in Microsoft Edge"
        )]
        [switch] $Edge,
        ###############################################################################

        [Alias("ch")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Select in Google Chrome"
        )]
        [switch] $Chrome,
        ###############################################################################

        [Alias("ff")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Select in Firefox"
        )]
        [switch] $Firefox,
        ###############################################################################
        ###############################################################################
        [Alias("oe")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Open urls in Microsoft Edge"
        )]
        [switch] $OpenInEdge,
        ###############################################################################

        [Alias("och")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Open urls in Google Chrome"
        )]
        [switch] $OpenInChrome,
        ###############################################################################

        [Alias("off")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Open urls in Firefox"
        )]
        [switch] $OpenInFirefox,

        ###############################################################################

        [Alias("m", "mon")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "The monitor to use, 0 = default, -1 is discard, -2 = Configured secondary monitor, defaults to `Global:DefaultSecondaryMonitor or 2 if not found"
        )]
        [int] $Monitor = -1,

        ###############################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = "Maximum number of urls to open, default = 50"
        )]
        [int] $Count = 50

        ###############################################################################
    )

    DynamicParam {

        Copy-CommandParameters -CommandName "Open-Webbrowser" -ParametersToSkip "Queries", "Chrome", "Edge", "FireFox", "Url", "Monitor"
    }

    begin {
        $PSBoundParameters["Monitor"] = $Monitor;
        $PSBoundParameters.Remove("Queries") | Out-Null;
        $PSBoundParameters.Remove("Chrome") | Out-Null;
        $PSBoundParameters.Remove("Firefox") | Out-Null;
        $PSBoundParameters.Remove("Edge") | Out-Null;
        $PSBoundParameters.Remove("Count") | Out-Null;
        $PSBoundParameters.Remove("OpenInEdge") | Out-Null;
        $PSBoundParameters.Remove("OpenInChrome") | Out-Null;
        $PSBoundParameters.Remove("OpenInFirefox") | Out-Null;

        if ($OpenInEdge) { $PSBoundParameters["Edge"] = $true };
        if ($OpenInChrome) { $PSBoundParameters["Chrome"] = $true };
        if ($OpenInFirefox) { $PSBoundParameters["Firefox"] = $true };
    }
    process {

        $FindParams = @{PassThru = $true }
        $FindParams["Queries"] = $Queries;
        if ($Chrome) { $FindParams["Chrome"] = $true };
        if ($Edge) { $FindParams["Edge"] = $true };
        if ($Firefox) { $FindParams["Firefox"] = $true };

        $PSBoundParameters["Url"] = @((Find-BrowserBookmarks @FindParams | ForEach-Object Url | Select-Object -First $Count))

        if ($PSBoundParameters["Url"].length -eq 0) {

            Write-Host "Nothing found"
            return;
        }

        Open-Webbrowser @PSBoundParameters
    }
}

################################################################################

<#
.SYNOPSIS
Imports bookmarks from a json file into a browser.

.DESCRIPTION
The `Import-BrowserBookmarks` cmdlet imports bookmarks from a json file into Microsoft Edge or Google Chrome.

.PARAMETER InputFile
Specifies the path to the json file containing the bookmarks to import.

.PARAMETER Bookmarks
Specifies a collection of bookmarks to import.

.PARAMETER Edge
Imports bookmarks into Microsoft Edge.

.PARAMETER Chrome
Imports bookmarks into Google Chrome.

.PARAMETER Firefox
(Not supported) Importing bookmarks into Firefox is currently not supported by this cmdlet.

.EXAMPLE
Import-BrowserBookmarks -InputFile "C:\Bookmarks.csv" -Edge

This command imports bookmarks from the specified CSV file into Edge.

.NOTES
For Edge and Chrome, the bookmarks are added to the 'Bookmarks Bar'. Importing into Firefox is currently not supported.
#>
function Import-BrowserBookmarks {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'FromFile', HelpMessage = "Specifies the path to the CSV file containing the bookmarks to import.")]
        [string]$InputFile,

        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'FromCollection', HelpMessage = "Specifies a collection of bookmarks to import.")]
        [array]$Bookmarks,

        [Parameter(Mandatory = $false, HelpMessage = "Imports bookmarks into Google Chrome.")]
        [switch]$Chrome,

        [Parameter(Mandatory = $false, HelpMessage = "Imports bookmarks into Microsoft Edge.")]
        [switch]$Edge,

        [Parameter(Mandatory = $false, HelpMessage = "Importing bookmarks into Firefox is currently not supported.")]
        [switch]$Firefox
    )

    $importedBookmarks = if ($Bookmarks) {
        # Use the provided bookmarks collection
        $Bookmarks
    }
    elseif ($InputFile) {
        # Read the bookmarks from the CSV file
        Import-Csv -Path $InputFile
    }
    else {
        Write-Host "Please provide either an InputFile or a Bookmarks collection."
        return
    }

    $installedBrowsers = Get-Webbrowser

    function Write-Bookmarks {
        param (
            [string]$BookmarksFilePath,
            [array]$BookmarksToWrite
        )

        if ($Edge -or $Chrome) {
            $bookmarksContent = if (Test-Path $BookmarksFilePath) {
                Get-Content -Path $BookmarksFilePath -Raw | ConvertFrom-Json
            }
            else {
                @{
                    roots = @{
                        bookmark_bar = @{children = @() }
                        other        = @{children = @() }
                        synced       = @{children = @() }
                    }
                }
            }

            foreach ($bookmark in $BookmarksToWrite) {
                $newBookmark = @{
                    type          = "url"
                    name          = $bookmark.Name
                    url           = $bookmark.URL
                    date_added    = if ($bookmark.DateAdded) {
                        [string]$bookmark.DateAdded.ToFileTimeUtc()
                    }
                    else {
                        [string][DateTime]::UtcNow.ToFileTimeUtc()
                    }
                    date_modified = if ($bookmark.DateModified) {
                        [string]$bookmark.DateModified.ToFileTimeUtc()
                    }
                    else {
                        $null
                    }
                }

                # Determine the folder to add the bookmark to
                $folderPath = $bookmark.Folder -split '\\'
                $currentNode = $bookmarksContent.roots.bookmark_bar

                foreach ($folder in $folderPath) {
                    if ($folder -eq 'Bookmarks Bar') {
                        $currentNode = $bookmarksContent.roots.bookmark_bar
                    }
                    elseif ($folder -eq 'Other Bookmarks') {
                        $currentNode = $bookmarksContent.roots.other
                    }
                    elseif ($folder -eq 'Synced Bookmarks') {
                        $currentNode = $bookmarksContent.roots.synced
                    }
                    else {
                        $existingFolder = $currentNode.children | Where-Object { $PSItem.type -eq 'folder' -and $PSItem.name -eq $folder }
                        if ($existingFolder) {
                            $currentNode = $existingFolder
                        }
                        else {
                            $newFolder = @{
                                type     = 'folder'
                                name     = $folder
                                children = @()
                            }
                            $currentNode.children += $newFolder
                            $currentNode = $newFolder
                        }
                    }
                }

                # Add the new bookmark to the determined folder
                $currentNode.children += $newBookmark

                $bookmarksContent | ConvertTo-Json -Depth 100 | Set-Content -Path $BookmarksFilePath
            }
            elseif ($Firefox) {
                Write-Host "Importing bookmarks to Firefox is currently not supported in this script."
                # Note: Importing bookmarks to Firefox would require SQLite operations to modify the places.sqlite file, which is more complex and not covered here.
            }
        }

        # Ensure Expand-Path is available
        if (-not (Get-Command -Name Expand-Path -ErrorAction SilentlyContinue)) {

            Import-Module GenXdev.FileSystem
        }
        # Expand the input file path
        $InputFile = Expand-Path $InputFile

        # If no browser is specified, use the default browser
        if (-not $Edge -and -not $Chrome -and -not $Firefox) {
            $defaultBrowser = Get-DefaultWebbrowser
            if ($defaultBrowser.Name -like '*Edge*') {
                $Edge = $true
            }
            elseif ($defaultBrowser.Name -like '*Chrome*') {
                $Chrome = $true
            }
            elseif ($defaultBrowser.Name -like '*Firefox*') {
                $Firefox = $true
            }
            else {
                Write-Host "Default browser is not Edge, Chrome, or Firefox."
                return
            }
        }

        if ($Edge) {
            $browser = $installedBrowsers | Where-Object { $PSItem.Name -like '*Edge*' }
            if (-not $browser) {
                Write-Host "Microsoft Edge is not installed."
                return
            }
            $bookmarksFilePath = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Microsoft\Edge\User Data\Default\Bookmarks'
            Write-Bookmarks -BookmarksFilePath $bookmarksFilePath -BookmarksToWrite $importedBookmarks
        }
        elseif ($Chrome) {
            $browser = $installedBrowsers | Where-Object { $PSItem.Name -like '*Chrome*' }
            if (-not $browser) {
                Write-Host "Google Chrome is not installed."
                return
            }
            $bookmarksFilePath = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Google\Chrome\User Data\Default\Bookmarks'
            Write-Bookmarks -BookmarksFilePath $bookmarksFilePath -BookmarksToWrite $importedBookmarks
        }
        elseif ($Firefox) {
            Write-Host 'Importing bookmarks into Firefox is currently not supported in this script.'
        }
        else {
            Write-Host 'Please specify either -Chrome, -Edge, or -Firefox switch.'
        }
    }
}

################################################################################
<#
.SYNOPSIS
Clears the application data of a web browser tab.

.DESCRIPTION
The `Clear-WebbrowserTabSiteApplicationData` cmdlet clears the application data of a web browser tab.

These include:
    - localStorage
    - sessionStorage
    - cookies
    - indexedDB
    - caches
    - service workers
#>
function Clear-WebbrowserTabSiteApplicationData {

    [CmdletBinding()]
    [Alias("clearsitedata")]

    param (
        [Alias("e")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Clear in Microsoft Edge"
        )]
        [switch] $Edge,
        ###############################################################################

        [Alias("ch")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Clear in Google Chrome"
        )]
        [switch] $Chrome
    )

    [string] $LocationJSScriptLet = "`"javascript:(function()%7BlocalStorage.clear()%3BsessionStorage.clear()%3Bdocument.cookie.split(\`"%3B\`").forEach(function(c)%7Bdocument.cookie%3Dc.replace(%2F%5E %2B%2F%2C\`"\`").replace(%2F%3D.*%2F%2C\`"%3D%3Bexpires%3D\`"%2Bnew Date().toUTCString()%2B\`"%3Bpath%3D%2F\`")%7D)%3Bwindow.indexedDB.databases().then((dbs)%3D>%7Bdbs.forEach((db)%3D>%7BindexedDB.deleteDatabase(db.name)%7D)%7D)%3Bif('caches' in window)%7Bcaches.keys().then((names)%3D>%7Bnames.forEach(name%3D>%7Bcaches.delete(name)%7D)%7D)%7Dif('serviceWorker' in navigator)%7Bnavigator.serviceWorker.getRegistrations().then((registrations)%3D>%7Bregistrations.forEach((registration)%3D>%7Bregistration.unregister()%7D)%7D)%7Dalert('All browser storage cleared!')%7D)()`"" | ConvertFrom-Json

    Set-WebbrowserTabLocation -Url $LocationJSScriptLet -Edge:$Edge -Chrome:$Chrome
}

################################################################################
################################################################################
