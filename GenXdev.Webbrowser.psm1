######################################################################################################################################################
######################################################################################################################################################
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
######################################################################################################################################################
######################################################################################################################################################
<#
.SYNOPSIS
Returns a collection of installed modern webbrowsers

.DESCRIPTION
Returns an collection of objects each describing a installed modern webbrowser

.EXAMPLE
PS C:\> Get-Webbrowser | Foreach-Object { & $PSItem.Path https://www.github.com/ }

PS C:\> Get-Webbrowser | select Name, Description | Format-Table

PS C:\> Get-Webbrowser | select Name, Path | Format-Table

.NOTES
Requires the Windows 10+ Operating System
#>
function Get-Webbrowser {

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
######################################################################################################################################################
######################################################################################################################################################
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
Open in all registered modern browsers -> -a

.PARAMETER Monitor
The monitor to use, 0 = default, -1 is discard --> -m, -mon

.PARAMETER FullScreen
Open in fullscreen mode --> -fs

.PARAMETER Left
Place browser window on the left side of the screen

.PARAMETER Right
Place browser window on the right side of the screen

.PARAMETER Top
Place browser window on the top side of the screen

.PARAMETER Bottom
Place browser window on the bottom side of the screen

.PARAMETER Foreground
Don't restore Powershell window focus --> -fg

.PARAMETER NoNewWindow
Re-use existing browser window, instead of creating a new one -> -nw, -nnw

.EXAMPLE
PS C:\> Open-Webbrowser -Chrome -Left -Top -Url "https://genxdev.net/"
PS C:\> @("https://genxdev.net/", "https://github.com/renevaessen/") | Open-Webbrowser -Monitor -1 -Foreground -NoNewWindow

.NOTES
Requires the Windows 10+ Operating System

This cmdlet was mend to be used, interactively.
It performs some strange tricks to position windows, including invoking alt-tab keystrokes.
It's best not to touch the keyboard or mouse, while it is doing that, for the best experience.

To disable any wait times due to this, you can disable it by;
    setting: -Monitor -1 -Foreground
    AND    : not using any of these switches: -Left -Right -Top -Bottom

For browsers that are not installed on the system, no actions may be performed or errors occur - at all.
#>
function Open-Webbrowser {

    [CmdletBinding()]
    [Alias("wb")]

    param(
        ####################################################################################################
        [Alias("Value")]
        [parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "The url to open",
            ValueFromPipeline = $true,
            ValueFromRemainingArguments = $true
        )]
        [string[]] $Url,
        ####################################################################################################
        [Alias("incognito", "inprivate")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Opens in incognito-/in-private browsing- mode"
        )]
        [switch] $Private,
        ####################################################################################################
        [Alias("e")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Opens in Microsoft Edge"
        )]
        [switch] $Edge,
        ####################################################################################################
        [Alias("ch")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Opens in Google Chrome"
        )]
        [switch] $Chrome,
        ####################################################################################################
        [Alias("c")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Opens in Microsoft Edge or Google Chrome, depending on what the default browser is"
        )]
        [switch] $Chromium,
        ####################################################################################################
        [Alias("ff")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Opens in Firefox"
        )]
        [switch] $Firefox,
        ####################################################################################################
        [Alias("a")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Opens in all registered modern browsers"
        )]
        [switch] $All,
        ####################################################################################################
        [Alias("m", "mon")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "The monitor to use, 0 = default, -1 is discard"
        )]
        [int] $Monitor = 1,
        ####################################################################################################
        [Alias("fs")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Opens in fullscreen mode"
        )]
        [switch] $FullScreen,
        ####################################################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the left side of the screen"
        )]
        [switch] $Left,
        ####################################################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the right side of the screen"
        )]
        [switch] $Right,
        ####################################################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the top side of the screen"
        )]
        [switch] $Top,
        ####################################################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the bottom side of the screen"
        )]
        [switch] $Bottom,
        ####################################################################################################
        [Alias("fg", "focus")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Don't restore Powershell window focus"
        )]
        [switch] $Foreground,
        ####################################################################################################
        [Alias("nw", "nnw")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Re-use existing browser window, instead of creating a new one"
        )]
        [switch] $NoNewWindow
    )
    Begin {

        # what if no url is specified?
        if (($null -eq $Url) -or ($Url.Length -lt 1)) {

            # show the help page from github
            $Url = @("https://github.com/renevaessen/GenXdev.Webbrowser/blob/main/README.md#syntax")
        }

        # remember current foreground window
        $PreviousActiveWindow = [GenXdev.Helpers.WindowObj]::GetFocusedWindow();

        # get a list of all available/installed modern webbrowsers
        $Browsers = Get-Webbrowser

        # get the configured default webbrowser
        $DefaultBrowser = Get-DefaultWebbrowser

        # initialize an empty argument list for the webbrowser commandline
        $ArgumentList = @();

        # reference the main monitor
        $Screen = [System.Windows.Forms.Screen]::PrimaryScreen;

        # reference the requested monitor
        if (($Monitor -ge 1) -and ($Monitor -lt [System.Windows.Forms.Screen]::AllScreens.Length)) {

            $Screen = [System.Windows.Forms.Screen]::AllScreens[$Monitor]
        }

        # init window position
        [int] $X = $Screen.WorkingArea.X;
        [int] $Y = $Screen.WorkingArea.Y;
        [int] $Width = $Screen.WorkingArea.Width;
        [int] $Height = $Screen.WorkingArea.Height;

        # remember
        [bool] $HavePositioning = ($Monitor -ge 0) -or ($Left -or $Right -or $Top -or $Bottom);

        # get the right debugging tcp port for this browser
        if ($Edge -eq $true) {

            $port = Get-EdgeRemoteDebuggingPort
        }
        else {
            if ($Chrome -eq $true) {

                $port = Get-ChromeRemoteDebuggingPort
            }
            else {

                $port = Get-ChromiumRemoteDebuggingPort
            }
        }

        # setup exact window position and size
        if ($Left -eq $true) {

            $Width = $Screen.WorkingArea.Width / 2;
        }
        else {
            if ($Right -eq $true) {

                $Width = $Screen.WorkingArea.Width / 2;
                $X = $Screen.WorkingArea.X + $Screen.WorkingArea.Width / 2;
            }
        }

        if ($Top -eq $true) {

            $Height = $Screen.WorkingArea.Height / 2;
        }
        else {
            if ($Bottom -eq $true) {

                $Height = $Screen.WorkingArea.Height / 2;
                $Y = $Screen.WorkingArea.Y + $Screen.WorkingArea.Height / 2;
            }
        }
    }

    Process {

        function refocusTab($browser, $CurrentUrl) {

            # '-Foreground' parameter supplied'?
            if ($Foreground -ne $true) {

                # Get handle to current foreground window
                $CurrentActiveWindow = [GenXdev.Helpers.WindowObj]::GetFocusedWindow();

                # Is it different then the one at the start of this command?
                if ($PreviousActiveWindow.Handle -ne $CurrentActiveWindow.Handle) {

                    # restore it
                    $PreviousActiveWindow.SetForeground();

                    # wait
                    [System.Threading.Thread]::Sleep(250);

                    # did it not work?
                    $CurrentActiveWindow = [GenXdev.Helpers.WindowObj]::GetFocusedWindow();
                    if ($PreviousActiveWindow.Handle -ne $CurrentActiveWindow.Handle) {

                        try {
                            # Send Alt-Tab
                            $helper = New-Object -ComObject WScript.Shell;
                            $helper.sendKeys("%{TAB}");

                            # wait
                            [System.Threading.Thread]::Sleep(500);
                        }
                        catch {

                        }
                    }
                }

                #  positioning of windows did happen?
                if ($HavePositioning -eq $true) {

                    # wait a little
                    [System.Threading.Thread]::Sleep(500);
                }
            }
            else {

                # wait a little
                [System.Threading.Thread]::Sleep(500);
            }
        }

        function constructArgumentList($browser, $CurrentUrl) {

            ########################################################################
            if ($browser.Name -like "*Firefox*") {

                # set default commandline parameters
                $ArgumentList = $ArgumentList + @("-width", $Width, "-height", $Height)

                # '-Foreground' parameter supplied'?
                if ($Foreground -eq $true) {

                    # set commandline argument
                    $ArgumentList = $ArgumentList + @("-foreground")
                }

                # '-Private' parameter supplied'?
                if ($Private -eq $true) {

                    # set commandline arguments
                    $ArgumentList = $ArgumentList + @("-private", "-private-window", $CurrentUrl)
                }
                else {

                    # '-NoNewWindow' parameter supplied'?
                    if ($NoNewWindow -ne $true) {

                        # set commandline argument
                        $ArgumentList = $ArgumentList + @("--new-window", $CurrentUrl)
                    }
                    else {

                        # set commandline argument
                        $ArgumentList = $ArgumentList + @("-url", $CurrentUrl)
                    }
                }
            }
            else {
                ########################################################################
                if ($browser.Name -like "*Edge*" -or $browser.Name -like "*Chrome*") {

                    # set default commandline parameters
                    $ArgumentList = $ArgumentList + @(
                        "--no-default-browser-check",
                        "--remote-debugging-port=$port",
                        "--window-size=$Width,$Height"
                    )

                    # '-Private' parameter supplied'?
                    if ($Private -eq $true) {

                        # force new window
                        $NoNewWindow = $false;

                        # set commandline argument
                        $ArgumentList = $ArgumentList + @("--incognito")
                    }

                    # '-NoNewWindow' parameter supplied'?
                    if ($NoNewWindow -ne $true) {

                        # set commandline argument
                        $ArgumentList = $ArgumentList + @("--new-window")
                    }

                    # '-Fullscreen' parameter supplied'?
                    if ($FullScreen -eq $true) {

                        # prevent manual F11 insertion
                        $FullScreen = $false;

                        # set commandline argument
                        $ArgumentList = $ArgumentList + @("--start-fullscreen")
                    }

                    # Add Url to commandline arguments
                    $ArgumentList = $ArgumentList + @($CurrentUrl)
                }
                else {
                    ########################################################################
                    # Default browser
                    if ($Private -eq $true) {

                        return;
                    }

                    # Add Url to commandline arguments
                    $ArgumentList = @($CurrentUrl);
                }
            }
        }

        function open($browser, $CurrentUrl) {
            try {
                ########################################################################
                # get the browser dependend argument list
                constructArgumentList $browser $CurrentUrl

                # setup process start info
                $si = New-Object "System.Diagnostics.ProcessStartInfo"
                $si.FileName = $browser.Path
                $si.CreateNoWindow = $true;
                $si.UseShellExecute = $false;
                $si.WindowStyle = "Normal"
                foreach ($arg in $ArgumentList) { $si.ArgumentList.Add($arg); }

                # log
                Write-Verbose "$($browser.Name) --> $($SI.ArgumentList | ConvertTo-Json)"

                # start process
                $process = [System.Diagnostics.Process]::Start($si)

                ########################################################################
                # nothing to do anymore? then don't waste time on positioning the window
                if ($HavePositioning -eq $false) {

                    return;
                }

                ########################################################################
                # allow the browser to start-up, and update process handle if needed
                Start-Sleep 2

                # did it only signal an already existing webbrowser instance, to create a new tab,
                # and did it then exit?
                if ($process.HasExited) {

                    # find the process
                    $process = @(Get-Process |
                        Where-Object -Property Path -EQ $browser.Path |
                        Where-Object -Property MainWindowHandle -NE 0 |
                        Sort-Object { $PSItem.StartTime } -Descending |
                        Select-Object -First 1)

                    # not found?
                    if (($process.Length -eq 0) -or ($null -eq $process[0])) {

                        $window = @()
                    }
                    else {

                        # get window helper utility for the mainwindow of the process
                        $process = $process[0];
                        $window = [GenXdev.Helpers.WindowObj]::GetMainWindow($process)
                    }
                }
                else {

                    # get window helper utility for the mainwindow of the process
                    $window = [GenXdev.Helpers.WindowObj]::GetMainWindow($process)
                }

                ########################################################################
                # have a handle to the mainwindow of the browser?
                if ($window.Length -eq 1) {

                    # if maximized, restore window style
                    $window[0].Show() | Out-Null

                    # move it to it's place
                    $window[0].Move($X, $Y, $Width, $Height)  | Out-Null

                    # wait
                    [System.Threading.Thread]::Sleep(1500);

                    # do again
                    $window[0].Show()  | Out-Null
                    $window[0].Move($X, $Y, $Width, $Height) | Out-Null

                    # needs to be set fullscreen manually?
                    if ($FullScreen -eq $true) {

                        # do some magic to make it the foreground window
                        $window[0].SetForeground() | Out-Null
                        $window[0].Move($X, $Y, $Width, $Height) | Out-Null

                        # did it not work?
                        $test = [GenXdev.Helpers.WindowObj]::GetFocusedWindow();
                        if ($test.Handle -ne $process.MainWindowHandle) {

                            try {
                                # send alt-tab
                                $helper = New-Object -ComObject WScript.Shell;
                                $helper.sendKeys("%{TAB}");
                            }
                            catch {

                            }

                            # wait
                            Start-Sleep 1
                        }

                        # is the browserwindow now focused?
                        $test = [GenXdev.Helpers.WindowObj]::GetFocusedWindow();
                        if ($test.Handle -eq $process.MainWindowHandle) {

                            try {
                                # send F11
                                $helper = New-Object -ComObject WScript.Shell;
                                $helper.sendKeys("{F11}");
                            }
                            catch {

                            }
                        }
                    }
                    else {

                        # not fullscreen, but webbrowser needs to be in foreground?
                        if ($Foreground -eq $true) {

                            # do some magic
                            $window[0].SetForeground() | Out-Null
                            $test = [GenXdev.Helpers.WindowObj]::GetFocusedWindow();

                            # did it not work?
                            if ($test.Handle -ne $process.MainWindowHandle) {

                                # send alt-tab
                                try {
                                    $helper = New-Object -ComObject WScript.Shell;
                                    $helper.sendKeys("%{TAB}");
                                }
                                catch {

                                }
                            }
                        }
                    }
                }

            }
            finally {

                # if needed, restore the focus to the Powershell terminal
                refocusTab $browser $CurrentUrl
            }
        }

        ###############################################################################################
        # start processing the Urls that we need to open
        $Url | ForEach-Object {

            # reference the next Url
            $CurrentUrl = $PSItem;

            # '-All' parameter was supplied?
            if ($All -eq $true) {

                # open for all browsers
                $Browsers | ForEach-Object { open $PSItem $CurrentUrl }

                return;
            }

            # '-Chromium' parameter was supplied
            if ($Chromium -eq $true) {

                # default browser already chrome or edge?
                if (($DefaultBrowser.Name -like "*Chrome*") -or ($DefaultBrowser.Name -like "*Edge*")) {

                    # open default browser
                    open $DefaultBrowser $CurrentUrl
                    return;
                }

                # enumerate all browsers
                $Browsers | Sort-Object { $PSItem.Name } -Descending | ForEach-Object {

                    # found edge or chrome?
                    if (($PSItem.Name -like "*Chrome*") -or ($PSItem.Name -like "*Edge*")) {

                        # open it
                        open $PSItem $CurrentUrl
                    }
                }
            }
            else {

                # '-Chrome' parameter supplied?
                if ($Chrome -eq $true) {

                    # enumerate all browsers
                    $Browsers | ForEach-Object {

                        # found chrome?
                        if ($PSItem.Name -like "*Chrome*") {

                            # open it
                            open $PSItem $CurrentUrl
                        }
                    }
                }

                # '-Edge' parameter supplied?
                if ($Edge -eq $true) {

                    # enumerate all browsers
                    $Browsers | ForEach-Object {

                        # found Edge?
                        if ($PSItem.Name -like "*Edge*") {

                            # open it
                            open $PSItem $CurrentUrl
                        }
                    }
                }
            }

            # '-Firefox' parameter supplied?
            if ($Firefox -eq $true) {

                # enumerate all browsers
                $Browsers | ForEach-Object {

                    # found Firefox?
                    if ($PSItem.Name -like "*Firefox*") {

                        # open it
                        open $PSItem $CurrentUrl
                    }
                }
            }

            # no specific browser requested?
            if (($Chromium -ne $true) -and ($Chrome -ne $true) -and ($Edge -ne $true) -and ($Firefox -ne $true)) {

                # open default browser
                open $DefaultBrowser $CurrentUrl
            }
        }
    }
}

