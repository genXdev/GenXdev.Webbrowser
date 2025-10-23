<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser
Original cmdlet filename  : Get-BrowserBookmark.ps1
Original author           : René Vaessen / GenXdev
Version                   : 2.1.2025
################################################################################
Copyright (c)  René Vaessen / GenXdev

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
################################################################################>
###############################################################################
<#
.SYNOPSIS
Returns all bookmarks from installed web browsers.

.DESCRIPTION
Retrieves bookmarks from Microsoft Edge, Google Chrome, or Mozilla Firefox
browsers installed on the system. The function can filter by browser type and
returns detailed bookmark information including name, URL, folder location, and
timestamps. Automatically handles consent for System.Data.SQLite NuGet package
installation when reading Firefox bookmarks.

.PARAMETER Chrome
Retrieves bookmarks specifically from Google Chrome browser.

.PARAMETER Edge
Retrieves bookmarks specifically from Microsoft Edge browser.

.PARAMETER Firefox
Retrieves bookmarks specifically from Mozilla Firefox browser.

.PARAMETER ForceConsent
Force consent for third-party software installation without prompting.

.PARAMETER ConsentToThirdPartySoftwareInstallation
Provide consent to third-party software installation.

.EXAMPLE
Get-BrowserBookmark -Edge | Format-Table Name, URL, Folder
Returns Edge bookmarks formatted as a table showing name, URL and folder.

.EXAMPLE
gbm -Chrome | Where-Object URL -like "*github*"
Returns Chrome bookmarks filtered to only show GitHub-related URLs.

