<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser
Original cmdlet filename  : Get-ChromeRemoteDebuggingPort.ps1
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
<#
.SYNOPSIS
Returns the configured remote debugging port for Google Chrome.

.DESCRIPTION
Retrieves and manages the remote debugging port configuration for Google Chrome.
The function first checks for a custom port number stored in $Global:ChromeDebugPort.
If not found or invalid, it defaults to port 9222. The port number is then stored
globally for use by other Chrome automation functions.

.OUTPUTS
System.Int32
Returns the configured Chrome debugging port number.

.EXAMPLE
$port = Get-ChromeRemoteDebuggingPort
Write-Host "Chrome debug port: $port"

.EXAMPLE
$port = Get-ChromePort
Write-Host "Chrome debug port: $port"
#>
function Get-ChromeRemoteDebuggingPort {

    [CmdletBinding()]
    [OutputType([System.Int32])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]

    param()

    begin {

        # initialize the default chrome debugging port
        [int] $port = 9222
    }


    process {

        # check if a custom port is configured in the global scope
        if ($Global:ChromeDebugPort) {

            # attempt to parse the global port value
            if ([int]::TryParse($Global:ChromeDebugPort, [ref] $port)) {

                Microsoft.PowerShell.Utility\Write-Verbose `
                    -Message "Using configured Chrome debug port: $port"
            }
            else {

                Microsoft.PowerShell.Utility\Write-Verbose `
                    -Message "Invalid port config, using default port: $port"
            }
        }
        else {

            Microsoft.PowerShell.Utility\Write-Verbose `
                -Message "No custom port configured, using default port: $port"
        }

        # ensure the port is available in global scope
        $null = Microsoft.PowerShell.Utility\Set-Variable `
            -Name ChromeDebugPort `
            -Value $port `
            -Scope Global
    }

    end {

        return $port
    }
}