######################################################################################################################################################
######################################################################################################################################################

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
        ####################################################################################################
        [Alias("e")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Closes Microsoft Edge"
        )]
        [switch] $Edge,
        ####################################################################################################
        [Alias("ch")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Closes Google Chrome"
        )]
        [switch] $Chrome,
        ####################################################################################################
        [Alias("c")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Closes Microsoft Edge or Google Chrome, depending on what the default browser is"
        )]
        [switch] $Chromium,
        ####################################################################################################
        [Alias("ff")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Closes Firefox"
        )]
        [switch] $Firefox,
        ####################################################################################################
        [Alias("a")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Closes all registered modern browsers"
        )]
        [switch] $All,
        ####################################################################################################
        [Alias("bg", "Force")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Closes all instances of the webbrowser, including background tasks and services"
        )]
        [switch] $IncludeBackgroundProcesses
    )

    # get a list of all available/installed modern webbrowsers
    $Browsers = Get-Webbrowser

    # get the configured default webbrowser
    $DefaultBrowser = Get-DefaultWebbrowser

    function close($browser) {

        # find all running processes of this browser
        Get-Process -Name ([IO.Path]::GetFileNameWithoutExtension($browser.Path)) -ErrorAction SilentlyContinue | ForEach-Object {

            # reference next process
            $P = $PSItem;

            # '-IncludeBackgroundProcesses' parameter supplied?
            if ($IncludeBackgroundProcesses -ne $true) {

                # this browser process has no main window?
                if ($PSItem.MainWindowHandle -eq 0) {

                    # continue to next process
                    return;
                }

                # get handle to main window
                [GenXdev.Helpers.WindowObj]::GetMainWindow($PSItem) | ForEach-Object -ErrorAction SilentlyContinue {

                    $startTime = [DateTime]::UtcNow;
                    # send a WM_Close message
                    $PSItem.Close() | Out-Null;

                    do {

                        # wait a little
                        [System.Threading.Thread]::Sleep(20);

                    } while (!$p.HasExited -and [datetime]::UtcNow - $startTime -lt [timespan]::FromSeconds(4))

                    if ($P.HasExited) {

                        return;
                    }
                }
            }

            try {
                $PSItem.Kill();
            }
            catch {
                [GenXdev.Helpers.WindowObj]::GetMainWindow($PSItem) | ForEach-Object -ErrorAction SilentlyContinue {

                    $PSItem.Close();
                }
            }
        }
    }

    # '-All' parameter was supplied?
    if ($All -eq $true) {

        # enumerate all browsers
        $Browsers | ForEach-Object {

            close($PSItem)
        }

        return;
    }

    # '-Chromium' parameter was supplied
    if ($Chromium -eq $true) {

        # default browser already chrome or edge?
        if (($DefaultBrowser.Name -like "*Chrome*") -or ($DefaultBrowser.Name -like "*Edge*")) {

            close($DefaultBrowser);
            return;
        }

        # enumerate all browsers
        $Browsers | Sort-Object { $PSItem.Name } -Descending | ForEach-Object {

            if (($PSItem.Name -like "*Chrome*") -or ($PSItem.Name -like "*Edge*")) {

                close($PSItem);
                return;
            }
        }
    }

    # '-Chrome' parameter supplied?
    if ($Chrome -eq $true) {

        # enumerate all browsers
        $Browsers | ForEach-Object {

            # found Chrome?
            if ($PSItem.Name -like "*Chrome*") {

                close($PSItem);
                return;
            }
        }
    }

    # '-Edge' parameter supplied?
    if ($Edge -eq $true) {

        # enumerate all browsers
        $Browsers | ForEach-Object {

            # found Edge?
            if ($PSItem.Name -like "*Edge*") {

                close($PSItem);
                return;
            }
        }
    }

    # '-Firefox' parameter supplied?
    if ($Firefox -eq $true) {

        # enumerate all browsers
        $Browsers | ForEach-Object {

            # found Firefox?
            if ($PSItem.Name -like "*Firefox*") {

                close($PSItem);
                return;
            }
        }
    }

    # no specific browser requested?
    if (($Chromium -ne $true) -and ($Chrome -ne $true) -and ($Edge -ne $true) -and ($Firefox -ne $true)) {

        # open default browser
        close($DefaultBrowser);
    }
}
##############################################################################################################
##############################################################################################################
<#
.SYNOPSIS
Selects a webbrowser tab

