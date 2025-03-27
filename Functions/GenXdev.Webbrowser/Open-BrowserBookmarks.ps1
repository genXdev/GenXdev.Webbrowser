################################################################################
<#
.SYNOPSIS
Opens browser bookmarks that match specified search criteria.

.DESCRIPTION
Searches bookmarks across Microsoft Edge, Google Chrome, and Mozilla Firefox
browsers based on provided search queries. Opens matching bookmarks in the
selected browser with configurable window settings and browser modes.

.PARAMETER Queries
Search terms used to filter bookmarks by title or URL.

.PARAMETER Edge
Use Microsoft Edge browser bookmarks as search source.

.PARAMETER Chrome
Use Google Chrome browser bookmarks as search source.

.PARAMETER Firefox
Use Mozilla Firefox browser bookmarks as search source.

.PARAMETER OpenInEdge
Open found bookmarks in Microsoft Edge browser.

.PARAMETER OpenInChrome
Open found bookmarks in Google Chrome browser.

.PARAMETER OpenInFirefox
Open found bookmarks in Mozilla Firefox browser.

.PARAMETER Monitor
Specifies target monitor: 0=default, -1=discard, -2=secondary monitor.

.PARAMETER Private
Opens bookmarks in private/incognito browsing mode.

.PARAMETER Force
Forces enabling of debugging port, stops existing browser instances if needed.

.PARAMETER FullScreen
Opens browser windows in fullscreen mode.

.PARAMETER Width
Sets initial browser window width in pixels.

.PARAMETER Height
Sets initial browser window height in pixels.

.PARAMETER X
Sets initial browser window X position.

.PARAMETER Y
Sets initial browser window Y position.

.PARAMETER Left
Places browser window on left side of screen.

.PARAMETER Right
Places browser window on right side of screen.

.PARAMETER Top
Places browser window on top of screen.

.PARAMETER Bottom
Places browser window on bottom of screen.

.PARAMETER Centered
Centers browser window on screen.

.PARAMETER ApplicationMode
Hides browser controls for clean app-like experience.

.PARAMETER NoBrowserExtensions
Prevents loading of browser extensions.

.PARAMETER AcceptLang
Sets browser accept-language HTTP header.

.PARAMETER RestoreFocus
Restores PowerShell window focus after opening bookmarks.

.PARAMETER NewWindow
Creates new browser window instead of reusing existing one.

.PARAMETER Count
Maximum number of bookmarks to open (default 50).

.EXAMPLE
Open-BrowserBookmarks -Queries "github" -Edge -OpenInChrome -Count 5

.EXAMPLE
sites gh -e -och -c 5
#>
function Open-BrowserBookmarks {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
    [Alias("sites")]

    param (
        #######################################################################
        [parameter(
            Position = 0,
            Mandatory = $false,

            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Search terms to filter bookmarks"
        )]
        [Alias("q", "Value", "Name", "Text", "Query")]
        [string[]] $Queries,

        #######################################################################
        [parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "Maximum number of urls to open"
        )]
        [int] $Count = 50,
        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Select in Microsoft Edge"
        )]
        [Alias("e")]
        [switch] $Edge,
        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Select in Google Chrome"
        )]
        [Alias("ch")]
        [switch] $Chrome,
        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Select in Firefox"
        )]
        [Alias("ff")]
        [switch] $Firefox,
        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Open urls in Microsoft Edge"
        )]
        [Alias("oe")]
        [switch] $OpenInEdge,
        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Open urls in Google Chrome"
        )]
        [Alias("och")]
        [switch] $OpenInChrome,
        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Open urls in Firefox"
        )]
        [Alias("off")]
        [switch] $OpenInFirefox,
        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Monitor to use (0=default, -1=discard, -2=secondary)"
        )]
        [Alias("m", "mon")]
        [int] $Monitor = -1,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in incognito/private browsing mode"
        )]
        [Alias("incognito", "inprivate")]
        [switch] $Private,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force enable debugging port, stopping existing browsers if needed"
        )]
        [switch] $Force,

        #######################################################################
        [Alias("fs", "f")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in fullscreen mode"
        )]
        [switch] $FullScreen,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial width of the webbrowser window"
        )]
        [int] $Width = -1,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial height of the webbrowser window"
        )]
        [int] $Height = -1,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial X position of the webbrowser window"
        )]
        [int] $X = -999999,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial Y position of the webbrowser window"
        )]
        [int] $Y = -999999,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the left side of the screen"
        )]
        [switch] $Left,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the right side of the screen"
        )]
        [switch] $Right,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the top side of the screen"
        )]
        [switch] $Top,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the bottom side of the screen"
        )]
        [switch] $Bottom,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window in the center of the screen"
        )]
        [switch] $Centered,

        #######################################################################
        [Alias("a", "app", "appmode")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Hide the browser controls"
        )]
        [switch] $ApplicationMode,

        #######################################################################
        [Alias("de", "ne", "NoExtensions")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Prevent loading of browser extensions"
        )]
        [switch] $NoBrowserExtensions,

        #######################################################################
        [Alias("lang", "locale")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Set the browser accept-lang http header"
        )]
        [string] $AcceptLang = $null,

        #######################################################################
        [Alias("bg")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Restore PowerShell window focus"
        )]
        [switch] $RestoreFocus,

        #######################################################################
        [Alias("nw", "new")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't re-use existing browser window, instead, create a new one"
        )]
        [switch] $NewWindow
        #######################################################################
    )

    begin {

        Microsoft.PowerShell.Utility\Write-Verbose "Initializing browser parameters for bookmark search..."

        # prepare browser opening parameters
        $invocationParams = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.Webbrowser\Open-Webbrowser" `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -Name * -ErrorAction SilentlyContinue)

        # remove count parameter as it's not used by Open-Webbrowser
        if ($invocationParams.ContainsKey("Count")) {

            $null = $invocationParams.Remove("Count")
        }

        # configure target browser based on parameters
        if ($OpenInEdge) { $invocationParams["Edge"] = $true }
        if ($OpenInChrome) { $invocationParams["Chrome"] = $true }
        if ($OpenInFirefox) { $invocationParams["Firefox"] = $true }
    }


process {

        Microsoft.PowerShell.Utility\Write-Verbose ("Searching bookmarks with criteria: " + ($Queries -join ", "))

        # setup bookmark search parameters
        $findParams = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.Webbrowser\Find-BrowserBookmark" `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -Name * `
                -ErrorAction SilentlyContinue)

        $findParams["PassThru"] = $true

        # find matching bookmarks and extract urls
        $urls = @(GenXdev.Webbrowser\Find-BrowserBookmark @findParams |
            Microsoft.PowerShell.Core\ForEach-Object Url |
            Microsoft.PowerShell.Utility\Select-Object -First $Count)

        if ($urls.Length -eq 0) {
            Microsoft.PowerShell.Utility\Write-Host "No bookmarks found matching the criteria"
            return
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Opening $($urls.Length) matching bookmarks in browser..."

        # pass urls to browser opening function
        $invocationParams["Url"] = $urls
        GenXdev.Webbrowser\Open-Webbrowser @invocationParams
    }

    end {
    }
}
################################################################################