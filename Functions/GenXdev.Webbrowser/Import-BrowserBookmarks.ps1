###############################################################################

<#
.SYNOPSIS
Imports bookmarks from a file or collection into a web browser.

.DESCRIPTION
Imports bookmarks into Microsoft Edge or Google Chrome from either a CSV file or
a collection of bookmark objects. The bookmarks are added to the browser's
bookmark bar or specified folders. Firefox import is not currently supported.

.PARAMETER InputFile
The path to a CSV file containing bookmarks to import. The CSV should have
columns for Name, URL, Folder, DateAdded, and DateModified.

.PARAMETER Bookmarks
An array of bookmark objects to import. Each object should have properties for
Name, URL, Folder, DateAdded, and DateModified.

.PARAMETER Chrome
Switch to import bookmarks into Google Chrome.

.PARAMETER Edge
Switch to import bookmarks into Microsoft Edge.

.PARAMETER Firefox
Switch to indicate Firefox as target (currently not supported).

.EXAMPLE
Import-BrowserBookmarks -InputFile "C:\MyBookmarks.csv" -Edge
Imports bookmarks from the CSV file into Microsoft Edge.

.EXAMPLE
$bookmarks = @(
    @{
        Name = "Microsoft";
        URL = "https://microsoft.com";
        Folder = "Tech"
    }
)
Import-BrowserBookmarks -Bookmarks $bookmarks -Chrome
Imports a collection of bookmarks into Google Chrome.
#>
function Import-BrowserBookmarks {

    [CmdletBinding(DefaultParameterSetName = 'Default', SupportsShouldProcess)]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param (
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ParameterSetName = 'FromFile',
            HelpMessage = 'Path to CSV file with bookmarks to import'
        )]
        [string]$InputFile,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ParameterSetName = 'FromCollection',
            HelpMessage = 'Collection of bookmarks to import'
        )]
        [array]$Bookmarks,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Import into Google Chrome'
        )]
        [switch]$Chrome,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Import into Microsoft Edge'
        )]
        [switch]$Edge,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Import into Firefox (not supported)'
        )]
        [switch]$Firefox
        ########################################################################
    )

    begin {
        # ensure the GenXdev.FileSystem\Expand-Path cmdlet is available for file operations
        if (-not (Microsoft.PowerShell.Core\Get-Command -Name GenXdev.FileSystem\Expand-Path -ErrorAction SilentlyContinue)) {
            Microsoft.PowerShell.Core\Import-Module GenXdev.FileSystem
        }

        # get list of installed browsers on the system
        $installedBrowsers = GenXdev.Webbrowser\Get-Webbrowser
        Microsoft.PowerShell.Utility\Write-Verbose "Found installed browsers: $($installedBrowsers.Name)"
    }


    process {

        # load bookmarks from either the collection or input file
        $importedBookmarks = if ($Bookmarks) {
            Microsoft.PowerShell.Utility\Write-Verbose "Using provided collection of $($Bookmarks.Count) bookmarks"
            $Bookmarks
        }
        elseif ($InputFile) {
            Microsoft.PowerShell.Utility\Write-Verbose "Reading bookmarks from CSV: $InputFile"
            Microsoft.PowerShell.Utility\Import-Csv -Path (GenXdev.FileSystem\Expand-Path $InputFile)
        }
        else {
            Microsoft.PowerShell.Utility\Write-Host 'Please provide either an InputFile or Bookmarks collection.'
            return
        }

        # determine target browser if none specified
        if (-not $Edge -and -not $Chrome -and -not $Firefox) {
            $defaultBrowser = GenXdev.Webbrowser\Get-DefaultWebbrowser
            Microsoft.PowerShell.Utility\Write-Verbose "No browser specified, using default: $($defaultBrowser.Name)"

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
                Microsoft.PowerShell.Utility\Write-Host 'Default browser is not Edge, Chrome, or Firefox.'
                return
            }
        }

        # handle import for each supported browser
        if ($Edge) {
            $browser = $installedBrowsers |
                Microsoft.PowerShell.Core\Where-Object { $PSItem.Name -like '*Edge*' }

            if (-not $browser) {
                Microsoft.PowerShell.Utility\Write-Host 'Microsoft Edge is not installed.'
                return
            }

            $bookmarksFilePath = Microsoft.PowerShell.Management\Join-Path -Path $env:LOCALAPPDATA `
                -ChildPath 'Microsoft\Edge\User Data\Default\Bookmarks'

            if ($PSCmdlet.ShouldProcess($bookmarksFilePath, 'Import bookmarks to Microsoft Edge')) {
                Microsoft.PowerShell.Utility\Write-Verbose "Writing bookmarks to Edge at: $bookmarksFilePath"
                GenXdev.Webbrowser\Write-Bookmarks -BookmarksFilePath $bookmarksFilePath `
                    -BookmarksToWrite $importedBookmarks
            }
        }
        elseif ($Chrome) {
            $browser = $installedBrowsers |
                Microsoft.PowerShell.Core\Where-Object { $PSItem.Name -like '*Chrome*' }

            if (-not $browser) {
                Microsoft.PowerShell.Utility\Write-Host 'Google Chrome is not installed.'
                return
            }

            $bookmarksFilePath = Microsoft.PowerShell.Management\Join-Path -Path $env:LOCALAPPLOAD `
                -ChildPath 'Google\Chrome\User Data\Default\Bookmarks'

            if ($PSCmdlet.ShouldProcess($bookmarksFilePath, 'Import bookmarks to Google Chrome')) {
                Microsoft.PowerShell.Utility\Write-Verbose "Writing bookmarks to Chrome at: $bookmarksFilePath"
                GenXdev.Webbrowser\Write-Bookmarks -BookmarksFilePath $bookmarksFilePath `
                    -BookmarksToWrite $importedBookmarks
            }
        }
        elseif ($Firefox) {
            Microsoft.PowerShell.Utility\Write-Host 'Firefox import not supported'
        }
        else {
            Microsoft.PowerShell.Utility\Write-Host 'Please specify -Chrome, -Edge, or -Firefox switch.'
        }
    }

    end {
    }
}

###############################################################################helper function to write bookmarks to browser's bookmark file
function Write-Bookmarks {
    [CmdletBinding(SupportsShouldProcess)]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param (
        [Parameter(Mandatory)]
        [string]$BookmarksFilePath,

        [Parameter(Mandatory)]
        [array]$BookmarksToWrite
    )

    if (-not ($Edge -or $Chrome)) { return }

    $bookmarksContent = if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $BookmarksFilePath) {
        Microsoft.PowerShell.Management\Get-Content -LiteralPath  $BookmarksFilePath -Raw | Microsoft.PowerShell.Utility\ConvertFrom-Json
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

    $changes = $false
    foreach ($bookmark in $BookmarksToWrite) {
        if (-not $PSCmdlet.ShouldProcess(
                "$BookmarksFilePath",
                "Add bookmark '$($bookmark.Name)' to $(if($Edge){'Edge'}else{'Chrome'}) at folder '$($bookmark.Folder)'"
            )) { continue }

        $newBookmark = @{
            type          = 'url'
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
                $existingFolder = $currentNode.children | Microsoft.PowerShell.Core\Where-Object { $PSItem.type -eq 'folder' -and $PSItem.name -eq $folder }
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
        $changes = $true
    }

    # Only write file if changes were made and approved
    if ($changes -and $PSCmdlet.ShouldProcess($BookmarksFilePath, 'Save bookmarks file')) {
        $bookmarksContent | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 100 | Microsoft.PowerShell.Management\Set-Content -LiteralPath $BookmarksFilePath
    }
}