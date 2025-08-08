###############################################################################
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

.PARAMETER NoAutoSelectTab
Prevents automatic tab selection if no tab is currently selected.

.PARAMETER Edge
Switch parameter to specifically target Microsoft Edge browser. Cannot be used
together with -Chrome parameter.

.PARAMETER Chrome
Switch parameter to specifically target Google Chrome browser. Cannot be used
together with -Edge parameter.

.PARAMETER Page
Browser page object for execution when using ByReference mode.

.PARAMETER ByReference
Session reference object when using ByReference mode.

.EXAMPLE
Set-WebbrowserTabLocation -Url "https://github.com/microsoft" -Edge

.EXAMPLE
"https://github.com/microsoft" | lt -ch
#>
function Set-WebbrowserTabLocation {

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [CmdletBinding(
        SupportsShouldProcess = $true,
        DefaultParameterSetName = 'Default'
    )]
    [Alias('lt', 'Nav')]

    param(
        ########################################################################
        [parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The URL to navigate to'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Url,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $false,
            HelpMessage = 'Prevent automatic tab selection'
        )]
        [switch] $NoAutoSelectTab,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Edge',
            HelpMessage = 'Navigate using Microsoft Edge browser'
        )]
        [Alias('e')]
        [switch] $Edge,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Chrome',
            HelpMessage = 'Navigate using Google Chrome browser'
        )]
        [Alias('ch')]
        [switch] $Chrome,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Browser page object reference',
            ValueFromPipeline = $false
        )]
        [object] $Page,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Browser session reference object',
            ValueFromPipeline = $false
        )]
        [PSCustomObject] $ByReference
    )

    begin {
        # initialize reference tracking
        $reference = $null

        # handle reference initialization
        if (($null -eq $Page) -or ($null -eq $ByReference)) {

            try {
                $reference = GenXdev.Webbrowser\Get-ChromiumSessionReference
                $Page = $Global:chromeController
            }
            catch {
                if ($NoAutoSelectTab -eq $true) {
                    throw $PSItem.Exception
                }

                # attempt auto-selection of browser tab
                 try {
                    GenXdev.Webbrowser\Select-WebbrowserTab -Chrome:$Chrome -Edge:$Edge | Microsoft.PowerShell.Core\Out-Null
                    $Page = $Global:chromeController
                    $reference = GenXdev.Webbrowser\Get-ChromiumSessionReference
                }
                catch {}
            }
        }
        else {
            $reference = $ByReference
        }

        # validate browser context
        if (($null -eq $Page) -or ($null -eq $reference)) {

            throw 'No browser tab selected, use Select-WebbrowserTab to select a tab first.'
        }
    }


    process {

        if ($PSCmdlet.ShouldProcess($Url, 'Navigate to URL')) {

            Microsoft.PowerShell.Utility\Write-Verbose "Navigating to URL: $Url"
            $null = $Page.GotoAsync($Url)
            $null = $Page.WaitForNavigationAsync().Result
        }
    }

    end {
    }
}