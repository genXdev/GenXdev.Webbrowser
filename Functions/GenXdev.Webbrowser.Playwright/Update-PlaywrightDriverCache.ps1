################################################################################
using namespace System.Management.Automation
using namespace System.Collections.Concurrent
using namespace Microsoft.Playwright

<#
.SYNOPSIS
Maintains the Playwright browser instance cache by removing stale entries.

.DESCRIPTION
This function performs maintenance on browser instances by removing any that are
either null or have become disconnected. This helps prevent memory leaks and
ensures the cache remains healthy.

.PARAMETER BrowserDictionary
The concurrent dictionary containing browser instances to maintain.

.EXAMPLE
# Clean up disconnected browser instances from the cache
Update-PlaywrightDriverCache -BrowserDictionary $browserDictionary
#>
function Update-PlaywrightDriverCache {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ConcurrentDictionary[string, IBrowser]]
        $BrowserDictionary
    )

    begin {

        # log the start of cache cleanup operation
        Write-Verbose "Starting Playwright browser cache maintenance"
    }

    process {

        try {
            # iterate through all browser instances and remove stale ones
            $BrowserDictionary.GetEnumerator() |
            ForEach-Object {

                # output verbose info about current instance being checked
                Write-Verbose "Checking browser instance: $($_.Key)"

                # check if browser instance is null or disconnected
                if ($null -eq $_.Value -or -not $_.Value.IsConnected) {

                    if ($PSCmdlet.ShouldProcess(
                            "Browser instance $($_.Key)",
                            "Remove inactive browser instance")) {

                        Write-Verbose "Removing instance: $($_.Key)"
                        $null = $BrowserDictionary.TryRemove(
                            $_.Key,
                            [ref]$null
                        )
                    }
                }
            }
        }
        catch {
            Write-Error "Failed to update browser cache: $_"
            throw
        }
    }

    end {

        Write-Verbose "Completed browser cache maintenance"
    }
}
################################################################################