.DESCRIPTION
Selects a webbrowser tab for use by the cmdlets 'Invoke-WebbrowserEvaluation -> et, eval', 'Close-WebbrowserTab -> ct' and others

.PARAMETER id
When '-Id' is not supplied, a list of available webbrowser tabs is shown, where the right value can be found

.PARAMETER Edge
Force to use 'Microsoft Edge' webbrowser for selection

.PARAMETER Chrome
Force to use 'Google Chrome' webbrowser for selection

.EXAMPLE
PS C:\> Select-WebbrowserTab
PS C:\> Select-WebbrowserTab 3
PS C:\> Select-WebbrowserTab -Chrome 14
PS C:\> st -ch 14

.NOTES
Requires the Windows 10+ Operating System
#>
function Select-WebbrowserTab {
    [CmdletBinding()]
    [Alias("st", "Select-BrowserTab")]

    param (
        ####################################################################################################
        [parameter(Mandatory = $false)]
        [ValidateRange(0, [int]::MaxValue)]
        [int] $id = -1,
        ####################################################################################################
        [Alias("c", "create")]
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $false)]
        [switch] $New,
        ####################################################################################################
        [Alias("e")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Select in Microsoft Edge"
        )]
        [switch] $Edge,
        ####################################################################################################
        [Alias("ch")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Select in Google Chrome"
        )]
        [switch] $Chrome
    )

    if ($Global:Data -isnot [HashTable]) {

        $Global:Data = @{};
    }

    # init
    if ($Edge -eq $true) {

        $port = Get-EdgeRemoteDebuggingPort

        if (!(Test-Connection -TcpPort $port 127.0.0.1 -TimeoutSeconds 1)) {

            Start-Webbrowser -Edge -FullScreen

            Start-Sleep 2
        }
    }
    else {
        if ($Chrome -eq $true) {

            $port = Get-ChromeRemoteDebuggingPort

            if (!(Test-Connection -TcpPort $port 127.0.0.1 -TimeoutSeconds 1)) {

                Start-Webbrowser -Chrome -FullScreen

                Start-Sleep 2
            }
        }
        else {

            $port = Get-ChromiumRemoteDebuggingPort

            if (!(Test-Connection -TcpPort $port 127.0.0.1 -TimeoutSeconds 1)) {

                Start-Webbrowser -Chromium -FullScreen

                Start-Sleep 2
            }
        }
    }

    # get paths
    $Global:WorkspaceFolder = ([IO.Path]::GetFullPath($PSScriptRoot + "\.."));

    Push-Location
    Set-Location $Global:WorkspaceFolder

    try {
        function showList() {
            "+ Use 'Select-WebbrowserTab -> st, Invoke-WebbrowserEvaluation -> et' cmdLet to inspect webbrowser tab session, 'Select-WebbrowserTab -> st' cmdLet to select a new session`r`n`r`n`$Global:Data synchronizes with javascript 'data' object`r`n" | Out-Host

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

        if ($Global:chrome -isnot [GenXdev.Webbrowser.Chrome] -or $Global:chrome.Port -ne $port) {

            Write-Verbose "Creating new chromium automation object"
            $c = New-Object "GenXdev.Webbrowser.Chrome" @("http://localhost:$port")
            Set-Variable -Name chrome -Value $c -Scope Global
        }

        Set-Variable -Name CurrentChromiumDebugPort -Value $Port -Scope Global

        if ($id -lt 0) {

            Write-Verbose "No ID parameter specified"
            try {
                $s = $Global:chrome.GetAvailableSessions();
            }
            Catch {
                if ($Global:Host.Name.Contains("Visual Studio")) {

                    "Webbrowser has not been opened yet, press F5 to start debugging first.." | Out-Host
                }
                else {
                    "Webbrowser has not been opened yet, use Start-Webbrowser --> wb to start a browser with debugging enabled.." | Out-Host
                }
                return;
            }

            Set-Variable -Name chromeSessions -Value $s -Scope Global
            Write-Verbose "Sessions set, length= $($Global:chromeSessions.count)"

            $id = 0;
            while (($s[$id].url.startsWith("chrome-extension:") -or $s[$id].url.contains("/offline/")) -and ($id -lt ($s.count - 1))) {

                Write-Verbose "skipping $($s[$id].url)"

                $id = $id + 1;
            }

            $Global:chrome.SetActiveSession($s[$id].webSocketDebuggerUrl);
            Set-Variable -Name chromeSession -Value $s[$id] -Scope Global
            Write-Verbose "Session set: $($Global:chromeSession)"
        }
        else {
            "$($id)" | Write-Verbose

            $s = $Global:chromeSessions;

            if ($id -ge $s.count) {
                $s = $Global:chrome.GetAvailableSessions();
                Set-Variable -Name chromeSessions -Value $s -Scope Global
                Write-Verbose "Sessions set, length= $($Global:chromeSessions.count)"

                showList

                throw "Session expired, select new session with cmdlet: Select-WebbrowserTab --> st"
            }

            $Global:chrome.SetActiveSession($s[$id].webSocketDebuggerUrl);
            Set-Variable -Name chromeSession -Value $s[$id] -Scope Global

            $s = $Global:chrome.GetAvailableSessions();
            Set-Variable -Name chromeSessions -Value $s -Scope Global
            Write-Verbose "Sessions set, length= $($Global:chromeSessions.count)"

            $wsb = $Global:chromeSession.webSocketDebuggerUrl;
            $found = $false;

            $s | ForEach-Object -Process {
                if ($_.webSocketDebuggerUrl -eq $wsb) {
                    $found = $true;
                    Set-Variable -Name chromeSession -Value $_ -Scope Global
                }
            }

            if ($found -eq $false) {
                showList

                throw "Session expired, select new session with cmdlet: Select-WebbrowserTab --> st"
            }
        }

        showList
    }
    Finally {

        Pop-Location
    }
}
######################################################################################################################################################
######################################################################################################################################################
<#
.SYNOPSIS
Runs one or more scripts inside a selected webbrowser tab.

