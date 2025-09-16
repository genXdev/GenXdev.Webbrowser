<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser
Original cmdlet filename  : Show-WebsiteInAllBrowsers.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.268.2025
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
################################################################################
<#
.SYNOPSIS
Opens a URL in multiple browsers simultaneously in a mosaic layout.

.DESCRIPTION
This function creates a mosaic layout of browser windows by opening the specified
URL in Chrome, Edge, Firefox, and a private browsing window. The browsers are
arranged in a 2x2 grid pattern:
- Chrome: Top-left quadrant
- Edge: Bottom-left quadrant
- Firefox: Top-right quadrant
- Private window: Bottom-right quadrant

All parameters from Open-Webbrowser are supported and passed through to control
browser positioning, behavior, and appearance. The function acts as a wrapper
that applies consistent quadrant positioning while allowing full customization
of browser launch parameters.

.PARAMETER Url
The URLs to open in all browsers. Accepts pipeline input and can be specified by
position or through properties.

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

.PARAMETER FullScreen
Opens the browser in fullscreen mode using F11 key simulation.

.PARAMETER Private
Opens the browser in private/incognito browsing mode. Uses InPrivate for
Edge and incognito for Chrome. Not supported for the default browser mode.

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

.PARAMETER ApplicationMode
Hides browser controls for a distraction-free experience. Creates an app-like
interface for web applications.

.PARAMETER NoBrowserExtensions
Prevents loading of browser extensions. Uses safe mode for Firefox and
--disable-extensions for Chromium browsers.

.PARAMETER DisablePopupBlocker
Disables the browser's popup blocking functionality.

.PARAMETER RestoreFocus
Returns focus to the PowerShell window after opening the browser. Useful
for automated workflows where you want to continue working in PowerShell.

.PARAMETER NewWindow
Forces creation of a new browser window instead of reusing existing windows.

.PARAMETER FocusWindow
Gives focus to the browser window after opening.

.PARAMETER SetForeground
Brings the browser window to the foreground after opening.

.PARAMETER Maximize
Maximizes the browser window after positioning.

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

.EXAMPLE
Show-WebsiteInAllBrowsers -Url "https://www.github.com"
Opens github.com in four different browsers arranged in a mosaic layout.

