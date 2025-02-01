################################################################################
<#
.SYNOPSIS
Finds bookmarks from one or more web browsers.

.DESCRIPTION
Searches through bookmarks from Microsoft Edge, Google Chrome, or Mozilla Firefox
and returns matches based on search queries.

.PARAMETER Queries
One or more search terms to find matching bookmarks.

.PARAMETER Edge
Search through Microsoft Edge bookmarks.

.PARAMETER Chrome
Search through Google Chrome bookmarks.

.PARAMETER Firefox
Search through Mozilla Firefox bookmarks.

.PARAMETER Count
Maximum number of results to return. Default is 99999999.

.PARAMETER PassThru
Returns bookmark objects instead of just URLs.

.EXAMPLE
Find-BrowserBookmarks -Query "github" -Edge -Chrome -Count 10

.EXAMPLE
bookmarks github -e -ch -Count 10
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
            ValueFromRemainingArguments = $true,
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

        # build arguments for Get-BrowserBookmarks based on selected browsers
        if ($Chrome) { $bookmarksArguments["Chrome"] = $true }
        if ($Edge) { $bookmarksArguments["Edge"] = $true }
        if ($Firefox) { $bookmarksArguments["Firefox"] = $true }

        Write-Verbose "Retrieving bookmarks from selected browsers"
        $bookmarks = Get-BrowserBookmarks @bookmarksArguments

        # if no search queries provided, return all bookmarks up to Count
        if (($null -eq $Queries) -or ($Queries.Length -eq 0)) {

            Write-Verbose "No search queries specified, returning all bookmarks"
            $bookmarks | Select-Object -First $Count
            return
        }

        Write-Verbose "Searching bookmarks for matches to queries"
        $results = $Queries |
            ForEach-Object {
                $query = $PSItem
                $bookmarks |
                    Where-Object {
                        ($PSItem.Folder -like "*$query*") -or `
                        ($PSItem.Name -Like "*$query*") -or `
                        ($PSItem.URL -Like "*$query*")
                    }
            } |
            Select-Object -First $Count

        if ($PassThru) {
            Write-Verbose "Returning full bookmark objects"
            $results
        }
        else {
            Write-Verbose "Returning bookmark URLs only"
            $results | ForEach-Object URL
        }
    }

    end {
    }
}
################################################################################
