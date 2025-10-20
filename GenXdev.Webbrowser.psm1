if (-not $IsWindows) {
    throw "This module only supports Windows 10+ x64 with PowerShell 7.5+ x64"
}

$osVersion = [System.Environment]::OSVersion.Version
$major = $osVersion.Major

if ($major -ne 10) {
    throw "This module only supports Windows 10+ x64 with PowerShell 7.5+ x64"
}



. "$PSScriptRoot\Functions\GenXdev.Webbrowser\Get-BrowserBookmark.ps1"
. "$PSScriptRoot\Functions\GenXdev.Webbrowser\Import-BrowserBookmarks.ps1"
. "$PSScriptRoot\Functions\GenXdev.Webbrowser\Invoke-WebbrowserEvaluation.ps1"
. "$PSScriptRoot\Functions\GenXdev.Webbrowser\Open-BrowserBookmarks.ps1"
. "$PSScriptRoot\Functions\GenXdev.Webbrowser\Open-Webbrowser.ps1"
. "$PSScriptRoot\Functions\GenXdev.Webbrowser\Open-WebbrowserSideBySide.ps1"
. "$PSScriptRoot\Functions\GenXdev.Webbrowser\Select-WebbrowserTab.ps1"
. "$PSScriptRoot\Functions\GenXdev.Webbrowser\Show-WebsiteInAllBrowsers.ps1"
