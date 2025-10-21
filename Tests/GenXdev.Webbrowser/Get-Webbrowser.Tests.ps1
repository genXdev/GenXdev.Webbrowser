###############################################################################
# Part of PowerShell module : GenXdev.Webbrowser
# Original cmdlet filename  : Get-Webbrowser.Tests.ps1
# Original author           : René Vaessen / GenXdev
# Version                   : 1.304.2025
###############################################################################

Pester\BeforeAll {
    # Import the module for testing
    Microsoft.PowerShell.Core\Import-Module GenXdev.Webbrowser -Force
}

Pester\Describe "Get-Webbrowser" {

    Pester\It "Should return Microsoft Edge with msedge.exe path" {
        $browsers = GenXdev.Webbrowser\Get-Webbrowser
        $edgeBrowser = $browsers | Microsoft.PowerShell.Core\Where-Object { $_.Name -like "*Edge*" }

        $edgeBrowser | Pester\Should -Not -BeNullOrEmpty
        $edgeBrowser.Path | Pester\Should -Match "msedge\.exe"
    }
}