.EXAMPLE
"https://www.github.com" | Show-UrlInAllBrowsers
Uses the function's alias and pipeline input to achieve the same result.
#>
################################################################################
function Show-WebsiteInAllBrowsers {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]

    param(
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The URLs to open in all browsers simultaneously'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Value', 'Uri', 'FullName', 'Website', 'WebsiteUrl')]
        [string] $Url,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('The monitor to use, 0 = default, -1 is discard, ' +
                '-2 = Configured secondary monitor, defaults to ' +
                "`$Global:DefaultSecondaryMonitor or 2 if not found")
        )]
        [Alias('m', 'mon')]
        [int] $Monitor,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial width of the webbrowser window'
        )]
        [int] $Width,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial height of the webbrowser window'
        )]
        [int] $Height,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial X position of the webbrowser window'
        )]
        [int] $X,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial Y position of the webbrowser window'
        )]
        [int] $Y,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the browser accept-lang http header'
        )]
        [Alias('lang', 'locale')]
        [string] $AcceptLang,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in fullscreen mode'
        )]
        [Alias('fs', 'f')]
        [switch] $FullScreen,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in incognito/private browsing mode'
        )]
        [Alias('incognito', 'inprivate')]
        [switch] $Private,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Force enable debugging port, stopping existing ' +
                'browsers if needed')
        )]
        [switch] $Force,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in Microsoft Edge'
        )]
        [Alias('e')]
        [switch] $Edge,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in Google Chrome'
        )]
        [Alias('ch')]
        [switch] $Chrome,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Opens in Microsoft Edge or Google Chrome, ' +
                'depending on what the default browser is')
        )]
        [Alias('c')]
        [switch] $Chromium,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in Firefox'
        )]
        [Alias('ff')]
        [switch] $Firefox,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in all registered modern browsers'
        )]
        [switch] $All,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the left side of the screen'
        )]
        [switch] $Left,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the right side of the screen'
        )]
        [switch] $Right,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the top side of the screen'
        )]
        [switch] $Top,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the bottom side of the screen'
        )]
        [switch] $Bottom,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window in the center of the screen'
        )]
        [switch] $Centered,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hide the browser controls'
        )]
        [Alias('a', 'app', 'appmode')]
        [switch] $ApplicationMode,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Prevent loading of browser extensions'
        )]
        [Alias('de', 'ne', 'NoExtensions')]
        [switch] $NoBrowserExtensions,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable the popup blocker'
        )]
        [Alias('allowpopups')]
        [switch] $DisablePopupBlocker,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore PowerShell window focus'
        )]
        [Alias('rf', 'bg')]
        [switch] $RestoreFocus,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Don't re-use existing browser window, instead, " +
                'create a new one')
        )]
        [Alias('nw', 'new')]
        [switch] $NewWindow,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the browser window after opening'
        )]
        [Alias('fw', 'focus')]
        [switch] $FocusWindow,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the browser window to foreground after opening'
        )]
        [Alias('fg')]
        [switch] $SetForeground,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximize the window after positioning'
        )]
        [switch] $Maximize,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Keystrokes to send to the Browser window, ' +
                'see documentation for cmdlet GenXdev.Windows\Send-Key')
        )]
        [string[]] $KeysToSend,
        ###############################################################################
        [Alias('Escape')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Escape control characters when sending keys'
        )]
        [switch] $SendKeyEscape,
        ###############################################################################
        [Alias('HoldKeyboardFocus')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Prevent returning keyboard focus to PowerShell ' +
                'after sending keys')
        )]
        [switch] $SendKeyHoldKeyboardFocus,
        ###############################################################################
        [Alias('UseShiftEnter')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Send Shift+Enter instead of regular Enter for ' +
                'line breaks')
        )]
        [switch] $SendKeyUseShiftEnter,
        ###############################################################################
        [Alias('DelayMilliSeconds')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Delay between sending different key sequences ' +
                'in milliseconds')
        )]
        [int] $SendKeyDelayMilliSeconds,
        ########################################################################
        [Parameter(
            HelpMessage = 'Removes the borders of the browser window.'
        )]
        [Alias('nb')]
        [switch] $NoBorders,

        ########################################################################
        [Parameter(
            HelpMessage = 'Position browser window either fullscreen on different monitor than PowerShell, or side by side with PowerShell on the same monitor.'
        )]
        [Alias('sbs')]
        [switch] $SideBySide,

        ########################################################################
        [Parameter(
            HelpMessage = 'Use alternative settings stored in session for AI preferences.'
        )]
        [switch] $SessionOnly,

        ########################################################################
        [Parameter(
            HelpMessage = 'Clear alternative settings stored in session for AI preferences.'
        )]
        [switch] $ClearSession,

        ########################################################################
        [Parameter(
            HelpMessage = 'Store settings only in persistent preferences without affecting session.'
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession

        ########################################################################
    )

    begin {

        # log the start of the operation with the target url
        Microsoft.PowerShell.Utility\Write-Verbose ('Starting browser mosaic ' +
            "layout for URL: $Url")
    }

    process {

        # copy identical parameters between functions
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -FunctionName 'GenXdev.Webbrowser\Open-Webbrowser' `
            -BoundParameters $PSBoundParameters `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

        GenXdev.Webbrowser\Open-Webbrowser @params

        # initialize chrome in the top-left quadrant of the screen
        Microsoft.PowerShell.Utility\Write-Verbose ('Launching Chrome in ' +
            'top-left quadrant')

        $null = GenXdev.Webbrowser\Open-Webbrowser @params `
            -Chrome -Left -Top -Url $Url

        # initialize edge in the bottom-left quadrant of the screen
        Microsoft.PowerShell.Utility\Write-Verbose ('Launching Edge in ' +
            'bottom-left quadrant')

        $null = GenXdev.Webbrowser\Open-Webbrowser @params `
            -Edge -Left -Bottom -Url $Url

        # initialize firefox in the top-right quadrant of the screen
        Microsoft.PowerShell.Utility\Write-Verbose ('Launching Firefox in ' +
            'top-right quadrant')

        $null = GenXdev.Webbrowser\Open-Webbrowser @params `
            -Firefox -Right -Top -Url $Url

        # initialize private window in the bottom-right quadrant of the screen
        Microsoft.PowerShell.Utility\Write-Verbose ('Launching Private window ' +
            'in bottom-right quadrant')

        $null = GenXdev.Webbrowser\Open-Webbrowser @params `
            -Private -Right -Bottom -Url $Url
    }

    end {
    }
}
################################################################################