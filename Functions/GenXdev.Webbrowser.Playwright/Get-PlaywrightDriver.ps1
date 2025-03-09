################################################################################
using namespace System.Management.Automation
using namespace System.Collections.Concurrent
using namespace Microsoft.Playwright

# suppress global variable warning as this is required for browser instance sharing
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    "PSAvoidGlobalVars",
    "",
    Justification = "Required for maintaining browser state across sessions"
)]
param()

################################################################################
<#
.SYNOPSIS
Creates or retrieves a configured Playwright browser instance.

.DESCRIPTION
iManages Playwright browser instances with support for Chrome, Firefox and Webkit.
Handles browser window positioning, state persistence, and reconnection to
existing instances. Provides a unified interface for browser automation tasks.

.PARAMETER BrowserType
The browser engine to use (Chromium, Firefox, or Webkit).

.PARAMETER ReferenceKey
Unique identifier to track browser instances across sessions.

.PARAMETER Visible
Shows the browser window instead of running headless.

.PARAMETER Url
Initial URL to navigate after launching the browser.

.PARAMETER Monitor
Target monitor for window placement (0=primary, -1=discard, -2=secondary).

.PARAMETER Width
Browser window width in pixels.

.PARAMETER Height
Browser window height in pixels.

.PARAMETER X
Horizontal window position in pixels.

.PARAMETER Y
Vertical window position in pixels.

.PARAMETER Left
Aligns window to screen left.

.PARAMETER Right
Aligns window to screen right.

.PARAMETER Top
Aligns window to screen top.

.PARAMETER Bottom
Aligns window to screen bottom.

.PARAMETER Centered
Centers window on screen.

.PARAMETER FullScreen
Launches browser in fullscreen mode.

.PARAMETER PersistBrowserState
Maintains browser profile between sessions.

.PARAMETER WsEndpoint
WebSocket URL for connecting to existing browser instance.

.EXAMPLE
# Launch visible Chrome browser at GitHub
Get-PlaywrightDriver -BrowserType Chromium -Visible -Url "https://github.com"

.EXAMPLE
# Connect to existing browser via WebSocket
Get-PlaywrightDriver -WsEndpoint "ws://localhost:9222"
#>
function Get-PlaywrightDriver {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    param (
        ########################################################################
        [Parameter(
            Position = 0,
            ParameterSetName = 'Default',
            HelpMessage = "Browser engine to use (Chromium/Firefox/Webkit)"
        )]
        [ValidateSet("Chromium", "Firefox", "Webkit")]
        [string]$BrowserType = "Chromium",

        ########################################################################
        [Parameter(
            Position = 1,
            ParameterSetName = 'Default',
            HelpMessage = "Unique identifier for the browser instance"
        )]
        [string]$ReferenceKey = "Default",

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default',
            HelpMessage = "Shows the browser window instead of running headless"
        )]
        [switch]$Visible,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default',
            HelpMessage = "Initial URL to navigate to after launching"
        )]
        [string]$Url,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default',
            HelpMessage = "Target monitor number for the browser window"
        )]
        [int]$Monitor = -2,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default',
            HelpMessage = "Browser window width in pixels"
        )]
        [int]$Width = -1,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default',
            HelpMessage = "Browser window height in pixels"
        )]
        [int]$Height = -1,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default',
            HelpMessage = "Horizontal position of browser window"
        )]
        [int]$X = -999999,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default',
            HelpMessage = "Vertical position of browser window"
        )]
        [int]$Y = -999999,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default',
            HelpMessage = "Align browser window to the left of the screen"
        )]
        [switch]$Left,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default',
            HelpMessage = "Align browser window to the right of the screen"
        )]
        [switch]$Right,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default',
            HelpMessage = "Align browser window to the top of the screen"
        )]
        [switch]$Top,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default',
            HelpMessage = "Align browser window to the bottom of the screen"
        )]
        [switch]$Bottom,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default',
            HelpMessage = "Center the browser window on screen"
        )]
        [switch]$Centered,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default',
            HelpMessage = "Launch browser in fullscreen mode"
        )]
        [switch]$FullScreen,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default',
            HelpMessage = "Maintain browser state between sessions"
        )]
        [switch]$PersistBrowserState,

        ########################################################################
        [Parameter(
            ParameterSetName = 'WebSocket',
            Mandatory = $true,
            HelpMessage = "WebSocket URL for connecting to existing browser instance"
        )]
        [string]$WsEndpoint
    )


    begin {
        Write-Verbose "Initializing Playwright driver for $BrowserType browser"

        # ensure browser dependencies are installed
        Update-PlaywrightDriverCache

        # normalize reference key for consistency
        $referenceKey = [string]::IsNullOrWhiteSpace($ReferenceKey) ? `
            "Default" : $ReferenceKey

        Write-Verbose "Using browser reference key: $referenceKey"
    }

    process {

        # handle websocket connection mode first
        if ($PSCmdlet.ParameterSetName -eq 'WebSocket') {

            Write-Verbose "Connecting to existing browser via WebSocket"
            return Connect-PlaywrightViaDebuggingPort -WsEndpoint $WsEndpoint
        }

        # attempt to retrieve existing browser instance
        $browser = $null
        if (-not $Global:GenXdevPlaywrightBrowserDictionary.TryGetValue(
                $referenceKey, [ref]$browser)) {

            Write-Verbose "Creating new browser instance"

            # configure browser launch options
            $launchOptions = @{
                Headless = -not $Visible
                Args     = @()
            }

            # add window sizing if specified
            if ($Width -gt 0 -and $Height -gt 0) {

                Write-Verbose "Setting window size to ${Width}x${Height}"
                $launchOptions.Args += "--window-size=${Width},${Height}"
            }

            # configure profile persistence
            if ($PersistBrowserState) {

                $profileDir = Get-PlaywrightProfileDirectory `
                    -BrowserType $BrowserType

                Write-Verbose "Using profile directory: $profileDir"
                $launchOptions.Args += "--user-data-dir=$profileDir"
            }

            try {
                # initialize playwright instance
                $pw = [Microsoft.Playwright.Playwright]::CreateAsync().Result

                # launch browser based on type
                $browser = switch ($BrowserType) {
                    "Chromium" { $pw.Chromium.LaunchAsync($launchOptions).Result }
                    "Firefox" { $pw.Firefox.LaunchAsync($launchOptions).Result }
                    "Webkit" { $pw.Webkit.LaunchAsync($launchOptions).Result }
                }

                # store browser instance for reuse
                $null = $Global:GenXdevPlaywrightBrowserDictionary.TryAdd(
                    $referenceKey, $browser)
            }
            catch {
                Write-Error "Failed to launch $BrowserType browser: $_"
                return
            }
        }

        if ($X -ne -999999 -or $Y -ne -999999) {
            Write-Warning "Window positioning not yet supported in Playwright"
        }

        # handle initial navigation if URL specified
        if ($Url) {

            Write-Verbose "Navigating to $Url"
            $page = $browser.NewPageAsync().Result
            $null = $page.GotoAsync($Url).Wait()
            return $page
        }

        return $browser
    }

    end {
    }
}
################################################################################
