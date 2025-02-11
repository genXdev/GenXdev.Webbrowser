################################################################################
using namespace System.Management.Automation
using namespace System.Collections.Concurrent
using namespace Microsoft.Playwright

# add required assemblies from the module's lib folder
Add-Type -Path (Join-Path $PSScriptRoot `
    '..\..\..\..\GenXdev.Helpers\1.110.2025\lib\Microsoft.Playwright.dll')
Add-Type -Path (Join-Path $PSScriptRoot `
    '..\..\..\..\GenXdev.Helpers\1.110.2025\lib\Microsoft.Playwright.TestAdapter.dll')

# initialize concurrent dictionary for storing browser instances
$Global:GenXdevPlaywrightBrowserDictionary = `
    [ConcurrentDictionary[string, IBrowser]]::new()

################################################################################
<#
.SYNOPSIS
Initializes required Playwright types and assemblies.

.DESCRIPTION
This internal function ensures the required Playwright assemblies are loaded and
initializes the global browser dictionary. It is called automatically when the
module loads.

.EXAMPLE
_AssureTypes
#>
function _AssureTypes {

    [CmdletBinding()]
    param()

    begin {
        Write-Verbose "Initializing Playwright types and assemblies..."
    }

    process {
        # nothing to process
    }

    end {
        # initialization handled by module-level code
    }
}
################################################################################
