################################################################################
<#
.SYNOPSIS
Opens a URL in multiple browsers simultaneously in a mosaic layout.

.DESCRIPTION
This function creates a mosaic layout of browser windows by opening the specified
URL in Chrome, Edge, Firefox, and a private browsing window. The browsers are
arranged in a 2x2 grid pattern:
- Chrome: Top-left quadrant
- Edge: Bottom-left quadrant
- Firefox: Top-right quadrant
- Private window: Bottom-right quadrant

.PARAMETER Url
The URL to open in all browsers. Accepts pipeline input and can be specified by
position or through properties.

.EXAMPLE
Show-WebsiteInAllBrowsers -Url "https://www.github.com"
Opens github.com in four different browsers arranged in a mosaic layout.

.EXAMPLE
"https://www.github.com" | Show-UrlInAllBrowsers
Uses the function's alias and pipeline input to achieve the same result.
#>
function Show-WebsiteInAllBrowsers {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
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
        Microsoft.PowerShell.Utility\Write-Verbose "Starting browser mosaic layout for URL: $Url"
    }

    process {

        # initialize chrome in the top-left quadrant of the screen
        Microsoft.PowerShell.Utility\Write-Verbose "Launching Chrome in top-left quadrant"
        $null = GenXdev.Webbrowser\Open-Webbrowser -Chrome -Left -Top -Url $Url

        # initialize edge in the bottom-left quadrant of the screen
        Microsoft.PowerShell.Utility\Write-Verbose "Launching Edge in bottom-left quadrant"
        $null = GenXdev.Webbrowser\Open-Webbrowser -Edge -Left -Bottom -Url $Url

        # initialize firefox in the top-right quadrant of the screen
        Microsoft.PowerShell.Utility\Write-Verbose "Launching Firefox in top-right quadrant"
        $null = GenXdev.Webbrowser\Open-Webbrowser -Firefox -Right -Top -Url $Url

        # initialize private window in the bottom-right quadrant of the screen
        Microsoft.PowerShell.Utility\Write-Verbose "Launching Private window in bottom-right quadrant"
        $null = GenXdev.Webbrowser\Open-Webbrowser -Private -Right -Bottom -Url $Url
    }

    end {
    }
}
################################################################################