#
# Module manifest for module 'GenXdev.Webbrowser'
@{

    # Script module or binary module file associated with this manifest.
    RootModule = 'GenXdev.Webbrowser.psm1'

    # Version number of this module.
    ModuleVersion     = '1.10.0'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID              = '2f62080f-0483-4421-8497-b3d433b65175'

    # Author of this module
    Author            = 'René Vaessen'

    # Company or vendor of this module
    CompanyName       = 'GenXdev'

    # Copyright statement for this module
    Copyright         = 'Copyright (c) 2021 René Vaessen'

    # Description of the functionality provided by this module
    Description       = 'A Windows PowerShell module that allows you to run scripts against your casual desktop webbrowser-tab'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1.19041.906'

    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    DotNetFrameworkVersion = '4.6.1'

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # ClrVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @(@{ModuleName = 'GenXdev.Helpers'; ModuleVersion = '1.10.0'}, @{ModuleName = 'GenXdev.Windows'; ModuleVersion = '1.10.0'}, @{ModuleName = 'GenXdev.FileSystem'; ModuleVersion = '1.10.0'});

    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies = @("System.Windows.Forms", "Newtonsoft.Json.dll", "WebSocket4Net.dll", "SuperSocket.ClientEngine.dll", "GenXdev.Webbrowser.dll")

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = '*' # @("*")

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport   = '*' # = @("*")

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport   = '*'

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    ModuleList        = @("GenXdev.Webbrowser")

    # List of all files packaged with this module
    FileList          = @("GenXdev.Webbrowser.psd1", "GenXdev.Webbrowser.psm1", "LICENSE", "license.txt", "powershell.jpg", "README.md", "Newtonsoft.Json.dll", "WebSocket4Net.dll", "SuperSocket.ClientEngine.dll", "GenXdev.Webbrowser.dll")

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags                     = 'Console', 'Shell', 'GenXdev'

            # A URL to the license for this module.
            LicenseUri               = 'https://raw.githubusercontent.com/renevaessen/GenXdev.Webbrowser/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri               = 'https://github.com/renevaessen/GenXdev.Webbrowser'

            # A URL to an icon representing this module.
            IconUri                  = 'https://genxdev.net/favicon.ico'

            # ReleaseNotes of this module
            # ReleaseNotes = ''

            # Prerelease string of this module
            # Prerelease = ''

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            RequireLicenseAcceptance = $true

            # External dependent modules of this module
            # ExternalModuleDependencies = @()

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    HelpInfoURI       = 'https://github.com/renevaessen/GenXdev.Webbrowser/blob/master/README.md#syntax'

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
}

# PrivateData = @{
#     PSData = @{

#       # ...

#       # !! This field is *ancillary* to the more detailed 'RequiredModules' field and
#       # !! must reference the *same modules*, but by *names only*,
#       # !! in order to automatically install other modules
#       # !! *from the same repository* that this module depends on.
#       # !! To be safe, specify even a *single* name as an *array*
#       # !! (While this is not a general requirement in manifests,
#       # !!  it may be necessary here due to a bug.)
#       ExternalModuleDependencies = @('GenXdev.Windows')
#   }
# }