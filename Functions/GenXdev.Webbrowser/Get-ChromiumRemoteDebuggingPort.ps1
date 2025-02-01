################################################################################

<#
.SYNOPSIS
Returns the configured remote debugging port for the default Chromium browser.

.DESCRIPTION
Returns the configured remote debugging port for either Microsoft Edge or Google
Chrome, depending on which is set as the default browser. If Edge is the default
or no browser is detected, returns the Edge debugging port. Otherwise returns
the Chrome debugging port.

.EXAMPLE
# Get the debugging port using full command name
Get-ChromiumRemoteDebuggingPort

.EXAMPLE
# Get the debugging port using alias
Get-BrowserDebugPort
#>
function Get-ChromiumRemoteDebuggingPort {

    [CmdletBinding()]
    [OutputType([int])]
    [Alias('Get-BrowserDebugPort')]
    param()
    ############################################################################

    begin {

        # output verbose information about starting browser detection
        Write-Verbose "Starting detection of default Chromium browser type"

        # get reference to default browser for later port determination
        $defaultBrowser = Get-DefaultWebbrowser

        # output verbose information about detected browser
        Write-Verbose ("Default browser detected: {0}" -f `
            $(if ($null -eq $defaultBrowser) { 'None' } else { $defaultBrowser.Name }))
    }

    process {

        # determine which debug port to use based on default browser type
        if (($null -ne $defaultBrowser) -and
            ($defaultBrowser.Name -like "*Chrome*")) {

            # chrome is default, use chrome debugging port
            Write-Verbose "Using Chrome debugging port"
            Get-ChromeRemoteDebuggingPort
        }
        else {

            # edge is default or no browser detected, use edge debugging port
            Write-Verbose "Using Edge debugging port"
            Get-EdgeRemoteDebuggingPort
        }
    }

    end {
    }
}
################################################################################