.DESCRIPTION
Runs one or more scripts inside a selected webbrowser tab.
You can access 'data' object from within javascript, to synchronize data between Powershell and the Webbrowser.

.PARAMETER scripts
A string containing the javascript, or a file reference to a javascript file

.PARAMETER inspect
Will cause the developer tools of the webbrowser to break, before executing the scripts, allowing you to debug it.

.PARAMETER Edge
Will use the previous selected Microsoft Edge session

.PARAMETER Chrome
Will use the previous selected Microsoft Chrome session

.EXAMPLE
PS C:\> Invoke-WebbrowserEvaluation "document.title = 'hello world'"

PS C:\>

    # Synchronizing data
    Select-WebbrowserTab;
    $Global:Data = @{ files= (Get-ChildItem *.* -file | % FullName)};
    [int] $number = Invoke-WebbrowserEvaluation "document.body.innerHTML = JSON.stringify(data.files); data.title = document.title; 123;";
    Write-Host "
        Document title : $($Global:Data.title)
        return value   : $Number
    ";

PS C:\> Get-ChildItem *.js | Invoke-WebbrowserEvaluation -Edge
PS C:\> ls *.js | et -e


.NOTES
Requires the Windows 10+ Operating System
#>
function Invoke-WebbrowserEvaluation {
    [CmdletBinding()]
    [Alias("Eval", "et")]

    param(
        ####################################################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)
        ]
        [Alias('FullName')]
        [object[]] $scripts,
        ####################################################################################################
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $false)
        ]
        [switch] $inspect,
        ####################################################################################################
        [Alias("e")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Select in Microsoft Edge"
        )]
        [switch] $Edge,
        ####################################################################################################
        [Alias("ch")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Select in Google Chrome"
        )]
        [switch] $Chrome
    )

    Begin {

        # setup switches for info messages
        $Switches = "";
        $SwitchesShort = "";

        if ($Edge -eq $true) {

            $Switches = "-Edge"
            $SwitchesShort = "-e";
        }
        if ($Chrome -eq $true) {

            $Switches = "-Chrome"
            $SwitchesShort = "-c";
        }

        # initialize data hashtable
        if ($Global:Data -isnot [HashTable]) {

            $Global:Data = @{};
        }

        # no session yet?
        if ($Global:chromeSession -isnot [GenXdev.Webbrowser.RemoteSessionsResponse]) {

            throw "Select session first with cmdlet: Select-WebbrowserTab $switches -> st $switchesShort"
        }
        else {

            Write-Verbose "Found existing session: $($Global.chromeSession | ConvertTo-Json -Depth 100)"
        }

        # get available tabs
        $s = $Global:chrome.GetAvailableSessions();

        # reference selected session
        $wsb = $Global:chromeSession.webSocketDebuggerUrl;

        # find it in the most recent list
        $found = $false;
        $s | ForEach-Object -Process {

            if ($_.webSocketDebuggerUrl -eq $wsb) {

                $found = $true;
            }
        }

        # not found?
        if ($found -eq $false) {

            throw "Session expired, select new session with cmdlet: Select-WebbrowserTab $switches -> st $switchesShort"
        }
        else {

            Write-Verbose "Session still active"
        }
    }

    Process {

        Write-Verbose "Processing.."

        # enumerate provided scripts
        foreach ($js in $scripts) {

            # is it a file reference?
            if (($js -is [IO.FileInfo]) -or (($js -is [System.String]) -and [IO.File]::Exists($js))) {

                # comming from Get-ChildItem command?
                if ($js -is [IO.FileInfo]) {

                    # make it a string
                    $js = $js.FullName;
                }

                # it's a string with a path, load the content
                $js = [IO.File]::ReadAllText($js, [System.Text.Encoding]::UTF8)
            }
            else {

                # make it a string, if it isn't yet
                if ($js -isnot [System.String]) {

                    $js = "$js";
                }
            }

            # '-Inspect' parameter provided?
            if ($inspect -eq $true) {

                # invoke a debug break-point
                $js = "debugger;`r`n$js"
            }

            Write-Verbose "Processing: $($js | ConvertTo-Json -Compress -Depth 100)"

            # convert data object to json, and then again to make it a json string
            $json = ($Global:Data | ConvertTo-Json -Compress -Depth 100 | ConvertTo-Json -Compress -Depth 100);

            # init result
            $result = $null;

            Try {

                $js = "
            (function(data) {

            var returnValue;
            var success = true;

            try {
                returnValue = eval($($js | ConvertTo-Json -Compress -Depth 100));
            }
            catch(e) {
                success = false;
                returnValue = e+'';
            }
            var result = {
                data: data,
                success: success,
                returnValue: returnValue
            };

            return result;

            })(JSON.parse($json));
        ";

                Write-Verbose "Starting eval"

                # de-serialize outputed result object
                $result = ($Global:chrome.eval($js) | ConvertFrom-Json).result;

                Write-Verbose "Got results: $($result | ConvertTo-Json -Compress -Depth 100)"

                # all good?
                if ($result -is [Object]) {

                    # get actual returned value
                    $result = $result.result.value;

                    # present?
                    if ($result -is [Object]) {

                        Write-Verbose "`$result -is [Object]"

                        # there was an exception thrown?
                        if ($result.exceptionDetails) {

                            # re-throw
                            throw $result.exceptionDetails;
                        }

                        # got a data object?
                        if ($result.data -is [PSObject]) {

                            # initialize
                            $Global:Data = @{}

                            # enumerate properties
                            $result.data |
                            Get-Member -ErrorAction SilentlyContinue |
                            Where-Object -Property MemberType -Like *Property* |
                            ForEach-Object -ErrorAction SilentlyContinue {

                                # set in a case-sensitive manner
                                $Global:Data."$($PSItem.Name)" = $result.data."$($PSItem.Name)"
                            }
                        }

                        # result indicate an exception thrown?
                        if ($result.success -eq $false) {

                            # re-throw
                            throw $result.returnValue;
                        }

                        # return value
                        $result = $result.returnValue;
                    }
                }
            }
            Catch {
                Write-Error $_

                $result = $null
            }

            Write-Output $result;
        }
    }

    End {

    }
}

