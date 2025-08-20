################################################################################
<#
.SYNOPSIS
Opens browser bookmarks that match specified search criteria.

.DESCRIPTION
Searches bookmarks across Microsoft Edge, Google Chrome, and Mozilla Firefox
browsers based on provided search queries. Opens matching bookmarks in the
selected browser with configurable window settings and browser modes.

This function provides a comprehensive interface for finding and opening
browser bookmarks with advanced filtering and display options. It supports
multiple search criteria and can open results in any installed browser with
extensive window positioning and behavior customization.

.PARAMETER Queries
Search terms used to filter bookmarks by title or URL.

.PARAMETER Count
Maximum number of bookmarks to open (default 50).

.PARAMETER Edge
Use Microsoft Edge browser bookmarks as search source.

.PARAMETER Chrome
Use Google Chrome browser bookmarks as search source.

.PARAMETER Firefox
Use Mozilla Firefox browser bookmarks as search source.

.PARAMETER Monitor
The monitor to use for window placement:
- 0 = Primary monitor
- -1 = Discard positioning
- -2 = Configured secondary monitor

.PARAMETER Private
Opens bookmarks in private/incognito browsing mode.

.PARAMETER Force
Forces enabling of debugging port, stops existing browser instances if needed.

.PARAMETER FullScreen
Opens browser windows in fullscreen mode.

.PARAMETER Width
Sets initial browser window width in pixels.

.PARAMETER Height
Sets initial browser window height in pixels.

.PARAMETER X
Sets initial browser window X position.

.PARAMETER Y
Sets initial browser window Y position.

.PARAMETER Left
Places browser window on left side of screen.

.PARAMETER Right
Places browser window on right side of screen.

.PARAMETER Top
Places browser window on top of screen.

.PARAMETER Bottom
Places browser window on bottom of screen.

.PARAMETER Centered
Centers browser window on screen.

.PARAMETER ApplicationMode
Hides browser controls for clean app-like experience.

.PARAMETER NoBrowserExtensions
Prevents loading of browser extensions.

.PARAMETER AcceptLang
Sets browser accept-language HTTP header.

.PARAMETER KeysToSend
Keystrokes to send to the Browser window.

.PARAMETER FocusWindow
Focus the browser window after opening.

.PARAMETER SetForeground
Set the browser window to foreground after opening.

.PARAMETER Maximize
Maximize the browser window after positioning.

.PARAMETER RestoreFocus
Restores PowerShell window focus after opening bookmarks.

.PARAMETER NewWindow
Creates new browser window instead of reusing existing one.

.PARAMETER Chromium
Opens in Microsoft Edge or Google Chrome, depending on what the default
browser is.

.PARAMETER All
Opens in all registered modern browsers.

.PARAMETER DisablePopupBlocker
Disables the browser's popup blocking functionality.

.PARAMETER SendKeyEscape
Escapes control characters when sending keystrokes to the browser.

.PARAMETER SendKeyHoldKeyboardFocus
Prevents returning keyboard focus to PowerShell after sending keystrokes.

.PARAMETER SendKeyUseShiftEnter
Uses Shift+Enter instead of regular Enter for line breaks when sending keys.

.PARAMETER SendKeyDelayMilliSeconds
Delay between sending different key sequences in milliseconds.

.EXAMPLE
Open-BrowserBookmarks -Queries "github" -Edge -Count 5

Searches for bookmarks containing "github" in Microsoft Edge and opens the
first 5 results in the default browser.

.EXAMPLE
sites gh -e -c 5

Same as above using aliases - searches Edge bookmarks for "gh" and opens 5
results in the default browser.

.EXAMPLE
Open-BrowserBookmarks -Queries "development", "tools" -Chrome -Firefox -Left -Count 10