.EXAMPLE
Get-BrowserBookmark -Firefox -ConsentToThirdPartySoftwareInstallation
Returns Firefox bookmarks with automatic consent to SQLite package installation.
#>
function Get-BrowserBookmark {

    [CmdletBinding(DefaultParameterSetName = 'Default')]

    [OutputType([System.Object[]])]
    [Alias('gbm')]
    param (
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = 'Returns bookmarks from Google Chrome'
        )]
        [switch] $Chrome,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = 'Returns bookmarks from Microsoft Edge'
        )]
        [switch] $Edge,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Firefox',
            Position = 2,
            HelpMessage = 'Returns bookmarks from Mozilla Firefox'
        )]
        [switch] $Firefox,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force consent for third-party software installation'
        )]
        [switch]$ForceConsent,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Consent to third-party software installation'
        )]
        [switch]$ConsentToThirdPartySoftwareInstallation
    )

    begin {
        # prepare parameters for EnsureNuGetAssembly with embedded consent
        $params = GenXdev.FileSystem\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.Helpers\EnsureNuGetAssembly' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

        # load SQLite client assembly with embedded consent
        GenXdev.Helpers\EnsureNuGetAssembly -PackageKey 'System.Data.Sqlite' `
            -Description 'Required for reading Firefox bookmark database files' `
            -Publisher 'SQLite Development Team' @params

        # ensure filesystem module is loaded for path handling
        if (-not (Microsoft.PowerShell.Core\Get-Command -Name GenXdev.FileSystem\Expand-Path -ErrorAction SilentlyContinue)) {
            Microsoft.PowerShell.Core\Import-Module GenXdev.FileSystem
        }

        Microsoft.PowerShell.Utility\Write-Verbose 'Getting installed browsers...'

        # get list of installed browsers for validation
        $Script:installedBrowsers = GenXdev.Webbrowser\Get-Webbrowser

        # if no specific browser selected, use system default
        if (-not $Edge -and -not $Chrome -and -not $Firefox) {

            Microsoft.PowerShell.Utility\Write-Verbose 'No browser specified, detecting default browser...'
            $defaultBrowser = GenXdev.Webbrowser\Get-DefaultWebbrowser

            # set appropriate switch based on default browser
            if ($defaultBrowser.Name -like '*Edge*') {
                $Edge = $true
            }
            elseif ($defaultBrowser.Name -like '*Chrome*') {
                $Chrome = $true
            }
            elseif ($defaultBrowser.Name -like '*Firefox*') {
                $Firefox = $true
            }
            else {
                Microsoft.PowerShell.Utility\Write-Warning 'Default browser is not Edge, Chrome, or Firefox.'
                return
            }
        }
    }


    process {

        # helper function to parse Chromium-based browser bookmarks
        function Get-ChromiumBookmarks {

            [CmdletBinding()]
            [OutputType([System.Object[]])]
            [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
            [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
            [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '')]
            param (
                [string] $bookmarksFilePath,
                [string] $rootFolderName,
                [string] $browserName
            )

            if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $bookmarksFilePath)) {
                Microsoft.PowerShell.Utility\Write-Verbose "Bookmarks file not found: $bookmarksFilePath"
                return @()
            }

            # read bookmarks json file
            $bookmarksContent = Microsoft.PowerShell.Management\Get-Content -LiteralPath  $bookmarksFilePath -Raw |
                Microsoft.PowerShell.Utility\ConvertFrom-Json

            $bookmarks = [System.Collections.Generic.List[object]]::new()

            # recursive function to traverse bookmark tree
            function ParseBookmarkFolder {
                param (
                    [pscustomobject] $folder,
                    [string] $parentFolder = ''
                )

                foreach ($item in $folder.children) {
                    if ($item.type -eq 'folder') {
                        ParseBookmarkFolder -Folder $item `
                            -ParentFolder ($parentFolder + '\' + $item.name)
                    }
                    elseif ($item.type -eq 'url') {
                        $null = $bookmarks.Add([pscustomobject]@{
                                Name          = $item.name
                                URL           = $item.url
                                Folder        = $parentFolder
                                DateAdded     = [DateTime]::FromFileTimeUtc(
                                    [int64]$item.date_added
                                )
                                DateModified  = if ($item.PSObject.Properties.Match(
                                        'date_modified')) {
                                    [DateTime]::FromFileTimeUtc(
                                        [int64]$item.date_modified
                                    )
                                }
                                else {
                                    $null
                                }
                                BrowserSource = $browserName
                            })
                    }
                }
            }

            # process each root folder
            ParseBookmarkFolder -Folder $bookmarksContent.roots.bookmark_bar `
                -ParentFolder "$rootFolderName\Bookmarks Bar"
            ParseBookmarkFolder -Folder $bookmarksContent.roots.other `
                -ParentFolder "$rootFolderName\Other Bookmarks"
            ParseBookmarkFolder -Folder $bookmarksContent.roots.synced `
                -ParentFolder "$rootFolderName\Synced Bookmarks"

            return $bookmarks
        }

        # helper function to parse Firefox bookmarks from SQLite
        function Get-FirefoxBookmark {

            [CmdletBinding()]
            [OutputType([System.Object[]])]

            param (
                [string] $placesFilePath,
                [string] $browserName
            )

            if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $placesFilePath)) {
                Microsoft.PowerShell.Utility\Write-Verbose "Firefox places.sqlite not found: $placesFilePath"
                return @()
            }

            $connectionString = "Data Source=$placesFilePath;Version=3;"
            $query = @'
                SELECT
                    b.title,
                    p.url,
                    b.dateAdded,
                    b.lastModified,
                    f.title AS Folder
                FROM moz_bookmarks b
                JOIN moz_places p ON b.fk = p.id
                LEFT JOIN moz_bookmarks f ON b.parent = f.id
                WHERE b.type = 1
'@

            $bookmarks = @()

            try {

                $connection = Microsoft.PowerShell.Utility\New-Object System.Data.Sqlite.SQLiteConnection($connectionString)
                $connection.Open()
                $command = $connection.CreateCommand()
                $command.CommandText = $query
                $reader = $command.ExecuteReader()

                while ($reader.Read()) {
                    $bookmarks += [pscustomobject]@{
                        Name          = $reader['title']
                        URL           = $reader['url']
                        Folder        = $reader['Folder']
                        DateAdded     = [DateTime]::FromFileTimeUtc($reader['dateAdded'])
                        DateModified  = [DateTime]::FromFileTimeUtc($reader['lastModified'])
                        BrowserSource = $browserName
                    }
                }

                $reader.Close()
                $connection.Close()
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Host "Error reading Firefox bookmarks: $PSItem"
            }

            return $bookmarks
        }

        Microsoft.PowerShell.Utility\Write-Verbose 'Processing browser selection...'

        if ($Edge) {
            # validate Edge installation
            $browser = $Script:installedBrowsers |
                Microsoft.PowerShell.Core\Where-Object { $PSItem.Name -like '*Edge*' }

            if (-not $browser) {
                Microsoft.PowerShell.Utility\Write-Warning 'Microsoft Edge is not installed.'
                return
            }

            # construct path to Edge bookmarks file
            $bookmarksFilePath = Microsoft.PowerShell.Management\Join-Path `
                -Path $env:LOCALAPPDATA `
                -ChildPath 'Microsoft\Edge\User Data\Default\Bookmarks'

            $rootFolderName = 'Edge'

            # get Edge bookmarks
            $bookmarks = Get-ChromiumBookmarks `
                -BookmarksFilePath $bookmarksFilePath `
                -RootFolderName $rootFolderName `
                -BrowserName $browser.Name

        }
        elseif ($Chrome) {
            # validate Chrome installation
            $browser = $Script:installedBrowsers | Microsoft.PowerShell.Core\Where-Object { $PSItem.Name -like '*Chrome*' }
            if (-not $browser) {
                Microsoft.PowerShell.Utility\Write-Host 'Google Chrome is not installed.'
                return
            }
            # construct path to Chrome bookmarks file
            $bookmarksFilePath = Microsoft.PowerShell.Management\Join-Path -Path "${env:LOCALAPPDATA}" -ChildPath 'Google\Chrome\User Data\Default\Bookmarks'
            $rootFolderName = 'Chrome'
            # get Chrome bookmarks
            $bookmarks = Get-ChromiumBookmarks -bookmarksFilePath $bookmarksFilePath -rootFolderName $rootFolderName -browserName ($browser.Name)
        }
        elseif ($Firefox) {
            # validate Firefox installation
            $browser = $Script:installedBrowsers | Microsoft.PowerShell.Core\Where-Object { $PSItem.Name -like '*Firefox*' }
            if (-not $browser) {
                Microsoft.PowerShell.Utility\Write-Host 'Mozilla Firefox is not installed.'
                return
            }
            # find Firefox profile folder
            $profileFolderPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
            $profileFolder = Microsoft.PowerShell.Management\Get-ChildItem -LiteralPath  $profileFolderPath -Directory | Microsoft.PowerShell.Core\Where-Object { $PSItem.Name -match '\.default-release$' } | Microsoft.PowerShell.Utility\Select-Object -First 1
            if ($null -eq $profileFolder) {
                Microsoft.PowerShell.Utility\Write-Host 'Firefox profile folder not found.'
                return
            }
            # construct path to Firefox places.sqlite file
            $placesFilePath = Microsoft.PowerShell.Management\Join-Path -Path $profileFolder.FullName -ChildPath 'places.sqlite'
            # get Firefox bookmarks
            $bookmarks = Get-FirefoxBookmark -placesFilePath $placesFilePath -browserName ($browser.Name)
        }
        else {
            Microsoft.PowerShell.Utility\Write-Warning 'Please specify either -Chrome, -Edge, or -Firefox switch.'
            return
        }

        return $bookmarks
    }

    end {
    }
}