###############################################################################
using namespace System.Management.Automation
using namespace System.Collections.Concurrent
using namespace Microsoft.Playwright

###############################################################################load the main Playwright assembly from module's lib folder
Microsoft.PowerShell.Utility\Add-Type -LiteralPath (Microsoft.PowerShell.Management\Join-Path $PSScriptRoot `
        '..\..\..\..\GenXdev.Helpers\1.226.2025\lib\Microsoft.Playwright.dll')

###############################################################################load the Playwright test adapter assembly
Microsoft.PowerShell.Utility\Add-Type -LiteralPath (Microsoft.PowerShell.Management\Join-Path $PSScriptRoot `
        '..\..\..\..\GenXdev.Helpers\1.226.2025\lib\Microsoft.Playwright.TestAdapter.dll')

###############################################################################initialize thread-safe dictionary to store browser instances
$Global:GenXdevPlaywrightBrowserDictionary = `
    [ConcurrentDictionary[string, IBrowser]]::new()
