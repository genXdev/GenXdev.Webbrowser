<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser
Original cmdlet filename  : Open-Webbrowser.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.296.2025
################################################################################
MIT License

Copyright 2021-2025 GenXdev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
################################################################################>
###############################################################################
<#
.SYNOPSIS
Opens URLs in one or more browser windows with optional positioning and styling.

.DESCRIPTION
This function provides an advanced wrapper around browser launching with
extensive options for window positioning, browser selection, and behavior
customization. It supports multiple browsers including Edge, Chrome, and
Firefox with features like private browsing, application mode, and precise
window management.

Key features:
- Smart browser detection and selection
- Window positioning (left, right, top, bottom, centered, fullscreen)
- Multi-monitor support with automatic or manual monitor selection
- Private/incognito browsing mode support
- Application mode for distraction-free browsing
- Extension and popup blocking options
- Focus management and window manipulation
- Batch URL opening across multiple browsers
- Keystroke automation to browser windows

The function can automatically detect system capabilities and adjust behavior
accordingly. For browsers not installed on the system, operations are silently
skipped without errors.

.PARAMETER Url
The URLs to open in the browser. Accepts pipeline input and automatically
handles file paths (converts to file:// URLs). When no URL is provided,
opens the default GenXdev PowerShell help page.

.PARAMETER Monitor
The monitor to use for window placement:
- 0 = Primary monitor
- -1 = Discard positioning
- -2 = Configured secondary monitor (uses $Global:DefaultSecondaryMonitor or
  defaults to monitor 2)
- 1+ = Specific monitor number

.PARAMETER Width
The initial width of the browser window in pixels. When not specified,
uses the monitor's working area width or half-width for side positioning.

.PARAMETER Height
The initial height of the browser window in pixels. When not specified,
uses the monitor's working area height or half-height for top/bottom
positioning.

.PARAMETER X
The initial X coordinate for window placement. When not specified, uses
the monitor's left edge. Can be specified relative to the selected monitor.

.PARAMETER Y
The initial Y coordinate for window placement. When not specified, uses
the monitor's top edge. Can be specified relative to the selected monitor.

.PARAMETER AcceptLang
Sets the browser's Accept-Language HTTP header for internationalization.
Useful for testing websites in different languages.

.PARAMETER Force
Forces enabling of the debugging port by stopping existing browser instances
if needed. Useful when browser debugging features are required.

.PARAMETER Edge
Specifically opens URLs in Microsoft Edge browser.

.PARAMETER Chrome
Specifically opens URLs in Google Chrome browser.

.PARAMETER Chromium
Opens URLs in either Microsoft Edge or Google Chrome, depending on which
is set as the default browser. Prefers Chromium-based browsers.

.PARAMETER Firefox
Specifically opens URLs in Mozilla Firefox browser.

.PARAMETER All
Opens the specified URLs in all installed modern browsers simultaneously.

.PARAMETER Left
Positions the browser window on the left half of the screen.

.PARAMETER Right
Positions the browser window on the right half of the screen.

.PARAMETER Top
Positions the browser window on the top half of the screen.

.PARAMETER Bottom
Positions the browser window on the bottom half of the screen.

.PARAMETER Centered
Centers the browser window on the screen using 80% of the screen dimensions.

.PARAMETER FullScreen
Opens the browser in fullscreen mode using F11 key simulation.

.PARAMETER Private
Opens the browser in private/incognito browsing mode. Uses InPrivate for
Edge and incognito for Chrome. Not supported for the default browser mode.

.PARAMETER ApplicationMode
Hides browser controls for a distraction-free experience. Creates an app-like
interface for web applications.

.PARAMETER NoBrowserExtensions
Prevents loading of browser extensions. Uses safe mode for Firefox and
--disable-extensions for Chromium browsers.

.PARAMETER DisablePopupBlocker
Disables the browser's popup blocking functionality.

.PARAMETER NewWindow
Forces creation of a new browser window instead of reusing existing windows.

.PARAMETER FocusWindow
Gives focus to the browser window after opening.

.PARAMETER SetForeground
Brings the browser window to the foreground after opening.

.PARAMETER Maximize
Maximize the window after positioning

.PARAMETER SetRestored
Restore the window to normal state after positioning

.PARAMETER PassThru
Returns PowerShell objects representing the browser processes created.

.PARAMETER NoBorders
Removes the borders of the browser window.

.PARAMETER RestoreFocus
Returns focus to the PowerShell window after opening the browser. Useful
for automated workflows where you want to continue working in PowerShell.

.PARAMETER SideBySide
Position browser window either fullscreen on different monitor than PowerShell,
or side by side with PowerShell on the same monitor.

.PARAMETER KeysToSend
Keystrokes to send to the browser window after opening. Uses the same
format as the GenXdev.Windows\Send-Key cmdlet.

.PARAMETER SendKeyEscape
Escapes control characters when sending keystrokes to the browser.

.PARAMETER SendKeyHoldKeyboardFocus
Prevents returning keyboard focus to PowerShell after sending keystrokes.

.PARAMETER SendKeyUseShiftEnter
Uses Shift+Enter instead of regular Enter for line breaks when sending keys.

.PARAMETER SendKeyDelayMilliSeconds
Delay between sending different key sequences in milliseconds.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.EXAMPLE
Open-Webbrowser -Url "https://github.com"

Opens GitHub in the default browser.

.EXAMPLE
Open-Webbrowser -Url "https://stackoverflow.com" -Monitor 1 -Left

Opens Stack Overflow in the left half of monitor 1.

.EXAMPLE
wb "https://google.com" -m 0 -fs

Opens Google in fullscreen mode on the primary monitor using aliases.

.EXAMPLE
Open-Webbrowser -Chrome -Private -NewWindow

Opens a new Chrome window in incognito mode.

.EXAMPLE
"https://github.com", "https://stackoverflow.com" | Open-Webbrowser -All

Opens multiple URLs in all installed browsers via pipeline.

.EXAMPLE
Open-Webbrowser -Monitor 0 -Right

Re-positions an already open browser window to the right side of the primary
monitor.

.EXAMPLE
Open-Webbrowser -ApplicationMode -Url "https://app.example.com"

Opens a web application in app mode without browser controls.

.NOTES
Requires Windows 10+ Operating System.

This cmdlet is designed for interactive use and performs window manipulation
tricks including Alt-Tab keystrokes. Avoid touching keyboard/mouse during
positioning operations.

For fast launches of multiple URLs:
- Set Monitor to -1
- Avoid using positioning switches (-X, -Y, -Left, -Right, -Top, -Bottom,
  -RestoreFocus)

For browsers not installed on the system, operations are silently skipped.
#>
###############################################################################
function Open-Webbrowser {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Alias('wb')]

    param(
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromPipeline = $false,
            HelpMessage = 'The URLs to open in the browser'
        )]
        [string[]] $Url,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The URLs to open in the browser'
        )]
        [Alias('Value', 'Uri', 'FullName', 'Website', 'WebsiteUrl')]
        [string] $Input,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = ('The monitor to use, 0 = default, -1 is discard, ' +
                '-2 = Configured secondary monitor, defaults to ' +
                "`$Global:DefaultSecondaryMonitor or 2 if not found")
        )]
        [Alias('m', 'mon')]
        [int] $Monitor = -2,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial width of the webbrowser window'
        )]
        [int] $Width = -1,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial height of the webbrowser window'
        )]
        [int] $Height = -1,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial X position of the webbrowser window'
        )]
        [int] $X = -999999,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial Y position of the webbrowser window'
        )]
        [int] $Y = -999999,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the browser accept-lang http header'
        )]
        [Alias('lang', 'locale')]
        [string] $AcceptLang = $null,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Force enable debugging port, stopping existing ' +
                'browsers if needed')
        )]
        [switch] $Force,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in Microsoft Edge'
        )]
        [Alias('e')]
        [switch] $Edge,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in Google Chrome'
        )]
        [Alias('ch')]
        [switch] $Chrome,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Opens in Microsoft Edge or Google Chrome, ' +
                'depending on what the default browser is')
        )]
        [Alias('c')]
        [switch] $Chromium,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in Firefox'
        )]
        [Alias('ff')]
        [switch] $Firefox,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in all registered modern browsers'
        )]
        [switch] $All,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the left side of the screen'
        )]
        [switch] $Left,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the right side of the screen'
        )]
        [switch] $Right,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the top side of the screen'
        )]
        [switch] $Top,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the bottom side of the screen'
        )]
        [switch] $Bottom,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window in the center of the screen'
        )]
        [switch] $Centered,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in fullscreen mode'
        )]
        [Alias('fs', 'f')]
        [switch] $FullScreen,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in incognito/private browsing mode'
        )]
        [Alias('incognito', 'inprivate')]
        [switch] $Private,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hide the browser controls'
        )]
        [Alias('a', 'app', 'appmode')]
        [switch] $ApplicationMode,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Prevent loading of browser extensions'
        )]
        [Alias('de', 'ne', 'NoExtensions')]
        [switch] $NoBrowserExtensions,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable the popup blocker'
        )]
        [Alias('allowpopups')]
        [switch] $DisablePopupBlocker,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Don't re-use existing browser window, instead, " +
                'create a new one')
        )]
        [Alias('nw', 'new')]
        [switch] $NewWindow,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the browser window after opening'
        )]
        [Alias('fw','focus')]
        [switch] $FocusWindow,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the browser window to foreground after opening'
        )]
        [Alias('fg')]
        [switch] $SetForeground,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximize the window after positioning'
        )]
        [switch] $Maximize,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore the window to normal state after positioning'
        )]
        [switch] $SetRestored,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Returns a PowerShell object of ' +
                'the browserprocess')
        )]
        [Alias('pt')]
        [switch]$PassThru,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Removes the borders of the window'
        )]
        [Alias('nb')]
        [switch] $NoBorders,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore PowerShell window focus'
        )]
        [Alias('rf', 'bg')]
        [switch] $RestoreFocus,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Position browser window either fullscreen on ' +
                'different monitor than PowerShell, or side by side with ' +
                'PowerShell on the same monitor')
        )]
        [Alias('sbs')]
        [switch] $SideBySide,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Keystrokes to send to the Window, ' +
                'see documentation for cmdlet GenXdev.Windows\Send-Key')
        )]
        [string[]] $KeysToSend,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Escape control characters and modifiers when ' +
                'sending keys')
        )]
        [Alias('Escape')]
        [switch] $SendKeyEscape,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Hold keyboard focus on target window when ' +
                'sending keys')
        )]
        [Alias('HoldKeyboardFocus')]
        [switch] $SendKeyHoldKeyboardFocus,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use Shift+Enter instead of Enter when ' +
                'sending keys')
        )]
        [Alias('UseShiftEnter')]
        [switch] $SendKeyUseShiftEnter,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Delay between different input strings in ' +
                'milliseconds when sending keys')
        )]
        [Alias('DelayMilliSeconds')]
        [int] $SendKeyDelayMilliSeconds,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for AI ' +
                'preferences')
        )]
        [switch] $SessionOnly,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for ' +
                'AI preferences')
        )]
        [switch] $ClearSession,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Store settings only in persistent preferences ' +
                'without affecting session')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        #######################################################################
    )

    begin {

        if ($null -eq $Url) {

            $Url = @()
        }

        [System.Collections.Generic.List[string]] $UrlList = @($Url)

        # force new window creation if keystrokes need to be sent to browser
        if ($KeysToSend -and ($KeysToSend.Count -gt 0)) {

            $NewWindow = $true
        }

        # store original parameters for later use in key sending operations
        $wbParams = $PSBoundParameters

        # get all available screens/monitors on the system
        $allScreens = @([WpfScreenHelper.Screen]::AllScreens |
                Microsoft.PowerShell.Core\ForEach-Object {

                    $PSItem
                })

        # output diagnostic information about the function call
        Microsoft.PowerShell.Utility\Write-Verbose ("Open-Webbrowser " +
            "monitor = $Monitor, urls=$($UrlList |Microsoft.PowerShell.Utility\ConvertTo-Json)")

        # track if url parameter was explicitly provided by user
        [bool] $urlSpecified = $true

        # check if no url was specified by the user
        if (($null -eq $UrlList) -or ($UrlList.Length -lt 1)) {

            $urlSpecified = $false

            # show the default help page from github when no url provided
            $UrlList = @('https://powershell.genxdev.net/')
        }
        else {

            # process and normalize each url provided
            $UrlList = $($UrlList |
                    Microsoft.PowerShell.Core\ForEach-Object {

                        # clean up url by trimming quotes and spaces
                        $newUrl = $PSItem.Trim(' "'''.ToCharArray())
                        $filePath = $newUrl

                        try {

                            # try to expand the path in case it's a relative file path
                            $filePath = (GenXdev.FileSystem\Expand-Path $newUrl)
                        }
                        catch {

                            # ignore expansion errors for urls that aren't file paths
                        }

                        # check if the url refers to an existing local file
                        if ([System.IO.File]::Exists($filePath)) {

                            # convert local file path to file:// url format
                            $newUrl = ('file://' +
                                [Uri]::EscapeUriString($filePath.Replace('\', '/')))
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
                Microsoft.PowerShell.Core\ForEach-Object {

                    $PSItem
                });

        Microsoft.PowerShell.Utility\Write-Verbose ("Found $($allScreens.Count) " +
            "monitors available for window positioning")

        # copy window positioning parameters for later use
        $wpparams = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $wbParams `
            -FunctionName 'GenXdev.Windows\Set-WindowPosition'

        Microsoft.PowerShell.Utility\Write-Verbose ("Window positioning " +
            "parameters copied: $($wpparams.Keys -join ', ')")

        # set default positioning behavior when no positioning parameters provided
        if ($wpparams.Keys.Count -eq 0 -and -not $SideBySide) {

            Microsoft.PowerShell.Utility\Write-Verbose ("No window positioning " +
                "parameters provided, using defaults: SetForeground=true, " +
                "RestoreFocus=true, Maximize=$($Monitor -ne -1)")
            $SetForeground = $true
            $wpparams.SetForeground = $true
            $RestoreFocus = $true
            $wpparams.RestoreFocus = $true
            $Maximize = $Monitor -ne -1
            $wpparams.Maximize = $Maximize
        }
        else {
            Microsoft.PowerShell.Utility\Write-Verbose ("Window positioning " +
                "parameters provided, using user settings")
        }

        # determine if side-by-side positioning should be forced
        [int] $setDefaultMonitor = $Global:DefaultSecondaryMonitor -is [int] ?
            (
                $Global:DefaultSecondaryMonitor
            ):
            2;

        # determine if side-by-side mode should be forced due to monitor limitations
        $ForcedSideBySide = ($Monitor -eq -2) -and (
          ($allScreens.Count -lt 2)  -or
               (-not ($setDefaultMonitor -is [int] -and ($setDefaultMonitor -gt 0)))
        )

        if ($ForcedSideBySide) {

            Microsoft.PowerShell.Utility\Write-Verbose ("Forcing side-by-side " +
                "positioning: insufficient monitors ($($allScreens.Count)) or " +
                "invalid DefaultSecondaryMonitor " +
                "($setDefaultMonitor)")
        }

        # configure side-by-side positioning if requested or forced
        if ($SideBySide -or $ForcedSideBySide) {

            Microsoft.PowerShell.Utility\Write-Verbose ("Configuring " +
                "side-by-side positioning - PowerShell monitor: " +
                "$($powerShellWindow.GetCurrentMonitor()), " +
                "Browser monitor: $($powerShellWindow.GetCurrentMonitor() + 1)")

            $SideBySide = $true
            $wpparams.SideBySide = $true
            $Monitor = $powerShellWindow.GetCurrentMonitor() + 1
            $wpparams.Monitor = $Monitor
            $RestoreFocus = $true
            $wpparams.RestoreFocus = $true
            $Maximize = $false
            $wpparams.Maximize = $false
            $FullScreen = $false
            $wpparams.FullScreen = $false

            if ($KeysToSend.Count -eq 1 -and $KeysToSend[0] -in @('f', '{F11}')) {
                $KeysToSend = @()
                if ($wpparams.ContainsKey('KeysToSend')) {
                    $null = $wpparams.Remove('KeysToSend')
                }
            }
        }

        # determine which monitor to use based on monitor parameter
        if ($Monitor -eq 0) {

            Microsoft.PowerShell.Utility\Write-Verbose ('Choosing primary ' +
                'monitor, because default monitor requested using -Monitor 0')
            Microsoft.PowerShell.Utility\Write-Verbose ("Primary monitor " +
                "working area: $($screen.WorkingArea.Width)x" +
                "$($screen.WorkingArea.Height) at " +
                "($($screen.WorkingArea.X),$($screen.WorkingArea.Y))")
        }
        else {

            # check if secondary monitor was requested and global variable is set
            if ((-not $SideBySide) -and $Monitor -eq -2 -and $setDefaultMonitor -is [int] -and
                $setDefaultMonitor -ge 0) {

                $selectedIndex = ($setDefaultMonitor - 1) % $allScreens.Length
                Microsoft.PowerShell.Utility\Write-Verbose ('Picking monitor ' +
                    "$selectedIndex as secondary (requested with -monitor -2) " +
                    "set by `$setDefaultMonitor=" +
                    "$setDefaultMonitor")
                $screen = $allScreens[$selectedIndex]
                Microsoft.PowerShell.Utility\Write-Verbose ("Selected monitor " +
                    "working area: $($screen.WorkingArea.Width)x" +
                    "$($screen.WorkingArea.Height) at " +
                    "($($screen.WorkingArea.X),$($screen.WorkingArea.Y))")
            }
            elseif ((-not $SideBySide) -and $Monitor -eq -2 -and
                (-not ($setDefaultMonitor -is [int] -and
                    $setDefaultMonitor -ge 0)) -and
                ((GenXdev.Windows\Get-MonitorCount) -gt 1)) {

                Microsoft.PowerShell.Utility\Write-Verbose (('Picking monitor ' +
                        '#1 as default secondary (requested with -monitor -2), ' +
                        "because `$setDefaultMonitor not set"))
                $screen = $allScreens[1]
                Microsoft.PowerShell.Utility\Write-Verbose ("Secondary monitor " +
                    "working area: $($screen.WorkingArea.Width)x" +
                    "$($screen.WorkingArea.Height) at " +
                    "($($screen.WorkingArea.X),$($screen.WorkingArea.Y))")
            }
            # check if specific monitor number was requested
            elseif ((-not $SideBySide) -and $Monitor -ge 1) {

                $selectedIndex = ($Monitor - 1) % $allScreens.Length
                Microsoft.PowerShell.Utility\Write-Verbose ('Picking monitor ' +
                    "#$selectedIndex as requested by the -Monitor parameter " +
                    "($Monitor)")
                $screen = $allScreens[$selectedIndex]
                Microsoft.PowerShell.Utility\Write-Verbose ("Requested monitor " +
                    "working area: $($screen.WorkingArea.Width)x" +
                    "$($screen.WorkingArea.Height) at " +
                    "($($screen.WorkingArea.X),$($screen.WorkingArea.Y))")
            }
            else {
                try {
                    Microsoft.PowerShell.Utility\Write-Verbose ('Picking monitor ' +
                        '#1 (same as PowerShell), because no monitor specified')
                    $screen = [WpfScreenHelper.Screen]::FromPoint(@{
                            X = $powerShellWindow[0].Position().X
                            Y = $powerShellWindow[0].Position().Y
                        })
                    if ($SideBySide) {

                        $Monitor = [WpfScreenHelper.Screen]::AllScreens.indexOf($screen) + 1
                        Microsoft.PowerShell.Utility\Write-Verbose ("Side-by-side " +
                            "mode: adjusted Monitor to $Monitor")
                    }
                    Microsoft.PowerShell.Utility\Write-Verbose ("PowerShell " +
                        "monitor working area: $($screen.WorkingArea.Width)x" +
                        "$($screen.WorkingArea.Height) at " +
                        "($($screen.WorkingArea.X),$($screen.WorkingArea.Y))")
                }
                catch {
                    $screen = [WpfScreenHelper.Screen]::PrimaryScreen
                    Microsoft.PowerShell.Utility\Write-Verbose ("Failed to detect " +
                        "PowerShell monitor, using primary monitor")
                }
            }
        }

        # determine if any window positioning parameters were provided
        [bool] $havePositioning = (($Monitor -ge 0 -or $Monitor -eq -2) -or
            ($Left -or $Right -or $Top -or $Bottom -or $Centered -or $SideBySide -or $Maximize -or $FullScreen -or
                (($X -is [int]) -and ($X -gt -999999)) -or
                (($Y -is [int]) -and ($Y -gt -999999))))

        Microsoft.PowerShell.Utility\Write-Verbose ("Window positioning " +
            "required: $havePositioning (Monitor=$Monitor, Left=$Left, " +
            "Right=$Right, Top=$Top, Bottom=$Bottom, Centered=$Centered, " +
            "SideBySide=$SideBySide, Maximize=$Maximize, FullScreen=$FullScreen, " +
            "X=$X, Y=$Y)")

        # initialize window x position based on parameters or screen defaults
        if (($X -le -999999) -or ($X -isnot [int])) {

            $X = $screen.WorkingArea.X
            Microsoft.PowerShell.Utility\Write-Verbose ("Using default X " +
                "position: $X (screen working area left)")
        }
        else {

            # adjust x position relative to selected monitor if monitor specified
            if ($Monitor -ge 0) {

                $originalX = $X
                $X = $screen.WorkingArea.X + $X
                Microsoft.PowerShell.Utility\Write-Verbose ("Adjusted X " +
                    "position from $originalX to $X (relative to monitor)")
            }
            else {
                Microsoft.PowerShell.Utility\Write-Verbose ("Using absolute X " +
                    "position: $X")
            }
        }

        # initialize window y position based on parameters or screen defaults
        if (($Y -le -999999) -or ($Y -isnot [int])) {

            $Y = $screen.WorkingArea.Y
            Microsoft.PowerShell.Utility\Write-Verbose ("Using default Y " +
                "position: $Y (screen working area top)")
        }
        else {

            # adjust y position relative to selected monitor if monitor specified
            if ($Monitor -ge 0) {

                $originalY = $Y
                $Y = $screen.WorkingArea.Y + $Y
                Microsoft.PowerShell.Utility\Write-Verbose ("Adjusted Y " +
                    "position from $originalY to $Y (relative to monitor)")
            }
            else {
                Microsoft.PowerShell.Utility\Write-Verbose ("Using absolute Y " +
                    "position: $Y")
            }
        }

        # create state object to track browser window positioning and processes
        $state = @{
            existingWindow    = $false
            hadVisibleBrowser = $false
            Browser           = $null
            IsDefaultBrowser  = ((-not $All) -and
                ((-not $Chromium) -or ($defaultBrowser.Name -like '*chrome*') -or
                    ($defaultBrowser.Name -like '*edge*')) -and
                ((-not $Chrome) -or ($defaultBrowser.Name -like '*chrome*')) -and
                ((-not $Edge) -or ($defaultBrowser.Name -like '*edge*')) -and
                ((-not $Firefox) -or ($defaultBrowser.Name -like '*firefox*')))
            FirstProcess      = $null
            PositioningDone   = $false
            BrowserWindow     = $null
        }

        # determine if we can use simple start-process instead of complex positioning
        $useStartProcess = (-not ($havePositioning -or $FullScreen)) -and
        $state.IsDefaultBrowser -and ($Monitor -eq -1) -and (-not $NewWindow)

        # configure window dimensions and positioning if positioning is required
        if ($havePositioning -or $FullScreen) {

            Microsoft.PowerShell.Utility\Write-Verbose ("Configuring window " +
                "positioning - initial dimensions: ${Width}x${Height}")

            # check if width parameter was explicitly provided
            $widthProvided = ($Width -gt 0) -and ($Width -is [int])

            # check if height parameter was explicitly provided
            $heightProvided = ($Height -gt 0) -and ($Height -is [int])

            Microsoft.PowerShell.Utility\Write-Verbose ("Width provided by " +
                "user: $widthProvided, Height provided by user: $heightProvided")

            # set default width if not provided by user
            if ($widthProvided -eq $false) {

                $Width = $screen.WorkingArea.Width
                Microsoft.PowerShell.Utility\Write-Verbose ("Using default " +
                    "width: $Width (full screen working area)")
            }

            # set default height if not provided by user
            if ($heightProvided -eq $false) {

                $Height = $screen.WorkingArea.Height
                Microsoft.PowerShell.Utility\Write-Verbose ("Using default " +
                    "height: $Height (full screen working area)")
            }

            # configure window position and size for left side placement
            if ($Left -eq $true) {

                Microsoft.PowerShell.Utility\Write-Verbose ("Configuring LEFT " +
                    "side positioning")
                $X = $screen.WorkingArea.X

                # use half screen width if width not explicitly provided
                if ($widthProvided -eq $false) {

                    $Width = [Math]::Min($screen.WorkingArea.Width / 2, $Width)
                    Microsoft.PowerShell.Utility\Write-Verbose ("Left side: " +
                        "using half width: $Width")
                }

                # use full screen height if height not explicitly provided
                if ($heightProvided -eq $false) {

                    $Height = [Math]::Min($screen.WorkingArea.Height, $Height)
                    Microsoft.PowerShell.Utility\Write-Verbose ("Left side: " +
                        "using full height: $Height")
                }
                $Y = $screen.WorkingArea.Y
                Microsoft.PowerShell.Utility\Write-Verbose ("Left side final " +
                    "position: ${Width}x${Height} at ($X,$Y)")
            }

            # configure window position and size for right side placement
            if ($Right -eq $true) {

                # use half screen width if width not explicitly provided
                if ($widthProvided -eq $false) {

                    $Width = [Math]::Min($screen.WorkingArea.Width / 2, $Width)
                }

                # use full screen height if height not explicitly provided
                if ($heightProvided -eq $false) {

                    $Height = [Math]::Min($screen.WorkingArea.Height, $Height)
                }

                # position window on right side of screen
                $X = $screen.WorkingArea.X + $screen.WorkingArea.Width - $Width
                $Y = $screen.WorkingArea.Y
            }

            # configure window position and size for top placement
            if ($Top -eq $true) {

                $Y = $screen.WorkingArea.Y

                # use half screen height if height not explicitly provided
                if ($heightProvided -eq $false) {

                    $Height = [Math]::Min($screen.WorkingArea.Height / 2, $Height)
                }

                $Width = $screen.WorkingArea.Width
                $X = $screen.WorkingArea.X
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
            }
        }
    }

    ########################################################################
    process {

        if ([string]::IsNullOrEmpty($Input)) { return }

        $null = $UrlList.Add($_)
    }

    ########################################################################
    end {

        $Url = $UrlList.ToArray() | Microsoft.PowerShell.Utility\Select-Object -Unique

        #######################################################################
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

                    Microsoft.PowerShell.Utility\Start-Sleep -Milliseconds 200
                }
            }
        }

        #######################################################################
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

            #############################################################

            # handle firefox-specific command line arguments
            if ($browser.Name -like '*Firefox*') {

                # set default firefox command line parameters
                $argumentList = @()

                # add window size parameters if both width and height specified
                if (($Width -is [int]) -and ($Width -gt 0) -and
                    ($Height -is [int]) -and ($Height -gt 0)) {

                    $argumentList = $argumentList + @('-width', $Width,
                        '-height', $Height)
                }

                # set foreground mode unless restore focus is requested
                if ($RestoreFocus -ne $true) {

                    # set firefox to foreground on startup
                    $argumentList = $argumentList + @('-foreground')
                }

                # disable browser extensions if requested
                if ($NoBrowserExtensions -eq $true) {

                    $argumentList = $argumentList + @('-safe-mode')
                }

                # disable popup blocker if requested
                if ($DisablePopupBlocker -eq $true) {

                    $argumentList = $argumentList + @('-disable-popup-blocking')
                }

                # set accept language header if provided
                if ($null -ne $AcceptLang) {

                    $argumentList = $argumentList + @('--lang', $AcceptLang)
                }

                # handle private browsing mode for firefox
                if ($Private -eq $true) {

                    # open url in firefox private window
                    $argumentList = $argumentList + @('-private-window',
                        $currentUrl)
                }
                else {

                    # handle application mode for firefox
                    if ($ApplicationMode -eq $true) {

                        Microsoft.PowerShell.Utility\Write-Warning ('Firefox ' +
                            'does not support -ApplicationMode at this time')

                        GenXdev.Webbrowser\Approve-FirefoxDebugging

                        # use single site browser mode for firefox app mode
                        $argumentList = $argumentList + @('--ssb', $currentUrl)
                    }
                    else {

                        # handle new window creation for firefox
                        if ((-not $state.PositioningDone) -and
                            ($NewWindow -eq $true)) {

                            # create new firefox window with url
                            $argumentList = $argumentList + @('--new-window',
                                $currentUrl)
                        }
                        else {

                            # open url in existing or new firefox tab
                            $argumentList = $argumentList + @('-url', $currentUrl)
                        }
                    }
                }
            }
            else {

                ##########################################################

                # handle chromium-based browsers (edge and chrome)
                if ($browser.Name -like '*Edge*' -or
                    $browser.Name -like '*Chrome*') {

                    # get the appropriate debugging port for this browser type
                    $port = GenXdev.Webbrowser\Get-ChromiumRemoteDebuggingPort `
                        -Chrome:$Chrome -Edge:$Edge

                    # set default chromium command line parameters
                    # reference: https://peter.sh/experiments/chromium-command-line-switches/
                    $argumentList = $argumentList + @(
                        '--disable-infobars',
                        '--hide-crash-restore-bubble',
                        '--no-first-run',
                        '--disable-session-crashed-bubble',
                        '--disable-crash-reporter',
                        '--no-default-browser-check',
                        '--disable-restore-tabs',
                        '--remote-allow-origins=*',
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

                        $argumentList = $argumentList + @('--disable-extensions')
                    }

                    # disable popup blocker if requested
                    if ($DisablePopupBlocker -eq $true) {

                        $argumentList = $argumentList + @('--disable-popup-blocking')
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
                        if ($browser.Name -like '*Edge*') {

                            # use edge inprivate mode
                            $argumentList = $argumentList + @('-InPrivate')
                        }
                        else {

                            # use chrome incognito mode
                            $argumentList = $argumentList + @('--incognito')
                        }
                    }

                    # force new window creation if requested and not positioned yet
                    if ((-not $state.PositioningDone) -and ($NewWindow -eq $true)) {

                        # force creation of new browser window
                        $argumentList = $argumentList + @('--new-window') +
                        @('--force-launch-browser')
                    }

                    # set window to start maximized by default
                    $argumentList = $argumentList + @('--start-maximized')

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

                    ######################################################

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

        #######################################################################
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

                        Microsoft.PowerShell.Utility\Write-Verbose ('No process ' +
                            'found, retrying..')
                        $window = @()

                        $null = [System.Threading.Thread]::Sleep(80)
                    }
                    else {

                        Microsoft.PowerShell.Utility\Write-Verbose 'Found new process'

                        # get window helper utility for main window of process
                        $state.existingWindow = $state.hadVisibleBrowser
                        $process = $processesNew[0]
                        $window = [GenXdev.Helpers.WindowObj]::GetMainWindow($process,
                            1, 80)
                        break
                    }
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Verbose ('Error: ' +
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

        #######################################################################
        <#
        .SYNOPSIS
        Sends keystrokes to the browser window if specified.

        .DESCRIPTION
        Helper function to send keystrokes to the browser window after a delay
        to ensure the window is ready. Handles window handle detection and
        parameter copying for the Send-Key function.

        .PARAMETER window
        The browser window array to send keystrokes to.
        #>
        function sendKeysIfSpecified($window) {
            # send keys if specified, after a delay to ensure window is ready
            if ($null -ne $KeysToSend -and ($KeysToSend.Count -gt 0)) {
                Microsoft.PowerShell.Utility\Write-Verbose ('Sending keystrokes to browser window after 4 second delay')
                Microsoft.PowerShell.Utility\Start-Sleep 6

                # copy key sending parameters
                $invocationParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $wbParams `
                    -FunctionName 'GenXdev.Windows\Send-Key'

                if ($window.Length -eq 1) {
                    $invocationParams.WindowHandle = $window[0].Handle
                }

                $null = GenXdev.Windows\Send-Key @invocationParams -SendKeyHoldKeyboardFocus

                Microsoft.PowerShell.Utility\Start-Sleep 1
            }
        }

        #######################################################################
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

            Microsoft.PowerShell.Utility\Write-Verbose 'open()'

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

                Microsoft.PowerShell.Utility\Write-Verbose ('Found existing ' +
                    'webbrowser window')
                $state.hadVisibleBrowser = $true
            }

            # determine if we should skip launching new browser process
            if ((-not $NewWindow) -and
                (-not ($havePositioning -or $FullScreen)) -and
                (-not $urlSpecified)) {

                if ($state.hadVisibleBrowser) {

                    Microsoft.PowerShell.Utility\Write-Verbose ('No url specified, ' +
                        'found existing webbrowser window')
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

                        Microsoft.PowerShell.Utility\Write-Verbose ('No browser ' +
                            'with open debugger port found, closing all browser ' +
                            'instances and starting a new one')
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
                $null = $process.WaitForExit(2000)
            }

            # validate that we have a valid process
            if ($null -eq $process) {

                Microsoft.PowerShell.Utility\Write-Warning ('Could not start ' +
                    "browser $($browser.Name)")
                return
            }

            # skip positioning if not needed or already done
            if ((-not $PassThru) -and
                ((-not ($havePositioning -or ($FullScreen -and
                  -not $state.PositioningDone))) -or $state.PositioningDone)) {

                sendKeysIfSpecified $window

                Microsoft.PowerShell.Utility\Write-Verbose ('No positioning ' +
                    'required, done..')
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

                    Microsoft.PowerShell.Utility\Write-Verbose ('Returning ' +
                        'first process')
                    Microsoft.PowerShell.Utility\Write-Output $state.FirstProcess
                    return
                }

                # return current process if valid and has window
                if (($null -ne $process) -and (-not $process.HasExited) -and
                    ($process.MainWindowHandle -ne 0)) {

                    Microsoft.PowerShell.Utility\Write-Verbose 'Returning process'
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

                Microsoft.PowerShell.Utility\Write-Verbose ('Returning process ' +
                    'after process lookup')
                Microsoft.PowerShell.Utility\Write-Output $process
            }

            # skip positioning if not required or already completed
            if ((-not ($havePositioning -or ($FullScreen -and
                 (-not $state.PositioningDone)))) -or $state.PositioningDone) {
                sendKeysIfSpecified $window

                Microsoft.PowerShell.Utility\Write-Verbose ('No positioning ' +
                    'required, done..')
                return
            }

            # mark positioning as completed and store first process
            $state.PositioningDone = $true
            $state.FirstProcess = $process

            # position browser window if we have a valid window handle
            if ($window.Length -eq 1) {
                if ($wpparams.ContainsKey('KeysToSend')) {
                    $null = $wpparams.Remove('KeysToSend')
                }
                $null = GenXdev.Windows\Set-WindowPosition @wpparams `
                    -WindowHelper:$window[0]
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
                    Microsoft.PowerShell.Utility\Write-Verbose 'Start-Process'

                    # launch default browser with simple start-process method
                    $process = Microsoft.PowerShell.Management\Start-Process $currentUrl `
                        -PassThru

                    # return process if passthru requested for first launch
                    if ($PassThru -and $useStartProcess -and ($index -eq 0)) {

                        $browserFound = findProcess $defaultBrowser $process $state

                        $process = $browserFound.Process
                        $window = $browserFound.Window

                        Microsoft.PowerShell.Utility\Write-Verbose ('Returning ' +
                            'process after Start-Process')
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
                            if ($PSItem.Name -like '*Chrome*') {

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
                            if ($PSItem.Name -like '*Edge*') {

                                # open url in edge
                                open $PSItem $currentUrl $state
                            }
                        }
                }
                # handle chromium-based browser preference (edge or chrome)
                elseif ($Chromium -eq $true) {

                    # check if default browser is already chromium-based
                    if (($defaultBrowser.Name -like '*Chrome*') -or
                        ($defaultBrowser.Name -like '*Edge*')) {

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
                            if (($PSItem.Name -like '*Chrome*') -or
                                ($PSItem.Name -like '*Edge*')) {

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
                            if ($PSItem.Name -like '*Firefox*') {

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

                Microsoft.PowerShell.Utility\Write-Verbose 'Setting fullscreen'

                # use browser window reference if available
                if ($null -ne $state.BrowserWindow) {

                    Microsoft.PowerShell.Utility\Write-Verbose ('Changing focus ' +
                        'to browser window')

                    try {
                        $null = $state.BrowserWindow.Focus()
                        $null = $state.BrowserWindow.Maximize()
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

                        Microsoft.PowerShell.Utility\Write-Verbose ('have browser ' +
                            'window, sleeping 500ms')
                        $null = [System.Threading.Thread]::Sleep(500)

                        try {

                            $null = $state.BrowserWindow.Focus()
                            $null = $state.BrowserWindow.Maximize()
                        }
                        catch {
                            # ignore window manipulation errors
                        }
                        $null = GenXdev.Windows\Set-ForegroundWindow `
                        ($state.BrowserWindow.Handle)

                        $focusedWindowProcess = GenXdev.Windows\Get-CurrentFocusedProcess
                        if ($null -eq $focusedWindowProcess) { break }

                        if ($focusedWindowProcess.MainWindowHandle -ne $state.BrowserWindow.Handle) {

                            $null = [System.Threading.Thread]::Sleep(500)
                        }
                    }
                }
                else {
                    Microsoft.PowerShell.Utility\Write-Verbose ('Setting ' +
                        'fullscreen without having reference to browser window')
                    $tt = 0
                    $focusedWindowProcess = GenXdev.Windows\Get-CurrentFocusedProcess
                    $powershellWindow = GenXdev.Windows\Get-PowershellMainWindow

                    # wait for powershell window focus before sending f11
                    while (($tt++ -lt 20) -and
                        (($null -eq $focusedWindowProcess) -or
                            ($null -eq $powerShellWindow) -or
                            ($focusedWindowProcess.MainWindowHandle -ne
                        $powerShellWindow.Handle))) {
                        Microsoft.PowerShell.Utility\Write-Verbose ('no browser ' +
                            'window, sleeping 500ms')
                        $null = [System.Threading.Thread]::Sleep(500)

                        $focusedWindowProcess = GenXdev.Windows\Get-CurrentFocusedProcess

                        $powershellWindow = GenXdev.Windows\Get-PowershellMainWindow
                         if ($null -eq $focusedWindowProcess) { break }

                        if ($null -ne $powershellWindow -and $focusedWindowProcess.MainWindowHandle -ne $powerShellWindow.Handle) {

                            $null = [System.Threading.Thread]::Sleep(500)
                        }
                    }
                }
                $w = (GenXdev.Windows\Get-PowershellMainWindow);

                # send f11 key to activate fullscreen if browser has focus
                if ( ($w) -and ((GenXdev.Windows\Get-CurrentFocusedProcess).MainWindowHandle -ne
                        $w.Handle)) {
                    try {

                        # create com object to send f11 key press
                        $helper = Microsoft.PowerShell.Utility\New-Object `
                            -ComObject WScript.Shell
                        $null = $helper.sendKeys('{F11}')
                        Microsoft.PowerShell.Utility\Write-Verbose 'Sending F11'
                        $null = [System.Threading.Thread]::Sleep(500)
                    }
                    catch {
                        # ignore key sending errors
                    }
                }
            }
        }

        # restore powershell window focus if requested
        if ($RestoreFocus) {

            GenXdev.Windows\Set-WindowPosition -SetForeground
        }
    }
}
################################################################################