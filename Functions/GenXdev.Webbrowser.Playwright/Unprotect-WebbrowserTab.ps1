<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser.Playwright
Original cmdlet filename  : Unprotect-WebbrowserTab.ps1
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
Takes control of a selected web browser tab for interactive manipulation.

.DESCRIPTION
This function enables interactive control of a browser tab that was previously
selected using Select-WebbrowserTab. It provides direct access to the Microsoft
Playwright Page object's properties and methods, allowing for automated browser
interaction.

.PARAMETER UseCurrent
When specified, uses the currently assigned browser tab instead of prompting to
select a new one. This is useful for continuing work with the same tab.

.PARAMETER Force
Forces a browser restart by closing all tabs if no debugging server is detected.
Use this when the browser connection is in an inconsistent state.

.EXAMPLE
Unprotect-WebbrowserTab -UseCurrent

.EXAMPLE
wbctrl -Force
#>
function Unprotect-WebbrowserTab {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Alias('wbctrl')]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ParameterSetName = 'Default',
            HelpMessage = 'Use current tab instead of selecting a new one'
        )]
        [Alias('current')]
        [switch] $UseCurrent,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            ParameterSetName = 'Default',
            HelpMessage = 'Restart browser if no debugging server detected'
        )]
        [switch] $Force
    )

    begin {

        Microsoft.PowerShell.Utility\Write-Verbose 'Initializing browser tab control sequence...'

        # get reference to powershell window for manipulation
        $pwshW = GenXdev.Windows\Get-PowershellMainWindow
    }


    process {

        if (-not $UseCurrent) {

            Clear-Host

            Microsoft.PowerShell.Utility\Write-Verbose 'Prompting user to select a browser tab...'
            Microsoft.PowerShell.Utility\Write-Host 'Select to which browser tab you want to send commands to'

            # attempt to get list of available browser tabs
            GenXdev.Webbrowser\Select-WebbrowserTab -Force:$Force

            if ($Global:ChromeSessions.Length -eq 0) {

                Microsoft.PowerShell.Utility\Write-Host 'No browser tabs are open'
                return
            }

            # get valid tab selection from user
            $tabNumber = 0
            do {
                $tabNumber = Microsoft.PowerShell.Utility\Read-Host 'Enter the number of the tab you want to control'
                $tabNumber = $tabNumber -as [int]
                $tabCount = $Global:ChromeSessions.Length

                if ($tabNumber -lt 0 -or $tabNumber -gt $tabCount - 1) {
                    Microsoft.PowerShell.Utility\Write-Host ('Invalid tab number. Please enter a number ' +
                        "between 0 and $($tabCount-1)")
                    continue
                }
                break
            } while ($true)

            # activate the selected browser tab
            GenXdev.Webbrowser\Select-WebbrowserTab $tabNumber
        }

        if (-not $Global:chromeController) {

            Microsoft.PowerShell.Utility\Write-Host 'No ChromeController object found'
            return
        }

        try {
            # maximize the powershell window
            $null = $pwshW.Maximize()
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Verbose "Failed to maximize PowerShell window: $_"
        }

        # create background job for keyboard input
        $null = Microsoft.PowerShell.Core\Start-Job {

            # send keyboard sequence to expose chrome controller object
            $null = GenXdev.Windows\Send-Key `
                '{ESCAPE}', 'Clear-Host', '{ENTER}', "`$ChromeController", '.',
            '^( )', 'y' `
                -SendKeyDelayMilliSeconds 500 `
                -WindowHandle ((GenXdev.Windows\Get-PowershellMainWindow).Handle)

            # allow time for commands to complete
            $null = Microsoft.PowerShell.Utility\Start-Sleep 3
        }

        try {
            # attempt to bring powershell window to front
            $null = GenXdev.Windows\Get-PowershellMainWindow | Microsoft.PowerShell.Core\ForEach-Object {

                $null = $_.Focus()
                $null = GenXdev.Windows\Set-ForegroundWindow $_.handle
            }
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Verbose "Failed to set PowerShell window focus: $_"
        }
    }

    end {
    }
}
###############################################################################