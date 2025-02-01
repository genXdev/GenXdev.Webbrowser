################################################################################
<#
.SYNOPSIS
Returns the configured remote debugging port for Google Chrome.

.DESCRIPTION
Retrieves the remote debugging port number for Google Chrome browser. If no port 
is specified via $Global:ChromeDebugPort, defaults to port 9222. The port 
number is stored in the global scope for use by other functions.

.OUTPUTS
System.Int32
Returns the configured debug port number.

.EXAMPLE
Get-ChromeRemoteDebuggingPort
# Returns the configured debug port (default 9222)
#>
function Get-ChromeRemoteDebuggingPort {

    [CmdletBinding()]
    [OutputType([System.Int32])]
    [Alias("Get-ChromePort")]

    param()

    begin {

        # initialize port variable with default value
        [int] $port = 9222
    }

    process {

        # attempt to get custom port from global variable if it exists
        if ($Global:ChromeDebugPort) {
            
            # try to parse the global port variable
            if ([int]::TryParse($Global:ChromeDebugPort, [ref] $port)) {
                
                Write-Verbose "Using configured Chrome debug port: $port"
            }
            else {
                
                Write-Verbose "Invalid port config, using default port: $port"
            }
        }
        else {
            
            Write-Verbose "No custom port configured, using default port: $port"
        }

        # ensure port is set in global scope
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
