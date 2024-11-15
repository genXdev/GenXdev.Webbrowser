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

.PARAMETER RestoreFocus
Restore PowerShell window focus --> -bg

.PARAMETER NewWindow
Don't re-use existing browser window, instead, create a new one -> nw

.PARAMETER PassThrough
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

        [Alias("Value", "Website", "Uri", "FullName")]
        [parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "The url to open",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
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
        [switch] $PassThrough
    )

    Begin {

        Write-Verbose "Open-Webbrowser monitor = $Monitor"

        [bool] $UrlSpecified = $false;

        # what if no url is specified?
        if (($null -eq $Url) -or ($Url.Length -lt 1)) {

            $UrlSpecified = $false;

            # show the help page from github
            $Url = @("https://github.com/genXdev/GenXdev.Webbrowser/blob/main/README.md#Open-Webbrowser")
        }
        else {

            $Url = $Url.Trim(" `"'".ToCharArray());
            $filePath = $Url
            try {
                $filePath = (Expand-Path $Url);
            }
            catch {

            }

            if ([IO.File]::Exists($filePath)) {

                $Url = "file://$([Uri]::EscapeUriString($filePath.Replace("\", "/")))"
            }
        }

        # reference powershell main window
        $PowerShellWindow = Get-PowershellMainWindow

        # get a list of all available/installed modern webbrowsers
        $Browsers = Get-Webbrowser

        # get the configured default webbrowser
        $DefaultBrowser = Get-DefaultWebbrowser

        # reference the main monitor
        $Screen = [System.Windows.Forms.Screen]::PrimaryScreen;

        if ($Monitor -lt -1) {

            [int] $defaultMonitor = 1;

            if ([int]::TryParse($Global:DefaultSecondaryMonitor, [ref] $defaultMonitor)) {

                $Monitor = $defaultMonitor % ([System.Windows.Forms.Screen]::AllScreens.Length + 1);
            }
            else {

                $Monitor = 2 % ([System.Windows.Forms.Screen]::AllScreens.Length + 1);
            }
        }

        # reference the requested monitor
        if (($Monitor -ge 1) -and ($Monitor -lt [System.Windows.Forms.Screen]::AllScreens.Length)) {

            $Screen = [System.Windows.Forms.Screen]::AllScreens[$Monitor - 1]
        }
        if (($Monitor -eq 0)) {

            $Screen = [System.Windows.Forms.Screen]::PrimaryScreen;
        }

        # remember
        [bool] $HavePositioning = ($Monitor -ge 0) -or ($Left -or $Right -or $Top -or $Bottom -or $Centered -or (($X -is [int]) -and ($X -gt -999999)) -or (($Y -is [int]) -and ($Y -gt -999999)));

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

        if ($HavePositioning) {

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

                    Write-Verbose "Due to recent close of $($Browser.Name) now sleeping for $(($last.Value.AddSeconds(1) - $now).TotalMilliseconds)ms"

                    [System.Threading.Thread]::Sleep(($last.Value.AddSeconds(1) - $now).TotalMilliseconds)
                }
            }
        }

        function refocusTab($browser, $CurrentUrl) {

            # '-RestoreFocus' parameter supplied'?
            if ($RestoreFocus -eq $true) {

                # Get handle to current foreground window
                $CurrentActiveWindow = [GenXdev.Helpers.WindowObj]::GetFocusedWindow();

                # Is it different then the one at the start of this command?
                if (($null -ne $PowerShellWindow) -and ($PowerShellWindow.Handle -ne $CurrentActiveWindow.Handle)) {

                    # restore it
                    $PowerShellWindow.SetForeground();

                    # wait
                    [System.Threading.Thread]::Sleep(250);

                    # did it not work?
                    $CurrentActiveWindow = [GenXdev.Helpers.WindowObj]::GetFocusedWindow();

                    if ($PowerShellWindow.Handle -ne $CurrentActiveWindow.Handle) {

                        try {
                            # Sending Alt-Tab
                            $helper = New-Object -ComObject WScript.Shell;
                            $helper.sendKeys("%{TAB}");
                            Write-Verbose "Sending Alt-Tab"

                            # wait
                            [System.Threading.Thread]::Sleep(500);
                        }
                        catch {

                        }
                    }
                }

                #  positioning of windows did happen?
                if ($HavePositioning -eq $true) {

                    # wait a little
                    [System.Threading.Thread]::Sleep(500);
                }
            }
            else {
                #  positioning of windows did happen?
                if ($HavePositioning -eq $true) {

                    # wait a little
                    [System.Threading.Thread]::Sleep(500);
                }
            }
        }

        function constructArgumentList($browser, $CurrentUrl) {

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
                        if ($NewWindow -eq $true) {

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
                    $ArgumentList = $ArgumentList + @(
                        "--disable-infobars",
                        "--disable-session-crashed-bubble",
                        "--no-default-browser-check",
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
                    if ($NewWindow -eq $true) {

                        # set commandline argument
                        $ArgumentList = $ArgumentList + @("--new-window")
                    }

                    # '-Fullscreen' parameter supplied'?
                    if ($FullScreen -eq $true) {

                        # set commandline argument
                        $ArgumentList = $ArgumentList + @("--start-fullscreen")
                    }

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

        function open($browser, $CurrentUrl) {
            try {
                enforceMinimumDelays $browser
                ###############################################################################

                $StartBrowser = $true;
                $hadVisibleBrowser = $false;
                $process = $null;

                # find any existing  process
                $prcBefore = @(Get-Process -ErrorAction SilentlyContinue |
                    Where-Object -Property Path -EQ $browser.Path |
                    Where-Object -Property MainWindowHandle -NE 0 |
                    Sort-Object { $PSItem.StartTime } -Descending |
                    Select-Object -First 1)

                #found?
                if (($prcBefore.Length -ge 1) -and ($null -ne $prcBefore[0])) {

                    $hadVisibleBrowser = $true;
                }

                # no url specified?
                if (($NewWindow -ne $true) -and ($HavePositioning -eq $true) -and ($UrlSpecified -eq $false)) {

                    if ($hadVisibleBrowser) {

                        Write-Verbose "No url specified, found existing webbrowser window"
                        $StartBrowser = $false;
                        $process = $prcBefore[0];
                    }
                }

                if ($StartBrowser) {

                    if ($Force) {
                        $a = Select-WebbrowserTab

                        if ($a.length -eq 0) {

                            Find-Process -Name (Get-ChildItem $Browser.Path).Name | Stop-Process -Force
                        }
                    }

                    # get the browser dependend argument list
                    $ArgumentList = constructArgumentList $browser $CurrentUrl

                    # log
                    Write-Verbose "$($browser.Name) --> $($ArgumentList | ConvertTo-Json)"

                    # setup process start info
                    $si = New-Object "System.Diagnostics.ProcessStartInfo"
                    $si.FileName = $browser.Path
                    $si.CreateNoWindow = $true;
                    $si.UseShellExecute = $false;
                    $si.WindowStyle = "Normal"
                    foreach ($arg in $ArgumentList) { $si.ArgumentList.Add($arg); }

                    # start process
                    $process = [System.Diagnostics.Process]::Start($si)
                }

                ###############################################################################

                # nothing to do anymore? then don't waste time on positioning the window
                if (($HavePositioning -eq $false) -and ($PassThrough -ne $true)) {

                    Write-Verbose "No positioning required, done.."
                    return;
                }

                ###############################################################################

                # allow the browser to start-up, and update process handle if needed
                enforceMinimumDelays $browser
                [int] $i = 0;
                $window = @();
                $existingWindow = $false;
                do {

                    # did it only signal an already existing webbrowser instance, to create a new tab,
                    # and did it then exit?
                    if ($process.HasExited) {

                        # find the process
                        $processesNew = @(Get-Process -ErrorAction SilentlyContinue |
                            Where-Object -Property Path -EQ $browser.Path |
                            Where-Object -Property MainWindowHandle -NE 0 |
                            Sort-Object { $PSItem.StartTime } -Descending |
                            Select-Object -First 1)

                        # not found?
                        if (($processesNew.Length -eq 0) -or ($null -eq $processesNew[0])) {

                            $window = @();

                            [System.Threading.Thread]::Sleep(80);
                        }
                        else {

                            # get window helper utility for the mainwindow of the process
                            $existingWindow = $hadVisibleBrowser;
                            $process = $processesNew[0];
                            $window = [GenXdev.Helpers.WindowObj]::GetMainWindow($process, 1, 80);
                        }
                    }
                    else {

                        # get window helper utility for the mainwindow of the process
                        $window = [GenXdev.Helpers.WindowObj]::GetMainWindow($process, 1, 80);
                    }
                } while (($i++ -lt 50) -and ($window.length -le 0));

                if (($PassThrough -eq $true) -and ($null -ne $process)) {

                    Write-Output $process
                }

                if ($HavePositioning -eq $false) {

                    Write-Verbose "No positioning required, done.."
                    return;
                }

                ###############################################################################

                # have a handle to the mainwindow of the browser?
                if ($window.Length -eq 1) {

                    Write-Verbose "Restoring and positioning browser window"

                    # if maximized, restore window style
                    $window[0].Show() | Out-Null

                    # move it to it's place
                    $window[0].Move($X, $Y, $Width, $Height)  | Out-Null

                    # wait
                    [System.Threading.Thread]::Sleep(750);

                    # do again
                    $window[0].Show()  | Out-Null
                    $window[0].Move($X, $Y, $Width, $Height) | Out-Null

                    # needs to be set fullscreen manually?
                    if (($existingWindow -eq $false) -and ($FullScreen -eq $true) -and
                        ($Browser.Name -like "*Firefox*" -or ("--start-fullscreen" -notin $ArgumentList))) {

                        Write-Verbose "Setting fullscreen"

                        # do some magic to make it the foreground window
                        $window[0].SetForeground() | Out-Null
                        $window[0].Move($X, $Y, $Width, $Height) | Out-Null

                        # did it not work?
                        $test = [GenXdev.Helpers.WindowObj]::GetFocusedWindow();
                        if ($test.Handle -ne $process.MainWindowHandle) {

                            try {
                                # send alt-tab
                                $helper = New-Object -ComObject WScript.Shell;
                                $helper.sendKeys("%{TAB}");
                                Write-Verbose "Sending Alt-Tab"
                            }
                            catch {

                            }

                            # wait
                            Start-Sleep 1
                        }

                        # is the browserwindow now focused?
                        $test = [GenXdev.Helpers.WindowObj]::GetFocusedWindow();
                        if ($test.Handle -eq $process.MainWindowHandle) {

                            try {
                                # send F11
                                $helper = New-Object -ComObject WScript.Shell;
                                $helper.sendKeys("{F11}");
                                Write-Verbose "Sending F11"
                            }
                            catch {

                            }
                        }
                    }
                }
            }
            finally {

                # if needed, restore the focus to the PowerShell terminal
                refocusTab $browser $CurrentUrl
            }
        }

        ###############################################################################

        # start processing the Urls that we need to open
        $Url | ForEach-Object {

            # reference the next Url
            $CurrentUrl = $PSItem;

            # '-All' parameter was supplied?
            if ($All -eq $true) {

                # open for all browsers
                $Browsers | ForEach-Object { open $PSItem $CurrentUrl }

                return;
            }

            # '-Chromium' parameter was supplied
            if ($Chromium -eq $true) {

                # default browser already chrome or edge?
                if (($DefaultBrowser.Name -like "*Chrome*") -or ($DefaultBrowser.Name -like "*Edge*")) {

                    # open default browser
                    open $DefaultBrowser $CurrentUrl
                    return;
                }

                # enumerate all browsers
                $Browsers | Sort-Object { $PSItem.Name } -Descending | ForEach-Object {

                    # found edge or chrome?
                    if (($PSItem.Name -like "*Chrome*") -or ($PSItem.Name -like "*Edge*")) {

                        # open it
                        open $PSItem $CurrentUrl
                    }
                }
            }
            else {

                # '-Chrome' parameter supplied?
                if ($Chrome -eq $true) {

                    # enumerate all browsers
                    $Browsers | ForEach-Object {

                        # found chrome?
                        if ($PSItem.Name -like "*Chrome*") {

                            # open it
                            open $PSItem $CurrentUrl
                        }
                    }
                }

                # '-Edge' parameter supplied?
                if ($Edge -eq $true) {

                    # enumerate all browsers
                    $Browsers | ForEach-Object {

                        # found Edge?
                        if ($PSItem.Name -like "*Edge*") {

                            # open it
                            open $PSItem $CurrentUrl
                        }
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
                        open $PSItem $CurrentUrl
                    }
                }
            }

            # no specific browser requested?
            if (($Chromium -ne $true) -and ($Chrome -ne $true) -and ($Edge -ne $true) -and ($Firefox -ne $true)) {

                # open default browser
                open $DefaultBrowser $CurrentUrl
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

        [parameter(Mandatory = $true, ParameterSetName = "byName", Position = 0,
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
            Mandatory = $true,
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

            if ([String]::IsNullOrWhiteSpace($_.url) -eq $false) {
                $b = " ";
                if ($_.webSocketDebuggerUrl -eq $Global:chromeSession.webSocketDebuggerUrl) {

                    $b = "*";
                }

                $Url = $_.url;

                if ($_.url.startsWith("chrome-extension:") -or $_.url.contains("/offline/")) {

                    $Url = "chrome-extension: ($($_.title))";
                }

                "{`"id`":$i,`"A`":`"$b`",`"url`":$([GenXdev.Helpers.Serialization]::ToJson($Url))}" | ConvertFrom-Json
                $i = $i + 1;
            }
        }
    }

    if ($Global:chrome -isnot [GenXdev.Helpers.Chrome] -or $Global:chrome.Port -ne $port) {

        Write-Verbose "Creating new chromium automation object"
        $c = New-Object "GenXdev.Helpers.Chrome" @("http://localhost:$port")
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

                Close-Webbrowser -Chrome:$Chrome -Edge:$Edge -Force

                if ([string]::IsNullOrWhiteSpace($Name)) {

                    Open-Webbrowser -Chrome:$Chrome -Edge:$Edge -Force
                    $s = $Global:chrome.GetAvailableSessions();
                }
                else {

                    Open-Webbrowser -Chrome:$Chrome -Edge:$Edge -Force -Url $Name
                    $s = $Global:chrome.GetAvailableSessions();
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

            $list.Add($_)
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
            if ($_.webSocketDebuggerUrl -eq $debugUri) {
                $found = $true;

                $Global:chrome.SetActiveSession($_.webSocketDebuggerUrl);
                Set-Variable -Name chromeSession -Value $_ -Scope Global
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
Select-WebbrowserTab;
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
Select-WebbrowserTab;
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

Select-WebbrowserTab;
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
Select-WebbrowserTab;
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
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)
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
        [switch] $NoAutoSelectTab
    )

    Begin {

        try {
            $reference = Get-ChromiumSessionReference
        }
        catch {
            if ($NoAutoSelectTab -eq $true) {

                throw $PSItem.Exception
            }

            Select-WebbrowserTab | Out-Null
            $reference = Get-ChromiumSessionReference
        }
    }

    Process {

        Write-Verbose "Processing.."

        # enumerate provided scripts
        foreach ($js in $Scripts) {

            $scriptBlock = {

                param($js, $reference, $AsJob, $Inspect)

                try {
                    Set-Variable -Name "Data" -Value $reference.data -Scope Global

                    Select-WebbrowserTab -ByReference $reference

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
                        resultData.returnValue = JSON.parse(JSON.stringify(e));
                    }
                    catch (e2) {

                        resultData.returnValue = e+`"`";
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
                            $result = ($Global:chrome.eval($js, 5) | ConvertFrom-Json).result;
                            Write-Verbose "Got results: $($result | ConvertTo-Json -Compress -Depth 100)"

                            # all good?
                            if ($result -is [Object]) {

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

                                        Set-Variable -Name "Data" -Value $reference.data -Scope Global
                                    }
                                }
                            }

                            if ($pollCount -gt 0) {

                                Start-Sleep 1 -Verbose
                            }

                            $pollCount++;

                            if ($AsJob -ne $true) {

                                $result.returnValues | Write-Output
                                $result.returnValues = @();
                            }

                        } while (!$result.done);

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
                        Write-Error $_

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
                        $($_.Exception) $($_.InvocationInfo.PositionMessage)
                        $($_.InvocationInfo.Line)
                    "
                }

            }

            if ($AsJob -eq $true) {

                Start-Job -InitializationScript { Import-Module GenXdev.Webbrowser } -ScriptBlock $scriptBlock -ArgumentList @($js, $reference, $true, ($Inspect -eq $true))
            }
            else {

                Invoke-Command -ScriptBlock $scriptBlock -ArgumentList @($js, $reference, $false, ($Inspect -eq $true));
            }
        }
    }

    End {

    }
}
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
            Mandatory = $true,
            Position = 0,
            HelpMessage = "The Url the browsertab should navigate too"
        )]
        [string] $Url
    )

    try {
        $Url = [Uri]::new($Url).ToString();
    }
    catch {
        throw "Url '$Url' is not in a proper format"
    }

    Invoke-WebbrowserEvaluation "let old = document.location;document.location = '$Url'; 'Navigating from '+old+' --> \'$Url\''"
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
    Proxy function dynamic parameter block for the Open-Webbrowser cmdlet
.DESCRIPTION
    The dynamic parameter block of a proxy function. This block can be used to copy a proxy function target's parameters .
#>
function Copy-OpenWebbrowserParameters {

    [System.Diagnostics.DebuggerStepThrough()]

    param(
        [string[]] $ParametersToSkip = @()
    )

    Copy-CommandParameters -CommandName "Open-Webbrowser" -ParametersToSkip $ParametersToSkip
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
    if ($Global:chromeSession -isnot [GenXdev.Helpers.RemoteSessionsResponse]) {

        throw "Select session first with cmdlet: Select-WebbrowserTab -> st"
    }
    else {

        Write-Verbose "Found existing session: $($Global.chromeSession | ConvertTo-Json -Depth 100)"
    }

    # get available tabs
    $s = $Global:chrome.GetAvailableSessions();

    # reference selected session
    $debugUri = $Global:chromeSession.webSocketDebuggerUrl;

    # find it in the most recent list
    $found = $false;
    $s | ForEach-Object -Process {

        if ($_.webSocketDebuggerUrl -eq $debugUri) {

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
################################################################################
################################################################################
