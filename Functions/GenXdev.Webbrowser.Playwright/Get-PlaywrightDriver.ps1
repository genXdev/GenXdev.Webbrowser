################################################################################
using namespace System.Management.Automation
using namespace System.Collections.Concurrent
using namespace Microsoft.Playwright

################################################################################
<#
.SYNOPSIS
Gets or creates a Playwright browser instance with full configuration options.

.DESCRIPTION
Creates and manages Playwright browser instances with support for multiple browser
types, window positioning, and state persistence.

.PARAMETER BrowserType
The type of browser to launch (Chromium, Firefox, or Webkit).

.PARAMETER ReferenceKey
Unique identifier for the browser instance. Defaults to "Default".

.PARAMETER Visible
Shows the browser window instead of running headless.

.PARAMETER Url
The URL or URLs to open in the browser. Can be provided via pipeline.

.PARAMETER Monitor
The monitor to use (0=default, -1=discard, -2=configured secondary monitor, defaults to $Global:DefaultSecondaryMonitor or 2 if not found).

.PARAMETER Width
The initial width of the webbrowser window.

.PARAMETER Height
The initial height of the webbrowser window.

.PARAMETER X
The initial X position of the webbrowser window.

.PARAMETER Y
The initial Y position of the webbrowser window.

.PARAMETER Left
Places browser window on the left side of the screen.

.PARAMETER Right
Places browser window on the right side of the screen.

.PARAMETER Top
Places browser window on the top side of the screen.

.PARAMETER Bottom
Places browser window on the bottom side of the screen.

.PARAMETER Centered
Places browser window in the center of the screen.

.PARAMETER FullScreen
Opens browser in fullscreen mode.

.PARAMETER PersistBrowserState
Maintains browser state between sessions.

.PARAMETER WsEndpoint
WebSocket URL for connecting to existing browser instance.

.EXAMPLE
Get-PlaywrightDriver -BrowserType Chromium -Visible -Url "https://github.com"

.NOTES
This is a Playwright-specific implementation that may not support all features of Open-Webbrowser.
Some positioning and window management features may be limited by Playwright capabilities.
#>
function Get-PlaywrightDriver {

    [CmdletBinding(DefaultParameterSetName = 'Default')]

    param (
        ########################################################################
        [Parameter(
            Position = 0,
            ParameterSetName = 'Default',
            HelpMessage = "The type of browser to launch"
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

        # ensure playwright cache is up to date
        Update-PlaywrightDriverCache

        # normalize reference key
        $referenceKey = [string]::IsNullOrWhiteSpace($ReferenceKey) ? `
            "Default" : $ReferenceKey

        # Write-Verbose "Using browser reference key: $referenceKey"
    }

    process {

        # Early return for WebSocket parameter set
        if ($PSCmdlet.ParameterSetName -eq 'WebSocket') {
            return Connect-PlaywrightViaDebuggingPort -WsEndpoint $WsEndpoint
        }

        # check if browser instance already exists
        if (-not $Global:GenXdevPlaywrightBrowserDictionary.TryGetValue(
                $referenceKey, [ref]$browser)) {

            # configure browser launch options
            $launchOptions = @{
                Headless = -not $Visible
                Args     = @()
            }

            # add window size arguments if specified
            if ($Width -gt 0 -and $Height -gt 0) {
                # Write-Verbose "Setting window size to ${Width}x${Height}"
                $launchOptions.Args += "--window-size=${Width},${Height}"
            }

            # configure persistent profile if requested
            if ($PersistBrowserState) {
                $profileDir = Get-PlaywrightProfileDirectory -BrowserType $BrowserType
                # Write-Verbose "Using profile directory: $profileDir"
                $launchOptions.Args += "--user-data-dir=$profileDir"
            }

            try {
                # create playwright instance
                $pw = [Microsoft.Playwright.Playwright]::CreateAsync().Result

                # launch browser based on type
                $browser = switch ($BrowserType) {
                    "Chromium" { $pw.Chromium.LaunchAsync($launchOptions).Result }
                    "Firefox" { $pw.Firefox.LaunchAsync($launchOptions).Result }
                    "Webkit" { $pw.Webkit.LaunchAsync($launchOptions).Result }
                }

                # store browser instance in global dictionary
                $null = $Global:GenXdevPlaywrightBrowserDictionary.TryAdd(
                    $referenceKey, $browser)
            }
            catch {

                Write-Error "Failed to launch $BrowserType browser: $_"
                return
            }
        }

        # warn about unsupported window positioning
        if ($X -ne -999999 -or $Y -ne -999999) {

            Write-Warning "Window positioning is not yet supported in Playwright"
        }

        # navigate to url if specified
        if ($Url) {

            # Write-Verbose "Navigating to $Url"
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
