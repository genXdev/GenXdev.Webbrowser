################################################################################
<#
.SYNOPSIS
Returns the remote debugging port for the system's default Chromium browser.

.DESCRIPTION
Detects whether Microsoft Edge or Google Chrome is the default browser and
returns the appropriate debugging port number. If Chrome is the default browser,
returns the Chrome debugging port. Otherwise returns the Edge debugging port
(also used when no default browser is detected).

.OUTPUTS
[int] The remote debugging port number for the detected browser.

.EXAMPLE
# Get debugging port using full command name
Get-ChromiumRemoteDebuggingPort

.EXAMPLE
# Get debugging port using alias
Get-BrowserDebugPort
#>
function Get-ChromiumRemoteDebuggingPort {

    [CmdletBinding()]
    [OutputType([int])]
    [Alias('Get-BrowserDebugPort')]
    param(

        [switch] $Chrome,
        [switch] $Edge
    )
    ############################################################################

    begin {
        # verbose output to indicate start of browser detection
        Write-Verbose "Starting detection of default Chromium browser type"

        # get the system's default browser information
        $defaultBrowser = Get-DefaultWebbrowser

        # log the detected default browser name
        Write-Verbose ("Default browser detected: {0}" -f `
            $(if ($null -eq $defaultBrowser) { 'None' }
                else { $defaultBrowser.Name }))
    }

    process {

        if ($Chrome) {
            # return chrome debugging port
            Write-Verbose "Using Chrome debugging port"
            Get-ChromeRemoteDebuggingPort
            return;
        }

        if ($Edge) {
            # return edge debugging port
            Write-Verbose "Using Edge debugging port"
            Get-EdgeRemoteDebuggingPort
            return;
        }

        # determine and return appropriate debugging port based on browser
        if (($null -ne $defaultBrowser) -and
            ($defaultBrowser.Name -like "*Chrome*")) {

            # chrome is default - return chrome debugging port
            Write-Verbose "Using Chrome debugging port"
            Get-ChromeRemoteDebuggingPort
        }
        else {

            # edge is default or no browser - return edge debugging port
            Write-Verbose "Using Edge debugging port"
            Get-EdgeRemoteDebuggingPort
        }
    }

    end {
    }
}
################################################################################