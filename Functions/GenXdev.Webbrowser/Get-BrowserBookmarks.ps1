################################################################################
<#
.SYNOPSIS
Returns all bookmarks from installed web browsers.

.DESCRIPTION
Retrieves bookmarks from Microsoft Edge, Google Chrome, or Mozilla Firefox
browsers installed on the system. The function can filter by browser type and
returns detailed bookmark information including name, URL, folder location, and
timestamps.

.PARAMETER Chrome
Retrieves bookmarks specifically from Google Chrome browser.

.PARAMETER Edge
Retrieves bookmarks specifically from Microsoft Edge browser.

.PARAMETER Firefox
Retrieves bookmarks specifically from Mozilla Firefox browser.

.EXAMPLE
Get-BrowserBookmarks -Edge | Format-Table Name, URL, Folder
Returns Edge bookmarks formatted as a table showing name, URL and folder.

.EXAMPLE
gbm -Chrome | Where-Object URL -like "*github*"
Returns Chrome bookmarks filtered to only show GitHub-related URLs.
#>
function Get-BrowserBookmarks {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [Alias('gbm')]

    param (
        ########################################################################
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Chrome',
            Position = 0,
            HelpMessage = "Returns bookmarks from Google Chrome"
        )]
        [switch] $Chrome,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Edge',
            Position = 0,
            HelpMessage = "Returns bookmarks from Microsoft Edge"
        )]
        [switch] $Edge,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Firefox',
            Position = 0,
            HelpMessage = "Returns bookmarks from Mozilla Firefox"
        )]
        [switch] $Firefox
    )

    begin {

        # ensure filesystem module is loaded for path handling
        if (-not (Get-Command -Name Expand-Path -ErrorAction SilentlyContinue)) {
            Import-Module GenXdev.FileSystem
        }

        Write-Verbose "Getting installed browsers..."

        # get list of installed browsers for validation
        $installedBrowsers = Get-Webbrowser

        # if no specific browser selected, use system default
        if (-not $Edge -and -not $Chrome -and -not $Firefox) {

            Write-Verbose "No browser specified, detecting default browser..."
            $defaultBrowser = Get-DefaultWebbrowser

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
                Write-Warning "Default browser is not Edge, Chrome, or Firefox."
                return
            }
        }
    }

    process {

        # helper function to parse Chromium-based browser bookmarks
        function Get-ChromiumBookmarks {
            param (
                [string] $bookmarksFilePath,
                [string] $rootFolderName,
                [string] $browserName
            )

            if (-not (Test-Path $bookmarksFilePath)) {
                Write-Verbose "Bookmarks file not found: $bookmarksFilePath"
                return @()
            }

            # read bookmarks json file
            $bookmarksContent = Get-Content -Path $bookmarksFilePath -Raw |
            ConvertFrom-Json

            $bookmarks = [System.Collections.Generic.List[object]]::new()

            # recursive function to traverse bookmark tree
            function ParseBookmarkFolder {
                param (
                    [pscustomobject] $folder,
                    [string] $parentFolder = ""
                )

                foreach ($item in $folder.children) {
                    if ($item.type -eq "folder") {
                        ParseBookmarkFolder -Folder $item `
                            -ParentFolder ($parentFolder + "\" + $item.name)
                    }
                    elseif ($item.type -eq "url") {
                        $bookmarks.Add([pscustomobject]@{
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
        function Get-FirefoxBookmarks {
            param (
                [string] $placesFilePath,
                [string] $browserName
            )

            if (-not (Test-Path $placesFilePath)) {
                Write-Verbose "Firefox places.sqlite not found: $placesFilePath"
                return @()
            }

            $connectionString = "Data Source=$placesFilePath;Version=3;"
            $query = @"
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
"@

            $bookmarks = @()

            try {

                $connection = New-Object System.Data.SQLite.SQLiteConnection($connectionString)
                $connection.Open()
                $command = $connection.CreateCommand()
                $command.CommandText = $query
                $reader = $command.ExecuteReader()

                while ($reader.Read()) {
                    $bookmarks += [pscustomobject]@{
                        Name          = $reader["title"]
                        URL           = $reader["url"]
                        Folder        = $reader["Folder"]
                        DateAdded     = [DateTime]::FromFileTimeUtc($reader["dateAdded"])
                        DateModified  = [DateTime]::FromFileTimeUtc($reader["lastModified"])
                        BrowserSource = $browserName
                    }
                }

                $reader.Close()
                $connection.Close()
            }
            catch {
                Write-Host "Error reading Firefox bookmarks: $PSItem"
            }

            return $bookmarks
        }

        Write-Verbose "Processing browser selection..."

        if ($Edge) {
            # validate Edge installation
            $browser = $installedBrowsers |
            Where-Object { $PSItem.Name -like '*Edge*' }

            if (-not $browser) {
                Write-Warning "Microsoft Edge is not installed."
                return
            }

            # construct path to Edge bookmarks file
            $bookmarksFilePath = Join-Path `
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
            $browser = $installedBrowsers | Where-Object { $PSItem.Name -like '*Chrome*' }
            if (-not $browser) {
                Write-Host "Google Chrome is not installed."
                return
            }
            # construct path to Chrome bookmarks file
            $bookmarksFilePath = Join-Path -Path "${env:LOCALAPPDATA}" -ChildPath 'Google\Chrome\User Data\Default\Bookmarks'
            $rootFolderName = 'Chrome'
            # get Chrome bookmarks
            $bookmarks = Get-ChromiumBookmarks -bookmarksFilePath $bookmarksFilePath -rootFolderName $rootFolderName -browserName ($browser.Name)
        }
        elseif ($Firefox) {
            # validate Firefox installation
            $browser = $installedBrowsers | Where-Object { $PSItem.Name -like '*Firefox*' }
            if (-not $browser) {
                Write-Host "Mozilla Firefox is not installed."
                return
            }
            # find Firefox profile folder
            $profileFolderPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
            $profileFolder = Get-ChildItem -Path $profileFolderPath -Directory | Where-Object { $PSItem.Name -match '\.default-release$' } | Select-Object -First 1
            if ($null -eq $profileFolder) {
                Write-Host 'Firefox profile folder not found.'
                return
            }
            # construct path to Firefox places.sqlite file
            $placesFilePath = Join-Path -Path $profileFolder.FullName -ChildPath 'places.sqlite'
            # get Firefox bookmarks
            $bookmarks = Get-FirefoxBookmarks -placesFilePath $placesFilePath -browserName ($browser.Name)
        }
        else {
            Write-Warning 'Please specify either -Chrome, -Edge, or -Firefox switch.'
            return
        }

        return $bookmarks
    }

    end {
    }
}
################################################################################
