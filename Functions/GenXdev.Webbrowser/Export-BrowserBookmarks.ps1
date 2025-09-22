<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser
Original cmdlet filename  : Export-BrowserBookmarks.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.278.2025
################################################################################
MIT License

Copyright 2021-2025 GenXdev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
################################################################################>
###############################################################################
<#
.SYNOPSIS
Exports browser bookmarks to a JSON file.

.DESCRIPTION
The Export-BrowserBookmarks cmdlet exports bookmarks from a specified web browser
(Microsoft Edge, Google Chrome, or Mozilla Firefox) to a JSON file. Only one
browser type can be specified at a time. The bookmarks are exported with full
preservation of their structure and metadata.

.PARAMETER OutputFile
The path to the JSON file where the bookmarks will be saved. The path will be
expanded to a full path before use.

.PARAMETER Chrome
Switch parameter to export bookmarks from Google Chrome browser.

.PARAMETER Edge
Switch parameter to export bookmarks from Microsoft Edge browser.

.PARAMETER Firefox
Switch parameter to export bookmarks from Mozilla Firefox browser.

.EXAMPLE
Export-BrowserBookmarks -OutputFile "C:\MyBookmarks.json" -Edge

.EXAMPLE
Export-BrowserBookmarks "C:\MyBookmarks.json" -Chrome
#>
function Export-BrowserBookmarks {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    param (
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = 'Path to the JSON file where bookmarks will be saved'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$OutputFile,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Export bookmarks from Google Chrome'
        )]
        [switch]$Chrome,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Export bookmarks from Microsoft Edge'
        )]
        [switch]$Edge,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Firefox',
            HelpMessage = 'Export bookmarks from Mozilla Firefox'
        )]
        [switch]$Firefox
        ########################################################################
    )

    begin {
        # convert relative or partial path to full filesystem path
        $outputFilePath = GenXdev.FileSystem\Expand-Path $OutputFile

        # inform user about the output destination
        Microsoft.PowerShell.Utility\Write-Verbose "Exporting bookmarks to: $outputFilePath"
    }


    process {

        # initialize empty hashtable for browser selection parameters
        $bookmarksArguments = @{}

        # set appropriate flag based on selected browser type
        if ($Chrome) {
            $bookmarksArguments['Chrome'] = $true
            Microsoft.PowerShell.Utility\Write-Verbose 'Exporting Chrome bookmarks'
        }
        if ($Edge) {
            $bookmarksArguments['Edge'] = $true
            Microsoft.PowerShell.Utility\Write-Verbose 'Exporting Edge bookmarks'
        }
        if ($Firefox) {
            $bookmarksArguments['Firefox'] = $true
            Microsoft.PowerShell.Utility\Write-Verbose 'Exporting Firefox bookmarks'
        }

        # retrieve bookmarks and save them as formatted json to the output file
        GenXdev.Webbrowser\Get-BrowserBookmark @bookmarksArguments |
            Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 100 |
            Microsoft.PowerShell.Management\Set-Content -LiteralPath $outputFilePath -Force

        Microsoft.PowerShell.Utility\Write-Verbose 'Bookmarks exported successfully'
    }

    end {
    }
}