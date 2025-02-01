################################################################################
<#
.SYNOPSIS
Opens a URL in multiple browsers simultaneously in a mosaic layout.

.DESCRIPTION
Opens the specified URL in Chrome, Edge, Firefox, and an incognito window,
arranging them in a 2x2 mosaic layout on the screen. Each browser window is
positioned in a different quadrant of the screen.

.PARAMETER Url
The URL to open in all browsers. This parameter accepts pipeline input and can be
specified by position.

.EXAMPLE
Show-WebsiteInAllBrowsers -Url "https://www.github.com"
Opens github.com in all browsers in a mosaic layout.
#>
function Show-WebsiteInAllBrowsers {

    [CmdletBinding()]
    [Alias("Show-UrlInAllBrowsers")]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "The URL to open in all browsers simultaneously"
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("Uri", "Website", "Link")]
        [string] $Url
    )

    begin {

        # log the start of the operation with the target url
        Write-Verbose "Starting browser mosaic layout for URL: $Url"
    }

    process {

        # initialize chrome in the top-left quadrant
        Write-Verbose "Launching Chrome in top-left quadrant"
        $null = Open-Webbrowser -Chrome -Left -Top -Url $Url

        # initialize edge in the bottom-left quadrant
        Write-Verbose "Launching Edge in bottom-left quadrant"
        $null = Open-Webbrowser -Edge -Left -Bottom -Url $Url

        # initialize firefox in the top-right quadrant
        Write-Verbose "Launching Firefox in top-right quadrant"
        $null = Open-Webbrowser -Firefox -Right -Top -Url $Url

        # initialize private window in the bottom-right quadrant
        Write-Verbose "Launching Private window in bottom-right quadrant"
        $null = Open-Webbrowser -Private -Right -Bottom -Url $Url
    }

    end {
    }
}
################################################################################
