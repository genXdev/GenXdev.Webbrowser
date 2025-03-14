################################################################################
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
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    param()

    begin {
        Write-Verbose "Starting Get-EdgeRemoteDebuggingPort"
    }

    process {
        # set default edge debugging port
        [int] $port = 9223

        # check if user has configured a custom port in global scope
        if ($Global:EdgeDebugPort) {
            Write-Verbose "Found global EdgeDebugPort configuration"

            # attempt to parse the configured port value, keeping default if invalid
            if ([int]::TryParse($Global:EdgeDebugPort, [ref] $port)) {
                Write-Verbose "Using configured port: $port"
            }
            else {
                Write-Verbose "Invalid port config, using default: $port"
            }
        }
        else {
            Write-Verbose "No custom port configured, using default: $port"
        }

        # ensure global variable matches returned port for consistency
        $null = Set-Variable `
            -Name EdgeDebugPort `
            -Value $port `
            -Scope Global

        # return the resolved port number
        return $port
    }

    end {
        Write-Verbose "Completed Get-EdgeRemoteDebuggingPort"
    }
}
################################################################################