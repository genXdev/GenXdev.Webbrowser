################################################################################
<#
.SYNOPSIS
Exports bookmarks from a browser to a json file.

.DESCRIPTION
The Export-BrowserBookmarks cmdlet exports bookmarks from Microsoft Edge, Google
Chrome, or Mozilla Firefox into a json file. Only one browser type can be
specified at a time.

.PARAMETER OutputFile
Specifies the path to the JSON file where the bookmarks will be saved.

.PARAMETER Chrome
Exports bookmarks from Google Chrome.

.PARAMETER Edge
Exports bookmarks from Microsoft Edge.

.PARAMETER Firefox
Exports bookmarks from Mozilla Firefox.

.EXAMPLE
Export-BrowserBookmarks -OutputFile "C:\Bookmarks.json" -Edge

.EXAMPLE
Export-BrowserBookmarks "C:\Bookmarks.json" -Chrome
#>
function Export-BrowserBookmarks {

    [CmdletBinding(DefaultParameterSetName = 'Edge')]
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
            ParameterSetName = 'Chrome',
            HelpMessage = "Export bookmarks from Google Chrome"
        )]
        [switch]$Chrome,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Edge',
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

        # expand the output file path to full path
        $outputFilePath = Expand-Path $OutputFile

        Write-Verbose "Exporting bookmarks to: $outputFilePath"
    }

    process {

        # prepare arguments for Get-BrowserBookmarks based on selected browser
        $bookmarksArguments = @{}

        # determine which browser was selected and set appropriate argument
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

        # get bookmarks and convert to json with full depth preservation
        Get-BrowserBookmarks @bookmarksArguments |
            ConvertTo-Json -Depth 100 |
            Set-Content -Path $outputFilePath -Force

        Write-Verbose "Bookmarks exported successfully"
    }

    end {
    }
}
################################################################################
