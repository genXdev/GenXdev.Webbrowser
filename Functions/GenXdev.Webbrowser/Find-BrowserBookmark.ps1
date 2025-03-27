################################################################################
<#
.SYNOPSIS
Finds bookmarks from one or more web browsers.

.DESCRIPTION
Searches through bookmarks from Microsoft Edge, Google Chrome, or Mozilla Firefox.
Returns bookmarks that match one or more search queries in their name, URL, or
folder path. If no queries are provided, returns all bookmarks from the selected
browsers.

.PARAMETER Queries
One or more search terms to find matching bookmarks. Matches are found in the
bookmark name, URL, or folder path using wildcard pattern matching.

.PARAMETER Edge
Switch to include Microsoft Edge bookmarks in the search.

.PARAMETER Chrome
Switch to include Google Chrome bookmarks in the search.

.PARAMETER Firefox
Switch to include Mozilla Firefox bookmarks in the search.

.PARAMETER Count
Maximum number of results to return. Must be a positive integer.
Default is 99999999.

.PARAMETER PassThru
Switch to return complete bookmark objects instead of just URLs. Each bookmark
object contains Name, URL, and Folder properties.

.EXAMPLE
Find-BrowserBookmark -Query "github" -Edge -Chrome -Count 10
# Searches Edge and Chrome bookmarks for "github", returns first 10 URLs

.EXAMPLE
bookmarks powershell -e -ff -PassThru
# Searches Edge and Firefox bookmarks for "powershell", returns full objects
#>
function Find-BrowserBookmark {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [Alias("bookmarks")]
    param (
        ########################################################################
        [Alias("q", "Value", "Name", "Text", "Query")]
        [parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromRemainingArguments = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Search terms to find matching bookmarks"
        )]
        [SupportsWildcards()]
        [string[]] $Queries,
        ########################################################################

        [Alias("e")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Search through Microsoft Edge bookmarks"
        )]
        [switch] $Edge,
        ########################################################################

        [Alias("ch")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Search through Google Chrome bookmarks"
        )]
        [switch] $Chrome,
        ########################################################################

        [Alias("ff")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Search through Firefox bookmarks"
        )]
        [switch] $Firefox,
        ########################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = "Maximum number of results to return"
        )]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $Count = 99999999,
        ########################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = "Return bookmark objects instead of just URLs"
        )]
        [switch] $PassThru
        ########################################################################
    )

    begin {
        Microsoft.PowerShell.Utility\Write-Verbose "Initializing browser bookmark search"
        $bookmarksArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.Webbrowser\Get-BrowserBookmark" `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -Name * -ErrorAction SilentlyContinue)
    }


process {

        # retrieve all bookmarks from selected browsers
        Microsoft.PowerShell.Utility\Write-Verbose "Fetching bookmarks from selected browsers"
        $bookmarks = GenXdev.Webbrowser\Get-BrowserBookmark @bookmarksArguments

        # handle case when no search queries provided
        if (($null -eq $Queries) -or ($Queries.Length -eq 0)) {

            Microsoft.PowerShell.Utility\Write-Verbose "No search terms specified - returning all bookmarks"
            $bookmarks |
            Microsoft.PowerShell.Utility\Select-Object -First $Count
            return
        }

        # search bookmarks for matches to any query terms
        Microsoft.PowerShell.Utility\Write-Verbose "Searching bookmarks for matches to $($Queries.Count) queries"
        $results = $Queries |
        Microsoft.PowerShell.Core\ForEach-Object {
            $query = $PSItem
            if (-not ($query.Contains("*") -or ($query.Contains("?")))) {
                $query = "*$query*"
            }
            Microsoft.PowerShell.Utility\Write-Verbose "Processing query: $query"

            $bookmarks |
            Microsoft.PowerShell.Core\Where-Object {
                ($PSItem.Folder -like "$query") -or
                ($PSItem.Name -Like "$query") -or
                ($PSItem.URL -Like "$query")
            }
        } |
        Microsoft.PowerShell.Utility\Select-Object -First $Count

        # return either full bookmark objects or just URLs
        if ($PassThru) {
            Microsoft.PowerShell.Utility\Write-Verbose "Returning $($results.Count) bookmark objects"
            $results
        }
        else {
            Microsoft.PowerShell.Utility\Write-Verbose "Returning $($results.Count) bookmark URLs"
            $results |
            Microsoft.PowerShell.Core\ForEach-Object URL
        }
    }

    end {
    }
}
################################################################################