﻿###############################################################################
<#
.SYNOPSIS
Closes the currently selected webbrowser tab.

.DESCRIPTION
Closes the currently selected webbrowser tab using ChromeDriver's CloseAsync()
method. If no tab is currently selected, the function will automatically attempt
to select the last used tab before closing it.

.EXAMPLE
Close-WebbrowserTab
Closes the currently active browser tab

.EXAMPLE
ct
Uses the alias to close the currently active browser tab
#>
function Close-WebbrowserTab {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [Alias('ct', 'CloseTab')]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Navigate using Microsoft Edge browser'
        )]
        [Alias('e')]
        [switch] $Edge,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Navigate using Google Chrome browser'
        )]
        [Alias('ch')]
        [switch] $Chrome
        ########################################################################
    )

    begin {
        # attempt to get reference to existing chrome session
        # if this fails, we'll try to select the last used tab
        try {
            Microsoft.PowerShell.Utility\Write-Verbose 'Attempting to locate active browser session'
            $null = GenXdev.Webbrowser\Get-ChromiumSessionReference -Chrome:$Chrome -Edge:$Edge
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Verbose 'No active session found, selecting last used tab'
            $null = GenXdev.Webbrowser\Select-WebbrowserTab -Chrome:$Chrome -Edge:$Edge
        }
    }


    process {

        # log the tab information before closing
        Microsoft.PowerShell.Utility\Write-Verbose ("Closing browser tab: '$($Global:chromeSession.title)' " +
            "at URL: $($Global:chromeSession.url)")

        # use chromedriver's closeAsync method to close the current tab
        # wait for the async operation to complete
        $null = $Global:chromeController.CloseAsync().Wait()
    }

    end {
    }
}