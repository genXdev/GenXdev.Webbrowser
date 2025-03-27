#
# Module manifest for module 'GenXdev.Webbrowser'
#
# Generated by: genXdev
#
# Generated on: 27/03/2025
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'GenXdev.Webbrowser.psm1'

# Version number of this module.
ModuleVersion = '1.158.2025'

# Supported PSEditions
CompatiblePSEditions = 'Core'

# ID used to uniquely identify this module
GUID = '2f62080f-0483-4421-8497-b3d433b65175'

# Author of this module
Author = 'genXdev'

# Company or vendor of this module
CompanyName = 'GenXdev'

# Copyright statement for this module
Copyright = 'Copyright 2021-2025 GenXdev'

# Description of the functionality provided by this module
Description = 'A Windows PowerShell module that allows you to run scripts against your casual desktop webbrowser-tab'

# Minimum version of the PowerShell engine required by this module
PowerShellVersion = '7.5.0'

# Name of the PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
ClrVersion = '9.0.1'

# Processor architecture (None, X86, Amd64) required by this module
ProcessorArchitecture = 'Amd64'

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @(@{ModuleName = 'GenXdev.Data'; ModuleVersion = '1.158.2025'; }, 
               @{ModuleName = 'GenXdev.Helpers'; ModuleVersion = '1.158.2025'; }, 
               @{ModuleName = 'GenXdev.Windows'; ModuleVersion = '1.158.2025'; }, 
               @{ModuleName = 'GenXdev.FileSystem'; ModuleVersion = '1.158.2025'; })

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @('GenXdev.Webbrowser.Playwright.psm1')

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Approve-FirefoxDebugging', 
               'Clear-WebbrowserTabSiteApplicationData', 'Close-PlaywrightDriver', 
               'Close-Webbrowser', 'Close-WebbrowserTab', 
               'Connect-PlaywrightViaDebuggingPort', 'Export-BrowserBookmarks', 
               'Find-BrowserBookmark', 'Get-BrowserBookmark', 
               'Get-ChromeRemoteDebuggingPort', 'Get-ChromiumRemoteDebuggingPort', 
               'Get-ChromiumSessionReference', 'Get-DefaultWebbrowser', 
               'Get-EdgeRemoteDebuggingPort', 'Get-PlaywrightDriver', 
               'Get-PlaywrightProfileDirectory', 'Get-Webbrowser', 
               'Get-WebbrowserTabDomNodes', 'Import-BrowserBookmarks', 
               'Invoke-WebbrowserEvaluation', 'Open-BrowserBookmarks', 
               'Open-Webbrowser', 'Resume-WebbrowserTabVideo', 
               'Select-WebbrowserTab', 'Set-BrowserVideoFullscreen', 
               'Set-RemoteDebuggerPortInBrowserShortcuts', 
               'Set-WebbrowserTabLocation', 'Show-WebsiteInAllBrowsers', 
               'Stop-WebbrowserVideos', 'Unprotect-WebbrowserTab', 
               'Update-PlaywrightDriverCache', 'Write-Bookmarks'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = 'bookmarks', 'clearsitedata', 'CloseTab', 'ct', 'et', 'Eval', 'fsvideo', 'gbm', 
               'Get-BrowserDebugPort', 'Get-ChromePort', 'lt', 'Nav', 
               'Select-BrowserTab', 'Show-UrlInAllBrowsers', 'sites', 'ssst', 'st', 'wb', 
               'wbc', 'wbctrl', 'wbsst', 'wbvideoplay', 'wbvideostop', 'wl'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
ModuleList = @('GenXdev.Webbrowser')

