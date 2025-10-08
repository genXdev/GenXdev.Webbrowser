<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser
Original cmdlet filename  : Close-WebbrowserTab.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.298.2025
################################################################################
MIT License

Copyright 2021-2025 GenXdev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
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