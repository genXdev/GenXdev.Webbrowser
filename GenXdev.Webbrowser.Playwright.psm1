if (-not $IsWindows) {
    throw "This module only supports Windows 10+ x64 with PowerShell 7.5+ x64"
}

$osVersion = [System.Environment]::OSVersion.Version
$major = $osVersion.Major
$build = $osVersion.Build

if ($major -ne 10) {
    throw "This module only supports Windows 10+ x64 with PowerShell 7.5+ x64"
}


. "$PSScriptRoot\Functions\GenXdev.Webbrowser.Playwright\Close-PlaywrightDriver.ps1"
. "$PSScriptRoot\Functions\GenXdev.Webbrowser.Playwright\Connect-PlaywrightViaDebuggingPort.ps1"
. "$PSScriptRoot\Functions\GenXdev.Webbrowser.Playwright\EnsureTypes.ps1"
. "$PSScriptRoot\Functions\GenXdev.Webbrowser.Playwright\Get-PlaywrightDriver.ps1"
. "$PSScriptRoot\Functions\GenXdev.Webbrowser.Playwright\Get-PlaywrightProfileDirectory.ps1"
. "$PSScriptRoot\Functions\GenXdev.Webbrowser.Playwright\Resume-WebbrowserTabVideo.ps1"
. "$PSScriptRoot\Functions\GenXdev.Webbrowser.Playwright\Stop-WebbrowserVideos.ps1"
. "$PSScriptRoot\Functions\GenXdev.Webbrowser.Playwright\Unprotect-WebbrowserTab.ps1"
. "$PSScriptRoot\Functions\GenXdev.Webbrowser.Playwright\Update-PlaywrightDriverCache.ps1"