##############################################################################################################
##############################################################################################################
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
    [CmdletBinding()]
    [Alias("ct", "CloseTab")]

    param (
        [parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateRange(0, [int]::MaxValue)]
        [int] $id
    )

    Invoke-WebbrowserEvaluation "window.close()"
}

##############################################################################################################
##############################################################################################################

<#
.SYNOPSIS
Performs a  google search in previously selected webbrowser tab and returns the links

.DESCRIPTION
Performs a  google search in previously selected webbrowser tab and returns the links

.PARAMETER Query
The google query to perform

.EXAMPLE
PS C:\> Select-WebbrowserTab; $Urls = Get-AllGoogleLinks "site:github.com Powershell module"; $Urls

.NOTES
Requires the Windows 10+ Operating System
#>
function Get-AllGoogleLinks {

    [CmdletBinding()]
    [Alias("qlinks")]

    param(
        [parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromRemainingArguments = $true
        )]
        [string] $Query
    )

    $Global:data = @{

        urls  = @();
        query = $Query
    }

    $Query = "$([Uri]::EscapeUriString($Query))"
    $Url = "https://www.google.com/search?q=$Query"

    Invoke-WebbrowserEvaluation "document.location.href='$Url'" | Out-Null

    do {
        Start-Sleep 5 | Out-Null

        Invoke-WebbrowserEvaluation -scripts @("$PSScriptRoot\GetAllGoogleLinks.js") | Out-Null

        $Global:data.urls | ForEach-Object -ErrorAction SilentlyContinue { $_ }
    }

    while ($Global:data.more)
}

