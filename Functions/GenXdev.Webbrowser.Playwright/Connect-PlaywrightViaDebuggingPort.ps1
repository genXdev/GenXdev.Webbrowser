<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser.Playwright
Original cmdlet filename  : Connect-PlaywrightViaDebuggingPort.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.300.2025
################################################################################
Copyright (c)  René Vaessen / GenXdev

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
################################################################################>
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
dictionary for later reference. Automatically handles consent for
Microsoft.Playwright NuGet package installation.

.PARAMETER WsEndpoint
The WebSocket URL for connecting to the browser's debugging port. This URL
typically follows the format 'ws://hostname:port/devtools/browser/<id>'.

.PARAMETER ForceConsent
Force consent for third-party software installation without prompting.

.PARAMETER ConsentToThirdPartySoftwareInstallation
Provide consent to third-party software installation.

.EXAMPLE
Connect-PlaywrightViaDebuggingPort `
    -WsEndpoint "ws://localhost:9222/devtools/browser/abc123"

.EXAMPLE
Connect-PlaywrightViaDebuggingPort `
    -WsEndpoint "ws://localhost:9222/devtools/browser/abc123" `
    -ConsentToThirdPartySoftwareInstallation
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
        [string]$WsEndpoint,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force consent for third-party software installation'
        )]
        [switch]$ForceConsent,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Consent to third-party software installation'
        )]
        [switch]$ConsentToThirdPartySoftwareInstallation
        ########################################################################
    )

    begin {
        # log connection attempt for debugging purposes
        Microsoft.PowerShell.Utility\Write-Verbose "Attempting to connect to browser at: $WsEndpoint"

        # prepare parameters for EnsureNuGetAssembly with embedded consent
        $params = GenXdev.FileSystem\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.Helpers\EnsureNuGetAssembly' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

        GenXdev.Helpers\EnsureNuGetAssembly -PackageKey 'Microsoft.Playwright' `
            -Description 'Browser automation library required for connecting to browser instances via CDP' `
            -Publisher 'Microsoft' @params

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