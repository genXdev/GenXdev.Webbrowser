<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser
Original cmdlet filename  : Close-WebbrowserTab.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.300.2025
################################################################################
Copyright (c)  René Vaessen / GenXdev

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
################################################################################>
###############################################################################
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