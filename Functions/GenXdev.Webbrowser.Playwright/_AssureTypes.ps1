# using namespace System.Management.Automation
# using namespace System.Collections.Concurrent
# using namespace Microsoft.Playwright

# Add required assemblies
Add-Type -Path (Join-Path $PSScriptRoot '..\..\..\..\GenXdev.Helpers\1.102.2025\lib\Microsoft.Playwright.dll')
Add-Type -Path (Join-Path $PSScriptRoot '..\..\..\..\GenXdev.Helpers\1.102.2025\lib\Microsoft.Playwright.TestAdapter.dll')

# Playwright module using debugging port
$Global:GenXdevPlaywrightBrowserDictionary = [System.Collections.Concurrent.ConcurrentDictionary[string, Microsoft.Playwright.IBrowser]]::new()

# Initialize Playwright on module load
# $null = [Microsoft.Playwright.Playwright]::InstallAsync().Wait()
