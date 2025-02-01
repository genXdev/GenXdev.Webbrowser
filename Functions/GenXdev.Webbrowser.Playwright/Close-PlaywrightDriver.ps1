################################################################################
using namespace System.Management.Automation
using namespace System.Collections.Concurrent
using namespace Microsoft.Playwright

<#
.SYNOPSIS
Closes a Playwright browser instance and removes it from the global cache.

.DESCRIPTION
This function safely closes a previously opened Playwright browser instance and
removes its reference from the global browser dictionary. It ensures proper
cleanup of browser resources and handles errors gracefully.

.PARAMETER BrowserType
The type of browser to close (Chromium, Firefox, or Webkit).

.PARAMETER ReferenceKey
The unique identifier for the browser instance in the cache. Defaults to
"Default" if not specified.

.EXAMPLE
Close-PlaywrightDriver -BrowserType Chromium -ReferenceKey "MainBrowser"

.EXAMPLE
Close-PlaywrightDriver Chrome Default
#>
function Close-PlaywrightDriver {

    [CmdletBinding()]
    param (
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = "The type of browser to close"
        )]
        [ValidateSet("Chromium", "Firefox", "Webkit")]
        [string]$BrowserType = "Chromium",
        ########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "The unique key identifying the browser instance"
        )]
        [ValidateNotNullOrEmpty()]
        [string]$ReferenceKey = "Default"
        ########################################################################
    )

    begin {

        # ensure the browser cache is initialized and up to date
        Update-PlaywrightDriverCache

        # Write-Verbose "Attempting to close browser [$BrowserType] with key: $ReferenceKey"
    }

    process {

        # normalize the reference key to ensure consistent caching
        $referenceKey = [string]::IsNullOrWhiteSpace($ReferenceKey) ?
        "Default" : $ReferenceKey

        # attempt to retrieve the browser instance from the global dictionary
        $browser = $null
        if ($Global:GenXdevPlaywrightBrowserDictionary.TryGetValue(
                $referenceKey, [ref]$browser)) {

            try {
                # attempt to gracefully close the browser instance
                # Write-Verbose "Closing browser instance..."
                $null = $browser.CloseAsync().Wait()
            }
            catch {
                Write-Warning "Failed to close browser: $_"
            }
            finally {
                # remove the browser reference from the global dictionary
                $null = $Global:GenXdevPlaywrightBrowserDictionary.TryRemove(
                    $referenceKey, [ref]$browser)
            }
        }
        else {
            # Write-Verbose "No browser instance found for key: $ReferenceKey"
        }
    }

    end {
    }
}
################################################################################
