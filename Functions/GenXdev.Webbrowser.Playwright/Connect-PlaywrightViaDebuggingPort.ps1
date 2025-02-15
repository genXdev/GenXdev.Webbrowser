################################################################################
using namespace System.Management.Automation
using namespace System.Collections.Concurrent
using namespace Microsoft.Playwright

################################################################################
<#
.SYNOPSIS
Connects to an existing browser instance via debugging port.

.DESCRIPTION
Establishes a connection to a running Chromium-based browser instance using the
WebSocket debugger URL. Creates a Playwright instance and connects over CDP
(Chrome DevTools Protocol). The connected browser instance is stored in a global
dictionary for later reference.

.PARAMETER WsEndpoint
The WebSocket URL for connecting to the browser's debugging port. This URL
typically follows the format 'ws://hostname:port/devtools/browser/<id>'.

.EXAMPLE
Connect-PlaywrightViaDebuggingPort `
    -WsEndpoint "ws://localhost:9222/devtools/browser/abc123"
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

        # log the connection attempt with the provided endpoint
        Write-Verbose "Attempting to connect to browser at: $WsEndpoint"
    }

    process {
        try {
            # initialize a new playwright instance asynchronously
            Write-Verbose "Creating Playwright instance"
            $playwright = [Microsoft.Playwright.Playwright]::CreateAsync().Result

            # establish CDP connection to the browser using the websocket endpoint
            Write-Verbose "Connecting to browser via CDP"
            $browser = $playwright.Chromium.ConnectOverCDPAsync($WsEndpoint).Result

            # store the browser instance in global dictionary for later access
            Write-Verbose "Storing browser instance in global dictionary"
            $Global:GenXdevPlaywrightBrowserDictionary[$WsEndpoint] = $browser

            # return the connected browser instance to the caller
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
