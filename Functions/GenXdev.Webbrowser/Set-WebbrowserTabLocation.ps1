################################################################################

<#
.SYNOPSIS
Navigates the current webbrowser tab to a specified URL.

.DESCRIPTION
Sets the location (URL) of the currently selected webbrowser tab. Supports both
Edge and Chrome browsers through optional switches. The navigation includes a
small delay to ensure proper page loading.

.PARAMETER Url
The URL that the browser tab should navigate to. This parameter accepts input
from the pipeline and pipeline properties.

.PARAMETER Edge
Switch to force navigation in Microsoft Edge browser. This parameter cannot be
used together with -Chrome.

.PARAMETER Chrome
Switch to force navigation in Google Chrome browser. This parameter cannot be
used together with -Edge.

.EXAMPLE
Set-WebbrowserTabLocation -Url "https://github.com/microsoft" -Edge

.EXAMPLE
"https://github.com/microsoft" | lt -ch
#>
function Set-WebbrowserTabLocation {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [Alias("lt", "Nav")]

    param(
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "The URL the browser tab should navigate to"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Url,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Edge',
            HelpMessage = "Navigate using Microsoft Edge browser"
        )]
        [Alias("e")]
        [switch] $Edge,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Chrome',
            HelpMessage = "Navigate using Google Chrome browser"
        )]
        [Alias("ch")]
        [switch] $Chrome
        ########################################################################
    )

    begin {
        Write-Verbose "Starting browser navigation process"
        Write-Verbose "Target URL: $Url"
    }

    process {
        # create javascript that navigates to the url after a 1 second delay
        # this ensures the page has time to properly initialize
        $script = "setTimeout(function() { document.location = $($Url |
            ConvertTo-Json -Compress -Depth 1);}, 1000); return;"

        Write-Verbose "Executing navigation script in selected browser"

        # execute the navigation command and suppress unnecessary output
        $null = Invoke-WebbrowserEvaluation -Scripts $script `
            -Chrome:$Chrome `
            -Edge:$Edge
    }

    end {
    }
}
################################################################################
