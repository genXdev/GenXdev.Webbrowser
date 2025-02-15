################################################################################
using namespace System.Management.Automation
using namespace System.Collections.Concurrent
using namespace Microsoft.Playwright

<#
.SYNOPSIS
Closes a Playwright browser instance and removes it from the global cache.

.DESCRIPTION
This function safely closes a previously opened Playwright browser instance and
removes its reference from the global browser dictionary. The function handles
cleanup of browser resources and provides error handling for graceful shutdown.

.PARAMETER BrowserType
Specifies the type of browser instance to close (Chromium, Firefox, or Webkit).
If not specified, defaults to Chromium.

.PARAMETER ReferenceKey
The unique identifier used to retrieve the browser instance from the global
cache. If not specified, defaults to "Default".

.EXAMPLE
Close-PlaywrightDriver -BrowserType Chromium -ReferenceKey "MainBrowser"
Closes a specific Chromium browser instance identified by "MainBrowser"

.EXAMPLE
Close-PlaywrightDriver Chrome
Closes the default Chromium browser instance using position parameters
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

        # ensure the browser cache dictionary is initialized
        Write-Verbose "Initializing browser cache dictionary"
        Update-PlaywrightDriverCache

    }

    process {

        # normalize the reference key to handle null/empty cases
        Write-Verbose "Processing browser closure for key: $ReferenceKey"
        $referenceKey = [string]::IsNullOrWhiteSpace($ReferenceKey) ?
        "Default" : $ReferenceKey

        # attempt to retrieve the browser instance from cache
        Write-Verbose "Attempting to retrieve browser instance from cache"
        $browser = $null
        if ($Global:GenXdevPlaywrightBrowserDictionary.TryGetValue(
                $referenceKey, [ref]$browser)) {

            try {
                # close the browser instance asynchronously
                Write-Verbose "Closing browser instance..."
                $null = $browser.CloseAsync().Wait()
            }
            catch {
                Write-Warning "Failed to close browser: $_"
            }
            finally {
                # remove the browser reference from the global dictionary
                Write-Verbose "Removing browser reference from cache"
                $null = $Global:GenXdevPlaywrightBrowserDictionary.TryRemove(
                    $referenceKey, [ref]$browser)
            }
        }
        else {
            Write-Verbose "No browser instance found for key: $ReferenceKey"
        }
    }

    end {
    }
}
################################################################################
