################################################################################
<#
.SYNOPSIS
Selects a browser tab for automation in Chrome or Edge.

.DESCRIPTION
Manages browser tab selection for automation tasks. Can select tabs by ID, name,
or reference. Shows available tabs when no selection criteria are provided.
Supports both Chrome and Edge browsers. Handles browser connection and session
management.

.PARAMETER Id
Numeric identifier for the tab, shown when listing available tabs.

.PARAMETER Name
URL pattern to match when selecting a tab. Selects first matching tab.

.PARAMETER Edge
Switch to force selection in Microsoft Edge browser.

.PARAMETER Chrome
Switch to force selection in Google Chrome browser.

.PARAMETER ByReference
Session reference object from Get-ChromiumSessionReference to select specific tab.

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

    [CmdletBinding(DefaultParameterSetName = "ById")]
    [OutputType([string], [PSCustomObject])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    [Alias("st", "Select-BrowserTab")]

    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ParameterSetName = "ById",
            HelpMessage = "Tab identifier from the shown list"
        )]
        [ValidateRange(0, [int]::MaxValue)]
        [int] $Id = -1,

        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = "ByName",
            HelpMessage = "Selects first tab containing this name in URL"
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string] $Name,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force selection in Microsoft Edge"
        )]
        [Alias("e")]
        [switch] $Edge,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force selection in Google Chrome"
        )]
        [Alias("ch")]
        [switch] $Chrome,

        ########################################################################
        [Parameter(
            ParameterSetName = "ByReference",
            Mandatory = $true,
            HelpMessage = "Select tab using reference from Get-ChromiumSessionReference"
        )]
        [Alias("r")]
        [ValidateNotNull()]
        [PSCustomObject] $ByReference,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Forces browser restart if needed"
        )]
        [switch] $Force
    )

    begin {
        $sessions = $Global:chromeSessions ? $Global:chromeSessions : @()

        # determine debugging port based on browser selection or reference
        $debugPort = if ($null -ne $ByReference) {
            $ByReference.webSocketDebuggerUrl -replace "ws://localhost:(\d+)/.*", '$1'
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
                        $Global:chromeSession.id ? "*" : " "

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

            Microsoft.PowerShell.Utility\Write-Verbose "Establishing new browser automation connection"
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

                Microsoft.PowerShell.Utility\Write-Verbose "Retrieving list of available browser tabs"
                try {
                    # get all page tabs from browser
                    $sessions = @(
                        (Microsoft.PowerShell.Utility\Invoke-WebRequest -Uri "http://localhost:$debugPort/json").Content |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json |
                        Microsoft.PowerShell.Core\Where-Object -Property "type" -EQ "page"
                    )
                    $Global:chromeSessions = $sessions
                }
                catch {
                    if ($Force -and ($null -eq $ByReference)) {

                        # force browser restart if requested
                        $null = GenXdev.Webbrowser\Close-Webbrowser -Chrome:$Chrome -Edge:$Edge -Force -Chromium

                        $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
                            -BoundParameters $PSBoundParameters `
                            -FunctionName "GenXdev.Webbrowser\Open-Webbrowser" `
                            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -Name * `
                                -ErrorAction SilentlyContinue)

                        if (-not [string]::IsNullOrWhiteSpace($Name)) {
                            $invocationArguments.Url = $Name
                        }

                        $invocationArguments.Force = $true
                        $invocationArguments.Chromium = $true

                        $null = GenXdev.Webbrowser\Open-Webbrowser @invocationArguments

                        $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
                            -BoundParameters $PSBoundParameters `
                            -FunctionName "GenXdev.Webbrowser\Select-WebbrowserTab" `
                            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -Name * `
                                -ErrorAction SilentlyContinue)

                        $invocationArguments.Force = $false
                    }
                    else {

                        return "No browser available with open debugging port, use -Force to restart"
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

            # Ensure we have at least one session
            if ($sessions.Count -eq 0) {
                Microsoft.PowerShell.Utility\Write-Warning "No browser sessions found"
                $Global:chromeSession = $null
                return "No browser sessions available"
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
            $origData = $Global:chromeSession ? $Global:chromeSession.data : $null;            $Global:chromeSession = $sessions[$sessionId]

            # Validate that we have a valid session
            if ($null -eq $Global:chromeSession) {
                Microsoft.PowerShell.Utility\Write-Warning "No valid session found at index $sessionId"
                return "No valid browser session available"
            }

            $newId = $Global:chromeSession ? $Global:chromeSession.id : $null;
            $newData = $Global:chromeSession ? $Global:chromeSession.data : $null;

            if ($origId -ne $newId) {
                Microsoft.PowerShell.Utility\Write-Verbose "Selected tab: $($sessions[$sessionId].url)"
            }
            else {
                # Only add member if session is not null
                if ($null -ne $Global:chromeSession) {
                    Microsoft.PowerShell.Utility\Add-Member -InputObject $Global:chromeSession `
                        -MemberType NoteProperty -Name "data" -Value $origData -Force
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
                    $session = $Global:chrome.Browser.Contexts[0].NewCDPSessionAsync($PSItem).Result;
                    $info = $session.sendAsync("Target.getTargetInfo").Result |
                    Microsoft.PowerShell.Utility\ConvertFrom-Json
                    if ($info.targetInfo.targetId -eq $Global:chromeSession.id) {
                        $PSItem
                    }
                } | Microsoft.PowerShell.Utility\Select-Object -First 1;

                Microsoft.PowerShell.Utility\Write-Verbose "Connected to tab: $($sessions[$sessionId].url)"
            }
            else {
                throw "No browser automation object available"
            }
        }
        else {
            if ($null -eq $ByReference) {

                # handle selection by ID
                $sessions = $Global:chromeSessions                # refresh sessions if ID out of range
                if ($Id -ge $sessions.Count) {
                    $sessions = @((Microsoft.PowerShell.Utility\Invoke-WebRequest `
                                -Uri "http://localhost:$debugPort/json").Content |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json |
                        Microsoft.PowerShell.Core\Where-Object -Property "type" -EQ "page")
                    $Global:chromeSessions = $sessions
                    Microsoft.PowerShell.Utility\Write-Verbose "Refreshed sessions, found $($sessions.Count)"

                    Show-TabList
                    throw "Session expired, select new session with Select-WebbrowserTab -> st"
                }

                # connect to selected tab
                $Global:chromeSession = $sessions[$Id]
                $Global:chromeController = $Global:chrome.Browser.Contexts[0].Pages |
                Microsoft.PowerShell.Core\ForEach-Object {
                    $session = $Global:chrome.Browser.Contexts[0].NewCDPSessionAsync($PSItem).Result;
                    $info = $session.sendAsync("Target.getTargetInfo").Result |
                    Microsoft.PowerShell.Utility\ConvertFrom-Json
                    if ($info.targetInfo.targetId -eq $Global:chromeSession.id) {
                        $PSItem
                    }
                } | Microsoft.PowerShell.Utility\Select-Object -First 1;                # refresh session list
                try {
                    $sessions = @((Microsoft.PowerShell.Utility\Invoke-WebRequest `
                                -Uri "http://localhost:$debugPort/json").Content |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json |
                        Microsoft.PowerShell.Core\Where-Object -Property "type" -EQ "page")
                    $Global:chromeSessions = $sessions
                }
                catch {
                    throw "Session expired, select new session with Select-WebbrowserTab -> st"
                }

                Microsoft.PowerShell.Utility\Write-Verbose "Updated tab list"
            }
            else {
                # use provided reference
                $Global:chromeSession = $ByReference
            }

            # connect to selected tab
            $Global:chromeController = $Global:chrome.Browser.Contexts[0].Pages |
            Microsoft.PowerShell.Core\ForEach-Object {
                $session = $Global:chrome.Browser.Contexts[0].NewCDPSessionAsync($PSItem).Result;
                $info = $session.sendAsync("Target.getTargetInfo").Result |
                Microsoft.PowerShell.Utility\ConvertFrom-Json
                if ($info.targetInfo.targetId -eq $Global:chromeSession.id) {
                    $PSItem
                }
            } | Microsoft.PowerShell.Utility\Select-Object -First 1;

            # verify tab still exists
            $found = $null -ne $Global:chromeController

            if (!$found) {
                if ($null -eq $ByReference) {
                    Show-TabList
                }
                throw "Session expired, select new session with st"
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