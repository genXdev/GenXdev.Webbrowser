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
Find-BrowserBookmarks -Query "github" -Edge -Chrome -Count 10
# Searches Edge and Chrome bookmarks for "github", returns first 10 URLs

.EXAMPLE
bookmarks powershell -e -ff -PassThru
# Searches Edge and Firefox bookmarks for "powershell", returns full objects
#>
function Find-BrowserBookmarks {

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

        Write-Verbose "Initializing browser bookmark search"
        $bookmarksArguments = @{}
    }

    process {

        # create empty hashtable to store browser selection flags
        Write-Verbose "Configuring browser selection parameters"
        $bookmarksArguments = @{}

        # add each selected browser to the arguments
        if ($Chrome) {
            Write-Verbose "Including Chrome bookmarks in search"
            $bookmarksArguments["Chrome"] = $true
        }
        if ($Edge) {
            Write-Verbose "Including Edge bookmarks in search"
            $bookmarksArguments["Edge"] = $true
        }
        if ($Firefox) {
            Write-Verbose "Including Firefox bookmarks in search"
            $bookmarksArguments["Firefox"] = $true
        }

        # retrieve all bookmarks from selected browsers
        Write-Verbose "Fetching bookmarks from selected browsers"
        $bookmarks = Get-BrowserBookmarks @bookmarksArguments

        # handle case when no search queries provided
        if (($null -eq $Queries) -or ($Queries.Length -eq 0)) {

            Write-Verbose "No search terms specified - returning all bookmarks"
            $bookmarks |
            Select-Object -First $Count
            return
        }

        # search bookmarks for matches to any query terms
        Write-Verbose "Searching bookmarks for matches to $($Queries.Count) queries"
        $results = $Queries |
        ForEach-Object {
            $query = $PSItem
            Write-Verbose "Processing query: $query"
            $bookmarks |
            Where-Object {
                        ($PSItem.Folder -like "*$query*") -or `
                ($PSItem.Name -Like "*$query*") -or `
                ($PSItem.URL -Like "*$query*")
            }
        } |
        Select-Object -First $Count

        # return either full bookmark objects or just URLs
        if ($PassThru) {
            Write-Verbose "Returning $($results.Count) bookmark objects"
            $results
        }
        else {
            Write-Verbose "Returning $($results.Count) bookmark URLs"
            $results |
            ForEach-Object URL
        }
    }

    end {
    }
}
################################################################################
