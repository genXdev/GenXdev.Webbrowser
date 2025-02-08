################################################################################
<#
.SYNOPSIS
Opens bookmarks from various browsers based on search queries.

.DESCRIPTION
Opens browser bookmarks matching specified search queries in the selected browser.
Supports Microsoft Edge, Google Chrome, and Mozilla Firefox.

.PARAMETER Queries
Search terms to filter bookmarks.

.PARAMETER Edge
Select bookmarks from Microsoft Edge.

.PARAMETER Chrome
Select bookmarks from Google Chrome.

.PARAMETER Firefox
Select bookmarks from Mozilla Firefox.

.PARAMETER OpenInEdge
Open found bookmarks in Microsoft Edge.

.PARAMETER OpenInChrome
Open found bookmarks in Google Chrome.

.PARAMETER OpenInFirefox
Open found bookmarks in Mozilla Firefox.

.PARAMETER Monitor
The monitor to display on. 0=default, -1=discard, -2=secondary monitor.

.PARAMETER Count
Maximum number of bookmarks to open.

.EXAMPLE
Open-BrowserBookmarks -Query "github" -Edge -OpenInChrome -Count 5

.EXAMPLE
sites gh -e -och -Count 5
#>
function Open-BrowserBookmarks {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [Alias("sites")]
    param (
        ###############################################################################
        [parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromRemainingArguments,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage = "Search terms to filter bookmarks"
        )]
        [Alias("q", "Value", "Name", "Text", "Query")]
        [string[]] $Queries,
        ###############################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Select in Microsoft Edge"
        )]
        [Alias("e")]
        [switch] $Edge,
        ###############################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Select in Google Chrome"
        )]
        [Alias("ch")]
        [switch] $Chrome,
        ###############################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Select in Firefox"
        )]
        [Alias("ff")]
        [switch] $Firefox,
        ###############################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Open urls in Microsoft Edge"
        )]
        [Alias("oe")]
        [switch] $OpenInEdge,
        ###############################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Open urls in Google Chrome"
        )]
        [Alias("och")]
        [switch] $OpenInChrome,
        ###############################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Open urls in Firefox"
        )]
        [Alias("off")]
        [switch] $OpenInFirefox,
        ###############################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Monitor to use (0=default, -1=discard, -2=secondary)"
        )]
        [Alias("m", "mon")]
        [int] $Monitor = -1,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in incognito/private browsing mode"
        )]
        [Alias("incognito", "inprivate")]
        [switch] $Private,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force enable debugging port, stopping existing browsers if needed"
        )]
        [switch] $Force,

        ###############################################################################
        [Alias("fs", "f")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in fullscreen mode"
        )]
        [switch] $FullScreen,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial width of the webbrowser window"
        )]
        [int] $Width = -1,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial height of the webbrowser window"
        )]
        [int] $Height = -1,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial X position of the webbrowser window"
        )]
        [int] $X = -999999,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial Y position of the webbrowser window"
        )]
        [int] $Y = -999999,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the left side of the screen"
        )]
        [switch] $Left,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the right side of the screen"
        )]
        [switch] $Right,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the top side of the screen"
        )]
        [switch] $Top,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the bottom side of the screen"
        )]
        [switch] $Bottom,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window in the center of the screen"
        )]
        [switch] $Centered,

        ###############################################################################
        [Alias("a", "app", "appmode")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Hide the browser controls"
        )]
        [switch] $ApplicationMode,

        ###############################################################################
        [Alias("de", "ne", "NoExtensions")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Prevent loading of browser extensions"
        )]
        [switch] $NoBrowserExtensions,

        ###############################################################################
        [Alias("lang", "locale")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Set the browser accept-lang http header"
        )]
        [string] $AcceptLang = $null,

        ###############################################################################
        [Alias("bg")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Restore PowerShell window focus"
        )]
        [switch] $RestoreFocus,

        ###############################################################################
        [Alias("nw", "new")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't re-use existing browser window, instead, create a new one"
        )]
        [switch] $NewWindow,
        ###############################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Maximum number of urls to open"
        )]
        [int] $Count = 50
        ###############################################################################
    )

    begin {

        # prepare parameters for Open-Webbrowser
        $boundParams = @{}
        $boundParams["Monitor"] = $Monitor

        if ($OpenInEdge) { $boundParams["Edge"] = $true }
        if ($OpenInChrome) { $boundParams["Chrome"] = $true }
        if ($OpenInFirefox) { $boundParams["Firefox"] = $true }

        # copy remaining parameters
        foreach ($key in $PSBoundParameters.Keys) {
            if ($key -notin @('Queries','Chrome','Firefox','Edge','Count',
                'OpenInEdge','OpenInChrome','OpenInFirefox','Monitor')) {
                $boundParams[$key] = $PSBoundParameters[$key]
            }
        }

        Write-Verbose "Initialized parameters for browser opening"
    }

    process {

        # prepare parameters for finding bookmarks
        $findParams = @{
            PassThru = $true
            Queries = $Queries
        }

        if ($Chrome) { $findParams["Chrome"] = $true }
        if ($Edge) { $findParams["Edge"] = $true }
        if ($Firefox) { $findParams["Firefox"] = $true }

        Write-Verbose "Searching for bookmarks with specified criteria"

        # find and collect urls
        $urls = @(Find-BrowserBookmarks @findParams |
            ForEach-Object Url |
            Select-Object -First $Count)

        if ($urls.Length -eq 0) {
            Write-Host "No bookmarks found matching the criteria"
            return
        }

        Write-Verbose "Found $($urls.Length) matching bookmarks"

        # open urls in specified browser
        $boundParams["Url"] = $urls
        Open-Webbrowser @boundParams
    }

    end {
    }
}
################################################################################
