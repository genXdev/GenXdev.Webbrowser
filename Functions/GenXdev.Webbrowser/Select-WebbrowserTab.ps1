################################################################################
<#
.SYNOPSIS
Selects a webbrowser tab for use with automation cmdlets.

.DESCRIPTION
Selects and connects to a browser tab for use with automation cmdlets like
Invoke-WebbrowserEvaluation, Close-WebbrowserTab and others. Without parameters
it shows a list of available tabs.

.PARAMETER Id
Tab identifier from the list shown when no id is provided.

.PARAMETER Name
Selects first tab containing this name in its URL.

.PARAMETER Edge
Force selection in Microsoft Edge browser.

.PARAMETER Chrome
Force selection in Google Chrome browser.

.PARAMETER ByReference
Select tab using reference from Get-ChromiumSessionReference.

.PARAMETER Force
Forces browser restart if needed.

.EXAMPLE
Select-WebbrowserTab -Id 3 -Chrome

.EXAMPLE
st -ch 14
#>
function Select-WebbrowserTab {

    [CmdletBinding(DefaultParameterSetName = "ById")]
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

        # determine debug port based on parameters
        $debugPort = if ($null -ne $ByReference) {
            $ByReference.webSocketDebuggerUrl -replace "ws://localhost:(\d+)/.*", '$1'
        }
        elseif ($Edge) {
            Get-EdgeRemoteDebuggingPort
        }
        elseif ($Chrome) {
            Get-ChromeRemoteDebuggingPort
        }
        else {
            Get-ChromiumRemoteDebuggingPort
        }

        # ensure global data hashtable exists
        if ($Global:Data -isnot [HashTable]) {
            $Global:Data = @{}
        }

        Write-Verbose "Using debug port $debugPort"
    }

    process {

        # helper function to display tab list
        function Show-TabList {
            $index = 0
            $Global:chromeSessions | ForEach-Object {
                if (![String]::IsNullOrWhiteSpace($PSItem.url)) {
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

        # create or update chrome automation object if needed
        if ($Global:chrome -isnot [Hashtable] -or
            $Global:chrome.Port -ne $debugPort -or
            $null -eq $Global:chrome.Browser -or
            (-not $Global:chrome.Browser.IsConnected)) {

            Write-Verbose "Creating new chromium automation object"
            $Global:chrome = @{

                Debugurl = "http://localhost:$debugPort"
                Port     = $debugPort
                Browser  = Connect-PlaywrightViaDebuggingPort -WsEndpoint "http://localhost:$debugPort" -Verbose
            }

            $Global:CurrentChromiumDebugPort = $debugPort
        }

        # handle no id or name specified
        if (($null -eq $ByReference -and $Id -lt 0) -or
            ![string]::IsNullOrWhiteSpace($Name)) {

            Write-Verbose "Getting available sessions"

            try {
                $sessions = @(
                    (Invoke-WebRequest -Uri "http://localhost:$debugPort/json").Content |
                    ConvertFrom-Json |
                    Where-Object -Property "type" -EQ "page" |
                    Where-Object -Property "url" -Match "^https?://"
                )
            }
            catch {
                if ($Force -and ($null -eq $ByReference)) {

                    $null = Get-Process msedge, chrome | Stop-Process -Force
                    $null = Close-Webbrowser -Chrome:$Chrome -Edge:$Edge -Force -Chromium

                    if ([string]::IsNullOrWhiteSpace($Name)) {
                        $null = Open-Webbrowser -Chrome:$Chrome -Edge:$Edge -Force -Chromium
                        return Select-WebbrowserTab @PSBoundParameters
                    }
                    else {
                        $null = Open-Webbrowser -Chrome:$Chrome -Edge:$Edge -Force `
                            -Url $Name -Chromium
                        return Select-WebbrowserTab @PSBoundParameters
                    }
                }
                else {
                    if ($Global:Host.Name.Contains("Visual Studio")) {
                        return "Press F5 to start debugging first.."
                    }
                    else {
                        return "Use Open-Webbrowser (wb) to start browser with debugging"
                    }
                }

                $Global:chromeSessions = @()
                $Global:chromeController = $null
                $Global:chrome = $null
                $Global:chromeSession = $null
                return
            }

            $Global:chromeSessions = $sessions
            Write-Verbose "Found $($sessions.Count) sessions"

            # find first matching session
            $sessionId = 0
            while ($sessionId -lt ($sessions.Count - 1) -and (
                    (![string]::IsNullOrWhiteSpace($Name) -and
                    ($sessions[$sessionId].url -notlike "$Name")) -or
                    (($null -ne $ByReference) -and
                    ($sessions[$sessionId].id -ne $ByReference.id))
                )) {

                Write-Verbose "Skipping $($sessions[$sessionId].url)"
                $sessionId++
            }

            $sessionId = [Math]::Min($sessionId, $sessions.Count - 1)

            $origId = $Global:chromeSession ? $Global:chromeSession.id : $null;
            $origData = $Global:chromeSession ? $Global:chromeSession.data : $null;

            $Global:chromeSession = $sessions[$sessionId]

            $newId = $Global:chromeSession ? $Global:chromeSession.id : $null;
            $newData = $Global:chromeSession ? $Global:chromeSession.data : $null;

            if ($origId -ne $newId) {

                Write-Verbose "Selected session: $($sessions[$sessionId].url)"
            }
            else {

                Add-Member -InputObject $Global:chromeSession -MemberType NoteProperty -Name "data" -Value $origData -Force
                Write-Verbose "Selected session: $($sessions[$sessionId].url) (unchanged)"
            }

            if (($null -ne $Global:chrome) -and
                    ($null -ne $Global:chrome.Browser) -and
                    ($null -ne $Global:chrome.Browser.Contexts) -and
                    ($null -ne $Global:chrome.Browser.Contexts[0])) {

                $Global:chromeController = $Global:chrome.Browser.Contexts[0].Pages | ForEach-Object {

                    $session = $Global:chrome.Browser.Contexts[0].NewCDPSessionAsync($PSItem).Result;
                    $info = $session.sendAsync("Target.getTargetInfo").Result | ConvertFrom-Json
                    if ($info.targetInfo.targetId -eq $Global:chromeSession.id) {

                        $PSItem
                    }
                } | Select-Object -First 1;
                Write-Verbose "Selected session: $($sessions[$sessionId].url)"
            }
            else {
                throw "No browser automation object available"
            }
        }
        else {
            if ($null -eq $ByReference) {

                # id specified

                $sessions = $Global:chromeSessions

                if ($Id -ge $sessions.Count) {
                    $sessions = @((Invoke-WebRequest -Uri "http://localhost:$debugPort/json").Content | ConvertFrom-Json | Where-Object -Property "type" -EQ "page" | Where-Object -Property "url" -Match "^https?://")
                    $Global:chromeSessions = $sessions
                    Write-Verbose "Refreshed sessions, found $($sessions.Count)"

                    Show-TabList
                    throw "Session expired, select new session with Select-WebbrowserTab -> st"
                }

                $Global:chromeSession = $sessions[$Id]
                $Global:chromeController = $Global:chrome.Browser.Contexts[0].Pages | ForEach-Object {
                    $session = $Global:chrome.Browser.Contexts[0].NewCDPSessionAsync($PSItem).Result;
                    $info = $session.sendAsync("Target.getTargetInfo").Result | ConvertFrom-Json
                    if ($info.targetInfo.targetId -eq $Global:chromeSession.id) {

                        $PSItem
                    }
                } | Select-Object -First 1;

                try {
                    $sessions = @((Invoke-WebRequest -Uri "http://localhost:$debugPort/json").Content | ConvertFrom-Json | Where-Object -Property "type" -EQ "page" | Where-Object -Property "url" -Match "^https?://")
                    $Global:chromeSessions = $sessions
                }
                catch {
                    throw "Session expired, select new session with Select-WebbrowserTab -> st"
                }

                Write-Verbose "Updated session list"
            }
            else {

                # reference specified
                $Global:chromeSession = $ByReference
            }

            $Global:chromeController = $Global:chrome.Browser.Contexts[0].Pages | ForEach-Object {
                $session = $Global:chrome.Browser.Contexts[0].NewCDPSessionAsync($PSItem).Result;
                $info = $session.sendAsync("Target.getTargetInfo").Result | ConvertFrom-Json
                if ($info.targetInfo.targetId -eq $Global:chromeSession.id) {

                    $PSItem
                }
            } | Select-Object -First 1;

            # validate session still exists
            $found = $null -ne $Global:chromeController

            if (!$found) {

                if ($null -eq $ByReference) {

                    Show-TabList
                }
                throw "Session expired, select new session with st"
            }
        }

        if ($null -eq $ByReference) {

            Show-TabList
        }
    }

    end {
    }
}
################################################################################
