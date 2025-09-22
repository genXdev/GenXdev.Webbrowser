<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser
Original cmdlet filename  : Select-WebbrowserTab.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.278.2025
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
Selects a browser tab for automation in Chrome or Edge.

.DESCRIPTION
Manages browser tab selection for automation tasks. Can select tabs by ID, name,
or reference. Shows available tabs when no selection criteria are provided.
Supports both Chrome and Edge browsers. Handles browser connection and session
management.

This function provides comprehensive tab selection capabilities for web browser
automation. It can list available tabs, select specific tabs by various
criteria, and establish automation connections to the selected tab. The function
supports both Chrome and Edge browsers with debugging capabilities enabled.

Key features:
- Tab selection by numeric ID, URL pattern, or session reference
- Automatic browser detection and connection establishment
- Session management with state preservation
- Force restart capabilities when debugging ports are unavailable
- Integration with browser automation frameworks

.PARAMETER Id
Numeric identifier for the tab, shown when listing available tabs.

.PARAMETER Name
URL pattern to match when selecting a tab. Selects first matching tab.

.PARAMETER ByReference
Session reference object from Get-ChromiumSessionReference to select specific tab.

.PARAMETER Monitor
The monitor to use for window placement:
- 0 = Primary monitor
- -1 = Discard positioning
- -2 = Configured secondary monitor (uses $Global:DefaultSecondaryMonitor or
  defaults to monitor 2)
- 1+ = Specific monitor number

.PARAMETER Width
The initial width of the browser window in pixels.

.PARAMETER Height
The initial height of the browser window in pixels.

.PARAMETER X
The initial X coordinate for window placement.

.PARAMETER Y
The initial Y coordinate for window placement.

.PARAMETER AcceptLang
Sets the browser's Accept-Language HTTP header for internationalization.

.PARAMETER FullScreen
Opens the browser in fullscreen mode using F11 key simulation.

.PARAMETER Private
Opens the browser in private/incognito browsing mode.

.PARAMETER Chromium
Opens URLs in either Microsoft Edge or Google Chrome, depending on which
is set as the default browser.

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
Hides browser controls for a distraction-free experience.

.PARAMETER NoBrowserExtensions
Prevents loading of browser extensions.

.PARAMETER DisablePopupBlocker
Disables the browser's popup blocking functionality.

.PARAMETER RestoreFocus
Returns focus to the PowerShell window after opening the browser.

.PARAMETER NewWindow
Forces creation of a new browser window instead of reusing existing windows.

.PARAMETER FocusWindow
Gives focus to the browser window after opening.

.PARAMETER SetForeground
Brings the browser window to the foreground after opening.

.PARAMETER Maximize
Maximizes the browser window after positioning.

.PARAMETER KeysToSend
Keystrokes to send to the browser window after opening.

.PARAMETER SendKeyEscape
Escapes control characters when sending keystrokes to the browser.

.PARAMETER SendKeyHoldKeyboardFocus
Prevents returning keyboard focus to PowerShell after sending keystrokes.

.PARAMETER SendKeyUseShiftEnter
Uses Shift+Enter instead of regular Enter for line breaks when sending keys.

.PARAMETER SendKeyDelayMilliSeconds
Delay between sending different key sequences in milliseconds.

.PARAMETER Edge
Switch to force selection in Microsoft Edge browser.

.PARAMETER Chrome
Switch to force selection in Google Chrome browser.

.PARAMETER Force
Switch to force browser restart if needed during selection.

.EXAMPLE
Select-WebbrowserTab -Id 3 -Chrome -Force
Selects tab ID 3 in Chrome browser, forcing restart if needed.

