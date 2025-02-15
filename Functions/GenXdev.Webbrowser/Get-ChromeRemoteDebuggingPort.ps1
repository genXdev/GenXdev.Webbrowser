################################################################################
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
    [Alias("Get-ChromePort")]

    param()

    begin {

        # initialize the default chrome debugging port
        [int] $port = 9222
    }

    process {

        # check if a custom port is configured in the global scope
        if ($Global:ChromeDebugPort) {

            # attempt to parse the global port value to ensure it's a valid number
            if ([int]::TryParse($Global:ChromeDebugPort, [ref] $port)) {

                # log successful use of custom port
                Write-Verbose "Using configured Chrome debug port: $port"
            }
            else {

                # log fallback to default port due to invalid configuration
                Write-Verbose "Invalid port config, using default port: $port"
            }
        }
        else {

            # log use of default port when no custom port is configured
            Write-Verbose "No custom port configured, using default port: $port"
        }

        # ensure the port is available in global scope for other functions
        $null = Set-Variable `
            -Name ChromeDebugPort `
            -Value $port `
            -Scope Global
    }

    end {

        return $port
    }
}
################################################################################
