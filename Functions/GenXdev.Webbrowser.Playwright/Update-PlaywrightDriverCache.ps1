################################################################################
using namespace System.Management.Automation
using namespace System.Collections.Concurrent
using namespace Microsoft.Playwright

<#
.SYNOPSIS
Maintains the Playwright browser instance cache by removing stale entries.

.DESCRIPTION
This function performs maintenance on the global Playwright browser instance
dictionary by removing any browser instances that are either null or have become
disconnected. This helps prevent memory leaks and ensures the cache remains
healthy.

.EXAMPLE
# Clean up disconnected browser instances from the cache
Update-PlaywrightDriverCache
#>
function Update-PlaywrightDriverCache {

    [CmdletBinding()]
    param()

    begin {
        # log the start of cache cleanup operation
        Write-Verbose "Starting Playwright browser cache maintenance"
    }

    process {

        # iterate through all browser instances in the global dictionary and
        # remove any that are null or disconnected
        $Global:GenXdevPlaywrightBrowserDictionary.GetEnumerator() |
        ForEach-Object {

            # output verbose info about current browser instance being checked
            Write-Verbose "Checking browser instance status for ID: $($_.Key)"

            # check if browser instance is null or disconnected
            if ($null -eq $_.Value -or -not $_.Value.IsConnected) {

                # attempt to remove the stale browser instance from dictionary
                Write-Verbose "Removing inactive browser instance: $($_.Key)"
                $null = $Global:GenXdevPlaywrightBrowserDictionary.TryRemove(
                    $_.Key,
                    [ref]$null
                )
            }
        }
    }

    end {
        # log completion of cache cleanup
        Write-Verbose "Completed Playwright browser cache maintenance"
    }
}
################################################################################
