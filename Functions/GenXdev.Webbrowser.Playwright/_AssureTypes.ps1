################################################################################
using namespace System.Management.Automation
using namespace System.Collections.Concurrent
using namespace Microsoft.Playwright

# load the main Playwright assembly from module's lib folder
Add-Type -Path (Join-Path $PSScriptRoot `
        '..\..\..\..\GenXdev.Helpers\1.118.2025\lib\Microsoft.Playwright.dll')

# load the Playwright test adapter assembly
Add-Type -Path (Join-Path $PSScriptRoot `
        '..\..\..\..\GenXdev.Helpers\1.118.2025\lib\Microsoft.Playwright.TestAdapter.dll')

# initialize thread-safe dictionary to store browser instances
$Global:GenXdevPlaywrightBrowserDictionary = `
    [ConcurrentDictionary[string, IBrowser]]::new()

################################################################################
<#
.SYNOPSIS
Initializes required Playwright types and assemblies for web automation.

.DESCRIPTION
This internal function ensures the required Microsoft Playwright assemblies are
loaded and initializes the global concurrent dictionary used to store browser
instances. The function is called automatically when the module loads and sets up
the foundation for browser automation tasks.

.EXAMPLE
_AssureTypes
#>
function _AssureTypes {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    param()

    begin {
        Write-Verbose "Initializing Playwright types and assemblies..."
    }

    process {
    }

    end {
    }
}
################################################################################