##############################################################################################################
##############################################################################################################

<#
.SYNOPSIS
Performs an infinite auto opening google search in previously selected webbrowser tab.

.DESCRIPTION
Performs a google search in previously selected webbrowser tab.
Opens 10 tabs each times, pauses until initial tab is revisited
Press ctrl-c to stop, or close the initial tab

.PARAMETER Query
The google query to perform

.EXAMPLE
PS C:\> Select-WebbrowserTab; Open-AllGoogleLinks "site:github.com Powershell module"

.NOTES
Requires the Windows 10+ Operating System
#>
function Open-AllGoogleLinks {

    [CmdletBinding()]
    [Alias("qlinks")]

    param(
        [parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromRemainingArguments = $true
        )]
        [string] $Query
    )

    $Global:data = @{

        urls  = @();
        query = $Query
    }

    $Query = "$([Uri]::EscapeUriString($Query))"
    $Url = "https://www.google.com/search?q=$Query"

    Invoke-WebbrowserEvaluation "document.location.href='$Url'" | Out-Null

    do {
        Start-Sleep 5 | Out-Null

        Invoke-WebbrowserEvaluation -scripts @("$PSScriptRoot\OpenAllGoogleLinks.js") | Out-Null
    }
    while ($Global:data.more)
}

##############################################################################################################
##############################################################################################################
<#
.SYNOPSIS
Performs a google query in the previously selected webbrowser tab, and download all found pdf's into current directory