Searches Chrome bookmarks for "development" and "tools", opens first 10
results in Firefox positioned on the left side of screen.
#>
################################################################################
function Open-BrowserBookmarks {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [Alias('sites')]

    param (
        #######################################################################
        [parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Search terms to filter bookmarks'
        )]
        [Alias('q', 'Name', 'Text', 'Query')]
        [string[]] $Queries,

        #######################################################################
        [parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'Maximum number of urls to open'
        )]
        [int] $Count = 50,
        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Select in Microsoft Edge'
        )]
        [Alias('e')]
        [switch] $Edge,
        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Select in Google Chrome'
        )]
        [Alias('ch')]
        [switch] $Chrome,
        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Select in Firefox'
        )]
        [Alias('ff')]
        [switch] $Firefox,
        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = ('The monitor to use, 0 = default, -1 is discard, ' +
                '-2 = Configured secondary monitor')
        )]
        [Alias('m', 'mon')]
        [int] $Monitor = -1,

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
            HelpMessage = ('Force enable debugging port, stopping existing ' +
                'browsers if needed')
        )]
        [switch] $Force,
        ###############################################################################
        [Alias('fs', 'f')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in fullscreen mode'
        )]
        [switch] $FullScreen,
        ###############################################################################
        [Alias('sw')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show the browser window (not minimized or hidden)'
        )]
        [switch] $ShowWindow,

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
        [Alias('a', 'app', 'appmode')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hide the browser controls'
        )]
        [switch] $ApplicationMode,

        #######################################################################
        [Alias('de', 'ne', 'NoExtensions')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Prevent loading of browser extensions'
        )]
        [switch] $NoBrowserExtensions,

        #######################################################################
        [Alias('lang', 'locale')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the browser accept-lang http header'
        )]
        [string] $AcceptLang = $null,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Keystrokes to send to the Browser window, ' +
                'see documentation for cmdlet GenXdev.Windows\Send-Key')
        )]
        [string[]] $KeysToSend,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the browser window after opening'
        )]
        [Alias('fw','focus')]
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

        #######################################################################

        ###############################################################################

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore PowerShell window focus'
        )]
        [Alias('rf', 'bg')]
        [switch] $RestoreFocus,

        #######################################################################
        [Alias('nw', 'new')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Don't re-use existing browser window, instead, " +
                'create a new one')
        )]
        [switch] $NewWindow,
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
            HelpMessage = 'Opens in all registered modern browsers'
        )]
        [switch] $All,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable the popup blocker'
        )]
        [Alias('allowpopups')]
        [switch] $DisablePopupBlocker,
        #######################################################################
        ###############################################################################
        [Alias('Escape')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Escape control characters when sending keys'
        )]
        [switch] $SendKeyEscape,
        #######################################################################
        ###############################################################################
        [Alias('HoldKeyboardFocus')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Prevent returning keyboard focus to PowerShell ' +
                'after sending keys')
        )]
        [switch] $SendKeyHoldKeyboardFocus,
        #######################################################################
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
        #######################################################################
        [Parameter(
            HelpMessage = 'Removes the borders of the browser window'
        )]
        [Alias('nb')]
        [switch] $NoBorders,

        #######################################################################
        [Parameter(
            HelpMessage = 'Position browser window either fullscreen on different monitor than PowerShell, or side by side with PowerShell on the same monitor.'
        )]
        [Alias('sbs')]
        [switch] $SideBySide,

        #######################################################################
        [Parameter(
            HelpMessage = 'Use alternative settings stored in session for AI preferences'
        )]
        [switch] $SessionOnly,

        #######################################################################
        [Parameter(
            HelpMessage = 'Clear alternative settings stored in session for AI preferences'
        )]
        [switch] $ClearSession,

        #######################################################################
        [Parameter(
            HelpMessage = 'Store settings only in persistent preferences without affecting session'
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        #######################################################################
    )

    begin {

        # log the initialization phase for bookmark search operations
        Microsoft.PowerShell.Utility\Write-Verbose ('Initializing browser ' +
            'parameters for bookmark search...')

        # copy identical parameters between functions for passing to open-webbrowser
        $invocationParams = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.Webbrowser\Open-Webbrowser' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)

        # remove count parameter as it's specific to this function
        if ($invocationParams.ContainsKey('Count')) {

            $null = $invocationParams.Remove('Count')
        }
    }

    process {

        # log the search criteria being used for bookmark filtering
        Microsoft.PowerShell.Utility\Write-Verbose ('Searching bookmarks ' +
            'with criteria: ' + ($Queries -join ', '))

        # copy identical parameters between functions for bookmark searching
        $findParams = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.Webbrowser\Find-BrowserBookmark' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)

        # enable pass-through mode to get bookmark objects
        $findParams['PassThru'] = $true

        # find matching bookmarks and extract urls with count limitation
        $urls = @(GenXdev.Webbrowser\Find-BrowserBookmark @findParams |
                Microsoft.PowerShell.Core\ForEach-Object Url |
                Microsoft.PowerShell.Utility\Select-Object -First $Count)

        # check if any matching bookmarks were found
        if ($urls.Length -eq 0) {

            Microsoft.PowerShell.Utility\Write-Host ('No bookmarks found ' +
                'matching the criteria')
            return
        }

        # log the number of matching bookmarks found
        Microsoft.PowerShell.Utility\Write-Verbose ('Opening ' +
            "$($urls.Length) matching bookmarks in browser...")

        # pass extracted urls to browser opening function
        $invocationParams['Url'] = $urls

        # open all matching bookmark urls in the configured browser
        GenXdev.Webbrowser\Open-Webbrowser @invocationParams
    }

    end {

    }
}
################################################################################