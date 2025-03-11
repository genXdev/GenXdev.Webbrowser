################################################################################
<#
.SYNOPSIS
Navigates the current webbrowser tab to a specified URL.

.DESCRIPTION
Sets the location (URL) of the currently selected webbrowser tab. Supports both
Edge and Chrome browsers through optional switches. The navigation includes
validation of the URL and ensures proper page loading through async operations.

.PARAMETER Url
The target URL for navigation. Accepts pipeline input and must be a valid URL
string. This parameter is required.

.PARAMETER Edge
Switch parameter to specifically target Microsoft Edge browser. Cannot be used
together with -Chrome parameter.

.PARAMETER Chrome
Switch parameter to specifically target Google Chrome browser. Cannot be used
together with -Edge parameter.

.EXAMPLE
Set-WebbrowserTabLocation -Url "https://github.com/microsoft" -Edge

.EXAMPLE
"https://github.com/microsoft" | lt -ch
#>
function Set-WebbrowserTabLocation {

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    [CmdletBinding(
        SupportsShouldProcess = $true,
        DefaultParameterSetName = 'Default'
    )]
    [Alias("lt", "Nav")]

    param(
        ########################################################################
        [parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "The URL to navigate to"
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

        # attempt to connect to an existing browser session before proceeding
        try {
            Write-Verbose "Attempting to connect to existing browser session"
            $null = Get-ChromiumSessionReference -Chrome:$Chrome -Edge:$Edge
        }
        catch {
            # if no active session found, select the most recently used tab
            Write-Verbose "No active session found, selecting last used tab"
            $null = Select-WebbrowserTab -Chrome:$Chrome -Edge:$Edge
        }
    }

    process {

        if ($PSCmdlet.ShouldProcess($Url, "Navigate to URL")) {

            Write-Verbose "Navigating to URL: $Url"
            $null = $Global:chromeController.GotoAsync($Url).Result
        }
    }

    end {
    }
}
################################################################################
