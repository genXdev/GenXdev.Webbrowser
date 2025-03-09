################################################################################
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
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
    param (
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "Path to the JSON file where bookmarks will be saved"
        )]
        [ValidateNotNullOrEmpty()]
        [string]$OutputFile,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Export bookmarks from Google Chrome"
        )]
        [switch]$Chrome,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Export bookmarks from Microsoft Edge"
        )]
        [switch]$Edge,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Firefox',
            HelpMessage = "Export bookmarks from Mozilla Firefox"
        )]
        [switch]$Firefox
        ########################################################################
    )

    begin {
        # convert relative or partial path to full filesystem path
        $outputFilePath = GenXdev.FileSystem\Expand-Path $OutputFile

        # inform user about the output destination
        Write-Verbose "Exporting bookmarks to: $outputFilePath"
    }

    process {

        # initialize empty hashtable for browser selection parameters
        $bookmarksArguments = @{}

        # set appropriate flag based on selected browser type
        if ($Chrome) {
            $bookmarksArguments["Chrome"] = $true
            Write-Verbose "Exporting Chrome bookmarks"
        }
        if ($Edge) {
            $bookmarksArguments["Edge"] = $true
            Write-Verbose "Exporting Edge bookmarks"
        }
        if ($Firefox) {
            $bookmarksArguments["Firefox"] = $true
            Write-Verbose "Exporting Firefox bookmarks"
        }

        # retrieve bookmarks and save them as formatted json to the output file
        Get-BrowserBookmark @bookmarksArguments |
        ConvertTo-Json -Depth 100 |
        Set-Content -Path $outputFilePath -Force

        Write-Verbose "Bookmarks exported successfully"
    }

    end {
    }
}
################################################################################
