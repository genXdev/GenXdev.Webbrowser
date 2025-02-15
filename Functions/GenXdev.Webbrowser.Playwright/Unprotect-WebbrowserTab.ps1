################################################################################
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

    [CmdletBinding()]
    [Alias("wbctrl")]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "Use the current tab already assigned instead of selecting a new one"
        )]
        [Alias("current")]
        [switch] $UseCurrent,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "Restart webbrowser (closes all) if no debugging server is detected"
        )]
        [switch] $Force
        ########################################################################
    )

    begin {

        Write-Verbose "Initializing browser tab control sequence..."

        # get references to powershell window and process for later manipulation
        $pwshW = Get-PowershellMainWindow
        $pwshP = Get-PowershellMainWindowProcess
    }

    process {

        if (-not $UseCurrent) {

            Clear-Host

            Write-Verbose "Prompting user to select a browser tab..."
            Write-Host "Select to which browser tab you want to send commands to"

            # attempt to get list of available browser tabs
            Select-WebbrowserTab -Force:$Force | Out-Host

            if ($Global:ChromeSessions.Length -eq 0) {

                Write-Host "No browser tabs are open"
                return
            }

            # get valid tab selection from user with input validation
            $tabNumber = 0
            do {
                $tabNumber = Read-Host "Enter the number of the tab you want to control"
                $tabNumber = $tabNumber -as [int]
                $tabCount = $Global:ChromeSessions.Length

                if ($tabNumber -lt 0 -or $tabNumber -gt $tabCount - 1) {
                    Write-Host "Invalid tab number. Please enter a number between 0 and $($tabCount-1)"
                    continue
                }
                break
            } while ($true)

            # activate the selected browser tab
            Select-WebbrowserTab $tabNumber
        }

        if (-not $Global:chromeController) {

            Write-Host "No ChromeController object found"
            return
        }

        try {
            # maximize the powershell window
            $pwshW.maximize();
        }
        catch {
            Write-Verbose "Failed to maximize PowerShell window"
        }

        # create background job to handle keyboard input sequence
        $null = Start-Job {

            # send keyboard sequence to expose chrome controller object
            $null = Send-Keys `
                "{Escape}", "Clear-Host", "{Enter}", "`$ChromeController", ".", "^( )", "y" `
                -DelayMilliSeconds 500

            # allow time for commands to complete
            $null = Start-Sleep 3
        }

        try {
            # attempt to bring powershell window to front
            $null = Get-PowershellMainWindow | ForEach-Object {

                $null = $_.setForeground()
                Set-ForegroundWindow $_.handle
            }
        }
        catch {
            Write-Verbose "Failed to set PowerShell window focus"
        }
    }

    end {
    }
}
################################################################################
################################################################################