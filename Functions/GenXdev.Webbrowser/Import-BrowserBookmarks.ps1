################################################################################

<#
.SYNOPSIS
Imports bookmarks from a json file into a browser.

.DESCRIPTION
The `Import-BrowserBookmarks` cmdlet imports bookmarks from a json file into Microsoft Edge or Google Chrome.

.PARAMETER InputFile
Specifies the path to the json file containing the bookmarks to import.

.PARAMETER Bookmarks
Specifies a collection of bookmarks to import.

.PARAMETER Edge
Imports bookmarks into Microsoft Edge.

.PARAMETER Chrome
Imports bookmarks into Google Chrome.

.PARAMETER Firefox
(Not supported) Importing bookmarks into Firefox is currently not supported by this cmdlet.

.EXAMPLE
Import-BrowserBookmarks -InputFile "C:\Bookmarks.csv" -Edge

This command imports bookmarks from the specified CSV file into Edge.

.NOTES
For Edge and Chrome, the bookmarks are added to the 'Bookmarks Bar'. Importing into Firefox is currently not supported.
#>
function Import-BrowserBookmarks {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ParameterSetName = 'FromFile',
            HelpMessage = "Path to CSV file with bookmarks to import"
        )]
        [string]$InputFile,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ParameterSetName = 'FromCollection',
            HelpMessage = "Collection of bookmarks to import"
        )]
        [array]$Bookmarks,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Import into Google Chrome"
        )]
        [switch]$Chrome,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Import into Microsoft Edge"
        )]
        [switch]$Edge,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Import into Firefox (not supported)"
        )]
        [switch]$Firefox
        ########################################################################
    )

    begin {

        # ensure expand-path is available
        if (-not (Get-Command -Name Expand-Path -ErrorAction SilentlyContinue)) {
            Import-Module GenXdev.FileSystem
        }

        # get list of installed browsers
        $installedBrowsers = Get-Webbrowser
    }

    process {

        # get bookmarks from input source
        $importedBookmarks = if ($Bookmarks) {
            Write-Verbose "Using provided bookmarks collection"
            $Bookmarks
        }
        elseif ($InputFile) {
            Write-Verbose "Reading bookmarks from CSV file: $InputFile"
            Import-Csv -Path (Expand-Path $InputFile)
        }
        else {
            Write-Host "Please provide either an InputFile or Bookmarks collection."
            return
        }

        # if no browser specified, use default
        if (-not $Edge -and -not $Chrome -and -not $Firefox) {
            $defaultBrowser = Get-DefaultWebbrowser
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
                Write-Host "Default browser is not Edge, Chrome, or Firefox."
                return
            }
        }

        # write bookmarks based on selected browser
        if ($Edge) {
            $browser = $installedBrowsers |
                Where-Object { $PSItem.Name -like '*Edge*' }

            if (-not $browser) {
                Write-Host "Microsoft Edge is not installed."
                return
            }

            $bookmarksFilePath = Join-Path -Path $env:LOCALAPPDATA `
                -ChildPath 'Microsoft\Edge\User Data\Default\Bookmarks'

            Write-Verbose "Writing bookmarks to Edge at: $bookmarksFilePath"
            Write-Bookmarks -BookmarksFilePath $bookmarksFilePath `
                -BookmarksToWrite $importedBookmarks
        }
        elseif ($Chrome) {
            $browser = $installedBrowsers |
                Where-Object { $PSItem.Name -like '*Chrome*' }

            if (-not $browser) {
                Write-Host "Google Chrome is not installed."
                return
            }

            $bookmarksFilePath = Join-Path -Path $env:LOCALAPPDATA `
                -ChildPath 'Google\Chrome\User Data\Default\Bookmarks'

            Write-Verbose "Writing bookmarks to Chrome at: $bookmarksFilePath"
            Write-Bookmarks -BookmarksFilePath $bookmarksFilePath `
                -BookmarksToWrite $importedBookmarks
        }
        elseif ($Firefox) {
            Write-Host "Firefox import not supported"
        }
        else {
            Write-Host "Please specify -Chrome, -Edge, or -Firefox switch."
        }
    }

    end {
    }
}

function Write-Bookmarks {
    param (
        [string]$BookmarksFilePath,
        [array]$BookmarksToWrite
    )

    if ($Edge -or $Chrome) {
        $bookmarksContent = if (Test-Path $BookmarksFilePath) {
            Get-Content -Path $BookmarksFilePath -Raw | ConvertFrom-Json
        }
        else {
            @{
                roots = @{
                    bookmark_bar = @{children = @() }
                    other        = @{children = @() }
                    synced       = @{children = @() }
                }
            }
        }

        foreach ($bookmark in $BookmarksToWrite) {
            $newBookmark = @{
                type          = "url"
                name          = $bookmark.Name
                url           = $bookmark.URL
                date_added    = if ($bookmark.DateAdded) {
                    [string]$bookmark.DateAdded.ToFileTimeUtc()
                }
                else {
                    [string][DateTime]::UtcNow.ToFileTimeUtc()
                }
                date_modified = if ($bookmark.DateModified) {
                    [string]$bookmark.DateModified.ToFileTimeUtc()
                }
                else {
                    $null
                }
            }

            # Determine the folder to add the bookmark to
            $folderPath = $bookmark.Folder -split '\\'
            $currentNode = $bookmarksContent.roots.bookmark_bar

            foreach ($folder in $folderPath) {
                if ($folder -eq 'Bookmarks Bar') {
                    $currentNode = $bookmarksContent.roots.bookmark_bar
                }
                elseif ($folder -eq 'Other Bookmarks') {
                    $currentNode = $bookmarksContent.roots.other
                }
                elseif ($folder -eq 'Synced Bookmarks') {
                    $currentNode = $bookmarksContent.roots.synced
                }
                else {
                    $existingFolder = $currentNode.children | Where-Object { $PSItem.type -eq 'folder' -and $PSItem.name -eq $folder }
                    if ($existingFolder) {
                        $currentNode = $existingFolder
                    }
                    else {
                        $newFolder = @{
                            type     = 'folder'
                            name     = $folder
                            children = @()
                        }
                        $currentNode.children += $newFolder
                        $currentNode = $newFolder
                    }
                }
            }

            # Add the new bookmark to the determined folder
            $currentNode.children += $newBookmark

            $bookmarksContent | ConvertTo-Json -Depth 100 | Set-Content -Path $BookmarksFilePath
        }
        elseif ($Firefox) {
            Write-Host "Importing bookmarks to Firefox is currently not supported in this script."
            # Note: Importing bookmarks to Firefox would require SQLite operations to modify the places.sqlite file, which is more complex and not covered here.
        }
    }
}
################################################################################