.DESCRIPTION
Performs a google query in the previously selected webbrowser tab, and download all found pdf's into current directory

.PARAMETER Query
Parameter description

.EXAMPLE
PS D:\Downloads> mkdir pdfs; cd pdfs; Select-WebbrowserTab; DownloadPDFS "scientific paper co2"

.NOTES
Requires the Windows 10+ Operating System
#>
function DownloadPDFs {

    [CmdletBinding()]

    param(
        [parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromRemainingArguments = $true
        )]
        [string] $Query
    )

    GetAllGoogleLinks "filetype:pdf $Query" |
    ForEach-Object -ThrottleLimit 64 -Parallel {

        try {

            $destination = [IO.Path]::Combine(
                $PWD,
                (
                    [IO.Path]::ChangeExtension(
                        [Uri]::UnescapeDataString(
                            [IO.Path]::GetFileName($_).Split("#")[0].Split("?")[0]
                        ).Replace("\", "_").Replace("/", "_").Replace("?", "_").Replace("*", "_").Replace(" ", "_").Replace("__", "_"),
                        ".pdf"
                    )
                )
            );

            Invoke-WebRequest -Uri $_ -OutFile $destination

            "Success: $_"
        }
        catch {

            "Failed: $_"
        }
    }
}

##############################################################################################################
##############################################################################################################
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