.EXAMPLE
st -Name "github.com" -e
Selects first tab containing "github.com" in Edge browser using alias.
#>
function Select-WebbrowserTab {

    [CmdletBinding(DefaultParameterSetName = 'ById')]
    [OutputType([string], [PSCustomObject])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Alias('st')]

    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ParameterSetName = 'ById',
            HelpMessage = 'Tab identifier from the shown list'
        )]
        [ValidateRange(0, [int]::MaxValue)]
        [int] $Id = -1,

        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = 'ByName',
            HelpMessage = 'Selects first tab containing this name in URL'
        )]
        [Alias('Pattern')]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string] $Name,

        ########################################################################
        [Parameter(
            ParameterSetName = 'ByReference',
            Mandatory = $true,
            HelpMessage = 'Select tab using reference from Get-ChromiumSessionReference'
        )]
        [ValidateNotNull()]
        [PSCustomObject] $ByReference,

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

        ########################################################################
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

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Keystrokes to send to the Browser window, ' +
                'see documentation for cmdlet GenXdev.Windows\Send-Key')
        )]
        [string[]] $KeysToSend,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Escape control characters when sending keys'
        )]
        [Alias('Escape')]
        [switch] $SendKeyEscape,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Prevent returning keyboard focus to PowerShell ' +
                'after sending keys')
        )]
        [Alias('HoldKeyboardFocus')]
        [switch] $SendKeyHoldKeyboardFocus,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Send Shift+Enter instead of regular Enter for ' +
                'line breaks')
        )]
        [Alias('UseShiftEnter')]
        [switch] $SendKeyUseShiftEnter,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Delay between sending different key sequences ' +
                'in milliseconds')
        )]
        [Alias('DelayMilliSeconds')]
        [int] $SendKeyDelayMilliSeconds,

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
            HelpMessage = 'Forces browser restart if needed'
        )]
        [switch] $Force
    )

    begin {

        # store existing sessions from global state
        $sessions = $Global:chromeSessions ? $Global:chromeSessions : @()

        # determine debugging port based on browser selection or reference
        $debugPort = if ($null -ne $ByReference) {
            $ByReference.webSocketDebuggerUrl -replace 'ws://localhost:(\d+)/.*', '$1'
        }
        elseif ($Edge) {
            GenXdev.Webbrowser\Get-EdgeRemoteDebuggingPort
        }
        elseif ($Chrome) {
            GenXdev.Webbrowser\Get-ChromeRemoteDebuggingPort
        }
        else {
            GenXdev.Webbrowser\Get-ChromiumRemoteDebuggingPort
        }

        # ensure global state storage exists
        if ($Global:Data -isnot [HashTable]) {
            $Global:Data = @{}
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Using browser debugging port: $debugPort"
    }

    process {

        # helper function to display available browser tabs
        function Show-TabList {

            $index = 0
            $Global:chromeSessions |
                Microsoft.PowerShell.Core\ForEach-Object {
                    if (![String]::IsNullOrWhiteSpace($PSItem.url)) {
                        # mark current tab with asterisk
                        $bullet = $PSItem.id -eq `
                            $Global:chromeSession.id ? '*' : ' '

                        $url = $PSItem.url
                        $title = $PSItem.title

                        [PSCustomObject]@{
                            id    = $index
                            A     = $bullet
                            url   = $url
                            title = $title
                        }
                        $index++
                    }
                }
        }

        # create or update automation connection if needed
        if ($Global:chrome -isnot [Hashtable] -or
            $Global:chrome.Port -ne $debugPort -or
            $null -eq $Global:chrome.Browser -or
            (-not $Global:chrome.Browser.IsConnected)) {

            Microsoft.PowerShell.Utility\Write-Verbose 'Establishing new browser automation connection'
                $Global:chrome = @{
                    Debugurl = "http://localhost:$debugPort"
                    Port     = $debugPort
                    Browser  = GenXdev.Webbrowser\Connect-PlaywrightViaDebuggingPort `
                        -WsEndpoint "http://localhost:$debugPort"
                }

            $Global:CurrentChromiumDebugPort = $debugPort
        }

        # handle tab selection by name or show available tabs
        if (($null -eq $ByReference -and $Id -lt 0) -or
            ![string]::IsNullOrWhiteSpace($Name)) {

            Microsoft.PowerShell.Utility\Write-Verbose 'Retrieving list of available browser tabs'
            try {
                # get all page tabs from browser
                $sessions = @(
                        (Microsoft.PowerShell.Utility\Invoke-WebRequest -Uri "http://localhost:$debugPort/json").Content |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json |
                        Microsoft.PowerShell.Core\Where-Object -Property 'type' -EQ 'page'
                )
                $Global:chromeSessions = $sessions
            }
            catch {
                if ($Force -and ($null -eq $ByReference)) {

                    # force browser restart if requested
                    $null = GenXdev.Webbrowser\Close-Webbrowser -Chrome:$Chrome -Edge:$Edge -Force -Chromium

                    # copy identical parameters between functions
                    $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
                        -BoundParameters $PSBoundParameters `
                        -FunctionName 'GenXdev.Webbrowser\Open-Webbrowser' `
                        -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -Name * `
                            -ErrorAction SilentlyContinue)

                    # set url if name was provided
                    if (-not [string]::IsNullOrWhiteSpace($Name)) {
                        $invocationArguments.Url = $Name
                    }

                    $invocationArguments.Force = $true
                    $invocationArguments.Chromium = $true

                    $null = GenXdev.Webbrowser\Open-Webbrowser @invocationArguments

                    # prepare parameters for recursive call
                    $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
                        -BoundParameters $PSBoundParameters `
                        -FunctionName 'GenXdev.Webbrowser\Select-WebbrowserTab' `
                        -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -Name * `
                            -ErrorAction SilentlyContinue)

                    $invocationArguments.Force = $false

                    # wait for browser to start up
                    Microsoft.PowerShell.Utility\Write-Verbose 'Waiting for browser to start...'
                    $null = Microsoft.PowerShell.Utility\Start-Sleep -Seconds 3

                    # prepare parameters for recursive call, excluding problematic Id parameter
                    $recursiveParams = @{}
                    foreach ($key in $PSBoundParameters.Keys) {
                        if ($key -ne 'Id' -and $key -ne 'Force') {
                            $recursiveParams[$key] = $PSBoundParameters[$key]
                        }
                    }
                    $recursiveParams['Force'] = $false

                    # recursively call self to connect to the new browser
                    return GenXdev.Webbrowser\Select-WebbrowserTab @recursiveParams
                }
                else {

                    return 'No browser available with open debugging port, use -Force to restart'
                }

                # reset global state
                $Global:chromeSessions = @()
                $Global:chromeController = $null
                $Global:chrome = $null
                $Global:chromeSession = $null
                return
            }

            $Global:chromeSessions = $sessions
            Microsoft.PowerShell.Utility\Write-Verbose "Found $($sessions.Count) browser tabs"

            # ensure we have at least one session
            if ($sessions.Count -eq 0) {
                Microsoft.PowerShell.Utility\Write-Warning 'No browser sessions found'
                $Global:chromeSession = $null
                return 'No browser sessions available'
            }

            # find matching session based on criteria
            $sessionId = 0
            while ($sessionId -lt ($sessions.Count - 1) -and (
                    (![string]::IsNullOrWhiteSpace($Name) -and
                    ($sessions[$sessionId].url -notlike "$Name")) -or
                    (($null -ne $ByReference) -and
                    ($sessions[$sessionId].id -ne $ByReference.id))
                )) {

                Microsoft.PowerShell.Utility\Write-Verbose "Skipping tab: $($sessions[$sessionId].url)"
                $sessionId++
            }

            $sessionId = [Math]::Min($sessionId, $sessions.Count - 1)

            # preserve session data when switching tabs
            $origId = $Global:chromeSession ? $Global:chromeSession.id : $null;
            $origData = $Global:chromeSession ? $Global:chromeSession.data : $null;

            $Global:chromeSession = $sessions[$sessionId]

            # validate that we have a valid session
            if ($null -eq $Global:chromeSession) {
                Microsoft.PowerShell.Utility\Write-Warning "No valid session found at index $sessionId"
                return 'No valid browser session available'
            }

            $newId = $Global:chromeSession ? $Global:chromeSession.id : $null;
            $newData = $Global:chromeSession ? $Global:chromeSession.data : $null;

            if ($origId -ne $newId) {
                Microsoft.PowerShell.Utility\Write-Verbose "Selected tab: $($sessions[$sessionId].url)"
            }
            else {
                # only add member if session is not null
                if ($null -ne $Global:chromeSession) {
                    Microsoft.PowerShell.Utility\Add-Member -InputObject $Global:chromeSession `
                        -MemberType NoteProperty -Name 'data' -Value $origData -Force
                }
                Microsoft.PowerShell.Utility\Write-Verbose "Selected tab: $($sessions[$sessionId].url) (unchanged)"
            }

            # connect to selected tab via automation
            if (($null -ne $Global:chrome) -and
                    ($null -ne $Global:chrome.Browser) -and
                    ($null -ne $Global:chrome.Browser.Contexts) -and
                    ($null -ne $Global:chrome.Browser.Contexts[0])) {

                $Global:chromeController = $Global:chrome.Browser.Contexts[0].Pages |
                    Microsoft.PowerShell.Core\ForEach-Object {
                        try {
                            $session = $Global:chrome.Browser.Contexts[0].NewCDPSessionAsync($PSItem).Result;
                            if ($null -ne $session) {
                                $info = $session.sendAsync('Target.getTargetInfo').Result |
                                    Microsoft.PowerShell.Utility\ConvertFrom-Json
                                if ($info.targetInfo.targetId -eq $Global:chromeSession.id) {
                                    $PSItem
                                }
                            }
                        }
                        catch {
                            Microsoft.PowerShell.Utility\Write-Verbose "Failed to create session for page: $($_.Exception.Message)"
                        }
                    } |
                    Microsoft.PowerShell.Utility\Select-Object -First 1;

                Microsoft.PowerShell.Utility\Write-Verbose "Connected to tab: $($sessions[$sessionId].url)"
            }
            else {
                throw 'No browser automation object available'
            }
        }
        else {
            if ($null -eq $ByReference) {

                # handle selection by ID
                $sessions = $Global:chromeSessions

                # refresh sessions if ID out of range
                if ($Id -ge $sessions.Count) {
                    $sessions = @((Microsoft.PowerShell.Utility\Invoke-WebRequest `
                                -Uri "http://localhost:$debugPort/json").Content |
                            Microsoft.PowerShell.Utility\ConvertFrom-Json |
                            Microsoft.PowerShell.Core\Where-Object -Property 'type' -EQ 'page')
                    $Global:chromeSessions = $sessions
                    Microsoft.PowerShell.Utility\Write-Verbose "Refreshed sessions, found $($sessions.Count)"

                    Show-TabList
                    throw 'Session expired, select new session with Select-WebbrowserTab -> st'
                }

                # connect to selected tab
                $Global:chromeSession = $sessions[$Id]
                $Global:chromeController = $Global:chrome.Browser.Contexts[0].Pages |
                    Microsoft.PowerShell.Core\ForEach-Object {
                        try {
                            $session = $Global:chrome.Browser.Contexts[0].NewCDPSessionAsync($PSItem).Result;
                            if ($null -ne $session) {
                                $info = $session.sendAsync('Target.getTargetInfo').Result |
                                    Microsoft.PowerShell.Utility\ConvertFrom-Json
                                if ($info.targetInfo.targetId -eq $Global:chromeSession.id) {
                                    $PSItem
                                }
                            }
                        }
                        catch {
                            Microsoft.PowerShell.Utility\Write-Verbose "Failed to create session for page: $($_.Exception.Message)"
                        }
                    } |
                    Microsoft.PowerShell.Utility\Select-Object -First 1;

                # refresh session list
                try {
                    $sessions = @((Microsoft.PowerShell.Utility\Invoke-WebRequest `
                                -Uri "http://localhost:$debugPort/json").Content |
                            Microsoft.PowerShell.Utility\ConvertFrom-Json |
                            Microsoft.PowerShell.Core\Where-Object -Property 'type' -EQ 'page')
                    $Global:chromeSessions = $sessions
                }
                catch {
                    throw 'Session expired, select new session with Select-WebbrowserTab -> st'
                }

                Microsoft.PowerShell.Utility\Write-Verbose 'Updated tab list'
            }
            else {
                # use provided reference
                $Global:chromeSession = $ByReference
            }

            # connect to selected tab
            $Global:chromeController = $Global:chrome.Browser.Contexts[0].Pages |
                Microsoft.PowerShell.Core\ForEach-Object {
                    try {
                        $session = $Global:chrome.Browser.Contexts[0].NewCDPSessionAsync($PSItem).Result;
                        if ($null -ne $session) {
                            $info = $session.sendAsync('Target.getTargetInfo').Result |
                                Microsoft.PowerShell.Utility\ConvertFrom-Json
                            if ($info.targetInfo.targetId -eq $Global:chromeSession.id) {
                                $PSItem
                            }
                        }
                    }
                    catch {
                        Microsoft.PowerShell.Utility\Write-Verbose "Failed to create session for page: $($_.Exception.Message)"
                    }
                } |
                Microsoft.PowerShell.Utility\Select-Object -First 1;

            # verify tab still exists
            $found = $null -ne $Global:chromeController

            if (!$found) {
                if ($null -eq $ByReference) {
                    Show-TabList
                }
                throw 'Session expired, select new session with st'
            }
        }

        # show available tabs unless using reference
        if ($null -eq $ByReference) {
            Show-TabList
        }
    }

    end {
    }
}
################################################################################