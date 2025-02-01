using namespace System.Management.Automation
using namespace System.Collections.Concurrent
using namespace Microsoft.Playwright

################################################################################
<#
.SYNOPSIS
Maintains the Playwright browser instance cache.

.DESCRIPTION
This function cleans up disconnected or null browser instances from the global
Playwright browser dictionary to prevent memory leaks and maintain cache health.

.EXAMPLE
Update-PlaywrightDriverCache
#>
function Update-PlaywrightDriverCache {

    [CmdletBinding()]
    param()

    begin {
        # Write-Verbose "Starting Playwright driver cache cleanup"
    }

    process {
        # iterate through all browser instances in the global dictionary
        $Global:GenXdevPlaywrightBrowserDictionary.GetEnumerator() |
            ForEach-Object {

                # Write-Verbose "Checking browser instance $($_.Key)"

                # remove browser instances that are null or disconnected
                if ($null -eq $_.Value -or -not $_.Value.IsConnected) {
                    # Write-Verbose "Removing disconnected browser instance $($_.Key)"
                    $null = $Global:GenXdevPlaywrightBrowserDictionary.TryRemove(
                        $_.Key,
                        [ref]$null
                    )
                }
            }
    }

    end {
        # Write-Verbose "Completed Playwright driver cache cleanup"
    }
}
################################################################################