##############################################################################################################
##############################################################################################################
<#
.SYNOPSIS
Updates all browser shortcuts for current user, to enable the remote debugging port by default

.DESCRIPTION
Updates all browser shortcuts for current user, to enable the remote debugging port by default

.NOTES
Requires the Windows 10+ Operating System
#>
function Set-RemoteDebuggerPortInBrowserShortcuts {

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
    $param = " --remote-debugging-port=$port";
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
    $param = " --remote-debugging-port=$port";
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
                $shortcut.Arguments = $shortcut.Arguments.replace("222", "").Trim();
                $shortcut.Arguments = $shortcut.Arguments.replace("223", "").Trim();
                $shortcut.Arguments = "$(removePreviousParam $shortcut.Arguments) $param".Trim()

                $shortcut.Save();
            }
            catch {

                Write-Verbose $PSItem
            }
        }
    }
}
##############################################################################################################
function Get-ChromeRemoteDebuggingPort {
    [CmdletBinding()]

    [int] $Port = 0;

    if (![int]::TryParse("$Global:ChromeDebugPort", [ref] $port)) {

        $Port = 9222;
    }

    Set-Variable -Name ChromeDebugPort -Value $Port -Scope Global

    return $Port;
}
##############################################################################################################
function Get-EdgeRemoteDebuggingPort {
    [CmdletBinding()]

    [int] $Port = 0;

    if (![int]::TryParse($Global:EdgeDebugPort, [ref] $port)) {

        $Port = 9223;
    }

    Set-Variable -Name EdgeDebugPort -Value $Port -Scope Global

    return $Port;
}
##############################################################################################################
function Get-ChromeRemoteDebuggingPort {
    [CmdletBinding()]

    [int] $Port = 0;

    if (![int]::TryParse($Global:ChromeDebugPort, [ref] $port)) {

        $Port = 9222;
    }

    Set-Variable -Name ChromeDebugPort -Value $Port -Scope Global
    return $Port;
}
##############################################################################################################
function Get-ChromiumRemoteDebuggingPort {
    [CmdletBinding()]

    $DefaultBrowser = Get-DefaultWebbrowser;

    if (($null -eq $DefaultBrowser) -or ($DefaultBrowser.Name -like "*Edge*")) {

        Get-EdgeRemoteDebuggingPort;
        return;
    }

    Get-ChromeRemoteDebuggingPort;
}

##############################################################################################################
##############################################################################################################
