################################################################################
using namespace System.Management.Automation
using namespace System.Collections.Concurrent
using namespace Microsoft.Playwright

################################################################################
<#
.SYNOPSIS
Connects to an existing browser instance via debugging port.

.DESCRIPTION
Establishes a connection to a running browser instance using the WebSocket
debugger URL. Returns a Playwright browser instance that can be used for
automation.

.PARAMETER WsEndpoint
The WebSocket URL for the browser's debugging port
(e.g., ws://localhost:9222/devtools/browser/...)

.EXAMPLE
Connect-PlaywrightViaDebuggingPort `
    -WsEndpoint "ws://localhost:9222/devtools/browser/abc123"

.EXAMPLE
Connect-PlaywrightViaDebuggingPort "ws://localhost:9222/devtools/browser/abc123"
#>
function Connect-PlaywrightViaDebuggingPort {

    [CmdletBinding()]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "WebSocket URL for browser debugging connection"
        )]
        [ValidateNotNullOrEmpty()]
        [string]$WsEndpoint
        ########################################################################
    )

    begin {

        # output connection attempt information
        # Write-Verbose "Attempting to connect to browser at: $WsEndpoint"
    }

    process {
        try {
            # create playwright instance
            # Write-Verbose "Creating Playwright instance"
            $playwright = [Microsoft.Playwright.Playwright]::CreateAsync().Result

            # connect to browser over CDP
            # Write-Verbose "Connecting to browser via CDP"
            $browser = $playwright.Chromium.ConnectOverCDPAsync($WsEndpoint).Result

            # store browser instance in global dictionary
            # Write-Verbose "Storing browser instance with WsEndpoint as key"
            $Global:GenXdevPlaywrightBrowserDictionary[$WsEndpoint] = $browser

            # return the browser instance
            return $browser
        }
        catch {
            Write-Error "Failed to connect via debugging port: $_"
            throw
        }
    }

    end {
    }
}
################################################################################
