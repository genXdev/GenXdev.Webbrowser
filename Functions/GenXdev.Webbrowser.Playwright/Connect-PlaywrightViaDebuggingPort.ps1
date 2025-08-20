###############################################################################
using namespace System.Management.Automation
using namespace System.Collections.Concurrent

###############################################################################
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
###############################################################################>
function Connect-PlaywrightViaDebuggingPort {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = 'WebSocket URL for browser debugging connection'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$WsEndpoint
        ########################################################################
    )

    begin {
        # log connection attempt for debugging purposes
        Microsoft.PowerShell.Utility\Write-Verbose "Attempting to connect to browser at: $WsEndpoint"

        GenXdev.Helpers\EnsureNuGetAssembly -PackageKey 'Microsoft.Playwright'

       $Global:GenXdevPlaywrightBrowserDictionary = $Global:GenXdevPlaywrightBrowserDictionary ?
       $Global:GenXdevPlaywrightBrowserDictionary :
       [System.Collections.Concurrent.ConcurrentDictionary[string, Microsoft.Playwright.IBrowser]]::new()
    }


    process {
        try {
            # create new playwright instance
            Microsoft.PowerShell.Utility\Write-Verbose 'Creating Playwright instance'
            $playwright = [Microsoft.Playwright.Playwright]::CreateAsync().Result

            # connect to browser using CDP protocol
            Microsoft.PowerShell.Utility\Write-Verbose 'Connecting to browser via CDP'
            $browser = $playwright.Chromium.ConnectOverCDPAsync($WsEndpoint).Result

            # store browser instance for module-wide access
            Microsoft.PowerShell.Utility\Write-Verbose 'Storing browser instance in global dictionary'
            $Global:GenXdevPlaywrightBrowserDictionary[$WsEndpoint] = $browser

            return $browser
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Error "Failed to connect via debugging port: $_"
            throw
        }
    }

    end {
    }
}