# List of all files packaged with this module
FileList = 'GenXdev.Webbrowser.Playwright.psm1', 'GenXdev.Webbrowser.psd1', 
               'GenXdev.Webbrowser.psm1', 'LICENSE', 'license.txt', 'powershell.jpg', 
               'README.md', 
               'Tests\GenXdev.Webbrowser.Playwright\AssureTypes.Tests.ps1', 
               'Tests\GenXdev.Webbrowser.Playwright\Close-PlaywrightDriver.Tests.ps1', 
               'Tests\GenXdev.Webbrowser.Playwright\Connect-PlaywrightViaDebuggingPort.Tests.ps1', 
               'Tests\GenXdev.Webbrowser.Playwright\Get-PlaywrightDriver.Tests.ps1', 
               'Tests\GenXdev.Webbrowser.Playwright\Get-PlaywrightProfileDirectory.Tests.ps1', 
               'Tests\GenXdev.Webbrowser.Playwright\Resume-WebbrowserTabVideo.Tests.ps1', 
               'Tests\GenXdev.Webbrowser.Playwright\Stop-WebbrowserVideos.Tests.ps1', 
               'Tests\GenXdev.Webbrowser.Playwright\Unprotect-WebbrowserTab.Tests.ps1', 
               'Tests\GenXdev.Webbrowser.Playwright\Update-PlaywrightDriverCache.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Approve-FirefoxDebugging.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Clear-WebbrowserTabSiteApplicationData.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Close-Webbrowser.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Close-WebbrowserTab.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Export-BrowserBookmarks.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Find-BrowserBookmark.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Get-BrowserBookmark.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Get-ChromeRemoteDebuggingPort.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Get-ChromiumRemoteDebuggingPort.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Get-ChromiumSessionReference.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Get-DefaultWebbrowser.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Get-EdgeRemoteDebuggingPort.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Get-Webbrowser.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Get-WebbrowserTabDomNodes.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Import-BrowserBookmarks.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Invoke-WebbrowserEvaluation.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Open-BrowserBookmarks.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Open-Webbrowser.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Select-WebbrowserTab.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Set-BrowserVideoFullscreen.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Set-RemoteDebuggerPortInBrowserShortcuts.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Set-WebbrowserTabLocation.Tests.ps1', 
               'Tests\GenXdev.Webbrowser\Show-WebsiteInAllBrowsers.Tests.ps1', 
               'Functions\GenXdev.Webbrowser.Playwright\AssureTypes.ps1', 
               'Functions\GenXdev.Webbrowser.Playwright\Close-PlaywrightDriver.ps1', 
               'Functions\GenXdev.Webbrowser.Playwright\Connect-PlaywrightViaDebuggingPort.ps1', 
               'Functions\GenXdev.Webbrowser.Playwright\Get-PlaywrightDriver.ps1', 
               'Functions\GenXdev.Webbrowser.Playwright\Get-PlaywrightProfileDirectory.ps1', 
               'Functions\GenXdev.Webbrowser.Playwright\Resume-WebbrowserTabVideo.ps1', 
               'Functions\GenXdev.Webbrowser.Playwright\Stop-WebbrowserVideos.ps1', 
               'Functions\GenXdev.Webbrowser.Playwright\Unprotect-WebbrowserTab.ps1', 
               'Functions\GenXdev.Webbrowser.Playwright\Update-PlaywrightDriverCache.ps1', 
               'Functions\GenXdev.Webbrowser\Approve-FirefoxDebugging.ps1', 
               'Functions\GenXdev.Webbrowser\Clear-WebbrowserTabSiteApplicationData.ps1', 
               'Functions\GenXdev.Webbrowser\Close-Webbrowser.ps1', 
               'Functions\GenXdev.Webbrowser\Close-WebbrowserTab.ps1', 
               'Functions\GenXdev.Webbrowser\Export-BrowserBookmarks.ps1', 
               'Functions\GenXdev.Webbrowser\Find-BrowserBookmark.ps1', 
               'Functions\GenXdev.Webbrowser\Get-BrowserBookmark.ps1', 
               'Functions\GenXdev.Webbrowser\Get-ChromeRemoteDebuggingPort.ps1', 
               'Functions\GenXdev.Webbrowser\Get-ChromiumRemoteDebuggingPort.ps1', 
               'Functions\GenXdev.Webbrowser\Get-ChromiumSessionReference.ps1', 
               'Functions\GenXdev.Webbrowser\Get-DefaultWebbrowser.ps1', 
               'Functions\GenXdev.Webbrowser\Get-EdgeRemoteDebuggingPort.ps1', 
               'Functions\GenXdev.Webbrowser\Get-Webbrowser.ps1', 
               'Functions\GenXdev.Webbrowser\Get-WebbrowserTabDomNodes.ps1', 
               'Functions\GenXdev.Webbrowser\Import-BrowserBookmarks.ps1', 
               'Functions\GenXdev.Webbrowser\Invoke-WebbrowserEvaluation.ps1', 
               'Functions\GenXdev.Webbrowser\Open-BrowserBookmarks.ps1', 
               'Functions\GenXdev.Webbrowser\Open-Webbrowser.ps1', 
               'Functions\GenXdev.Webbrowser\Select-WebbrowserTab.ps1', 
               'Functions\GenXdev.Webbrowser\Set-BrowserVideoFullscreen.ps1', 
               'Functions\GenXdev.Webbrowser\Set-RemoteDebuggerPortInBrowserShortcuts.ps1', 
               'Functions\GenXdev.Webbrowser\Set-WebbrowserTabLocation.ps1', 
               'Functions\GenXdev.Webbrowser\Show-WebsiteInAllBrowsers.ps1'

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'Console','Shell','GenXdev'

        # A URL to the license for this module.
        LicenseUri = 'https://raw.githubusercontent.com/genXdev/GenXdev.Webbrowser/main/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://powershell.genxdev.net/#GenXdev.Webbrowser'

        # A URL to an icon representing this module.
        IconUri = 'https://genxdev.net/favicon.ico'

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

 } # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

