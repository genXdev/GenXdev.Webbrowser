<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser
Original cmdlet filename  : Get-EdgeRemoteDebuggingPort.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.268.2025
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
###############################################################################
<#
.SYNOPSIS
Returns the configured remote debugging port for Microsoft Edge browser.

.DESCRIPTION
Retrieves the remote debugging port number used for connecting to Microsoft Edge
browser's debugging interface. If no custom port is configured via the global
variable $Global:EdgeDebugPort, returns the default port 9223. The function
validates any custom port configuration and falls back to the default if invalid.

.OUTPUTS
System.Int32
Returns the port number to use for Edge remote debugging

.EXAMPLE
Get-EdgeRemoteDebuggingPort
Returns the configured debug port (default 9223 if not configured)

.NOTES
The function ensures $Global:EdgeDebugPort is always set to the returned value
for consistency across the session.
#>
function Get-EdgeRemoteDebuggingPort {

    [CmdletBinding()]
    [OutputType([int])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    param()

    begin {
        Microsoft.PowerShell.Utility\Write-Verbose 'Starting Get-EdgeRemoteDebuggingPort'
    }


    process {
        # set default edge debugging port
        [int] $port = 9223

        # check if user has configured a custom port in global scope
        if ($Global:EdgeDebugPort) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Found global EdgeDebugPort configuration'

            # attempt to parse the configured port value, keeping default if invalid
            if ([int]::TryParse($Global:EdgeDebugPort, [ref] $port)) {
                Microsoft.PowerShell.Utility\Write-Verbose "Using configured port: $port"
            }
            else {
                Microsoft.PowerShell.Utility\Write-Verbose "Invalid port config, using default: $port"
            }
        }
        else {
            Microsoft.PowerShell.Utility\Write-Verbose "No custom port configured, using default: $port"
        }

        # ensure global variable matches returned port for consistency
        $null = Microsoft.PowerShell.Utility\Set-Variable `
            -Name EdgeDebugPort `
            -Value $port `
            -Scope Global

        # return the resolved port number
        return $port
    }

    end {
        Microsoft.PowerShell.Utility\Write-Verbose 'Completed Get-EdgeRemoteDebuggingPort'
    }
}