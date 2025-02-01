################################################################################
<#
.SYNOPSIS
Returns the configured remote debugging port for Microsoft Edge browser.

.DESCRIPTION
Returns the configured remote debugging port for Microsoft Edge browser. Uses a
default port of 9223 if no custom port is configured via $Global:EdgeDebugPort.

.EXAMPLE
Get-EdgeRemoteDebuggingPort
Returns the configured debug port (default 9223 if not configured)

.NOTES
Use $Global:EdgeDebugPort to override default value of 9223
#>
function Get-EdgeRemoteDebuggingPort {

    [CmdletBinding()]
    [OutputType([int])]
    param()

    begin {

        Write-Verbose "Starting Get-EdgeRemoteDebuggingPort"
    }

    process {

        # initialize port variable with default value
        [int] $port = 9223

        # check if global port override exists
        if ($Global:EdgeDebugPort) {
            Write-Verbose "Found global EdgeDebugPort configuration"

            # try parse the configured port value
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

        # ensure global variable is set consistently
        $null = Set-Variable -Name EdgeDebugPort -Value $port -Scope Global

        # return the port number
        return $port
    }

    end {
    }
}
################################################################################
