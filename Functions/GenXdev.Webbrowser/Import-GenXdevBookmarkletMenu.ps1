<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser
Original cmdlet filename  : Import-GenXdevBookmarkletMenu.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.300.2025
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
################################################################################
<#
.SYNOPSIS
Imports GenXdev JavaScript bookmarklets into browser bookmark collections.

.DESCRIPTION
This function scans a directory for GenXdev bookmarklet files with the
.bookmarklet.txt extension and imports them into the specified web browser
as bookmarks. The bookmarklets are placed in browser-specific folders and
can be used as interactive tools in web pages. The function supports Edge,
Chrome, and Firefox browsers and provides a preview mode for safety.

.PARAMETER SnippetsPath
The file system path to the directory containing bookmarklet snippet files.
Each file should have a .bookmarklet.txt extension and contain JavaScript
code that can be executed as a bookmarklet in web browsers.

.PARAMETER TargetFolder
The target browser bookmark folder where the bookmarklets will be imported.
If not specified, the folder is automatically determined based on the
selected browser type. Uses browser-specific default bookmark bar locations.

.PARAMETER Edge
Specifies Microsoft Edge as the target browser for importing bookmarklets.
When used, bookmarklets are placed in the Edge Bookmarks Bar folder for
easy access from the browser toolbar.

.PARAMETER Chrome
Specifies Google Chrome as the target browser for importing bookmarklets.
When used, bookmarklets are placed in the Chrome Bookmarks Bar folder for
easy access from the browser toolbar.

.PARAMETER Firefox
Specifies Mozilla Firefox as the target browser for importing bookmarklets.
When used, bookmarklets are placed in the Firefox bookmarks folder
structure for browser integration.

.PARAMETER WhatIf
Performs a dry run of the import operation without actually creating any
bookmarks. Displays what bookmarklets would be imported and where they
would be placed for verification before executing the actual import.

.EXAMPLE
Import-GenXdevBookmarkletMenu -Edge

Imports all bookmarklet files from the default snippets directory into
Microsoft Edge's bookmark bar folder.

.EXAMPLE
Import-GenXdevBookmarkletMenu -SnippetsPath "C:\MyBookmarklets" -Chrome -WhatIf

Shows what bookmarklets would be imported from the specified path into
Google Chrome without actually performing the import operation.
#>
function Import-GenXdevBookmarkletMenu {

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "Path to directory containing bookmarklet snippet files"
        )]
        [string] $SnippetsPath = "$PSScriptRoot\..\..\Bookmarklets",
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "Target bookmark folder in browser bookmark structure"
        )]
        [string] $TargetFolder = "",
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Import bookmarklets into Microsoft Edge browser"
        )]
        [switch] $Edge,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Import bookmarklets into Google Chrome browser"
        )]
        [switch] $Chrome,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Import bookmarklets into Mozilla Firefox browser"
        )]
        [switch] $Firefox
        ###############################################################################
    )

    begin {

        # validate the snippets directory exists before proceeding
        if (Microsoft.PowerShell.Management\Test-Path $SnippetsPath) {

            # change to the snippets directory for file operations
            Microsoft.PowerShell.Management\Set-Location $SnippetsPath

            Microsoft.PowerShell.Utility\Write-Verbose (
                "Changed directory to snippets path: ${SnippetsPath}"
            )
        }
        else {

            # output error message when snippets directory is not found
            Microsoft.PowerShell.Utility\Write-Error "Snippets path not found: ${SnippetsPath}"

            return
        }
    }

    process {

        # find all bookmarklet files with the expected extension
        $bookmarkletFiles = Microsoft.PowerShell.Management\Get-ChildItem -Filter "*.bookmarklet.txt"

        # check if any bookmarklet files were found in the directory
        if ($bookmarkletFiles.Count -eq 0) {

            Microsoft.PowerShell.Utility\Write-Warning "No bookmarklet files found in ${SnippetsPath}"

            return
        }

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Found $($bookmarkletFiles.Count) snippet files to import"
        )

        # determine target folder path based on selected browser
        if ([string]::IsNullOrEmpty($TargetFolder)) {

            if ($Edge) {

                # set default Edge bookmark bar folder path
                $TargetFolder = "Edge\Bookmarks Bar\▼"

            }
            elseif ($Chrome) {

                # set default Chrome bookmark bar folder path
                $TargetFolder = "Chrome\Bookmarks Bar\▼"

            }
            elseif ($Firefox) {

                # set default Firefox bookmark folder path
                $TargetFolder = "Firefox\▼"

            }
            else {

                # default to Edge browser when no browser is specified
                $TargetFolder = "Edge\Bookmarks Bar\▼"

                $Edge = $true
            }
        }

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Target folder: ${TargetFolder}"
        )

        # create bookmark objects from each bookmarklet file
        $bookmarksToImport = $bookmarkletFiles |
            Microsoft.PowerShell.Core\ForEach-Object {

                # read the javascript content from the bookmarklet file
                $bookmarkletUrl = Microsoft.PowerShell.Management\Get-Content $_.FullName -Raw

                # extract bookmark name by removing the file extension
                $bookmarkName = $_.BaseName -replace '\.bookmarklet$', ''

                # create structured bookmark object for import operation
                [PSCustomObject]@{
                    Name         = $bookmarkName
                    URL          = $bookmarkletUrl.Trim()
                    Folder       = $TargetFolder
                    DateAdded    = $_.CreationTime
                    DateModified = $_.LastWriteTime
                }
            }

        # check if user wants to proceed with the import operation
        if (-not $PSCmdlet.ShouldProcess(
            "Import $($bookmarksToImport.Count) bookmarklets to ${TargetFolder}",
            "Import bookmarklets",
            "Confirm Bookmarklet Import")) {

            return
        }

        # prepare parameters for the import browser bookmarks function
        $importParams = @{
            Bookmarks = $bookmarksToImport
        }

        # add browser-specific parameters to the import operation
        if ($Edge) {
            $importParams.Edge = $true
        }

        if ($Chrome) {
            $importParams.Chrome = $true
        }

        if ($Firefox) {
            $importParams.Firefox = $true
        }

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Importing $($bookmarksToImport.Count) bookmarks to folder " +
            "'${TargetFolder}'"
        )

        # execute the bookmark import operation with error handling
        try {

            GenXdev.Webbrowser\Import-BrowserBookmarks @importParams -Verbose

            Microsoft.PowerShell.Utility\Write-Host (
                "Successfully imported snippets as bookmarks!"
            ) -ForegroundColor Green

            Microsoft.PowerShell.Utility\Write-Host (
                "Check your browser's '${TargetFolder}' folder for the " +
                "imported bookmarks."
            ) -ForegroundColor Cyan

        }
        catch {

            Microsoft.PowerShell.Utility\Write-Error "Failed to import bookmarks: ${_}"
        }
    }

    end {

         # check if user wants to proceed with the import operation
        if (-not $PSCmdlet.ShouldProcess(
            "Close any open browser instances",
            "Close browsers",
            "Confirm Browser Closure")) {

            return
        }
        $params = GenXdev.FileSystem\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.Webbrowser\Close-Webbrowser' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue);

        GenXdev.Webbrowser\Close-Webbrowser @params
    }
}
################################################################################