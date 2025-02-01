################################################################################
<#
.SYNOPSIS
Takes control of the selected webbrowser tab.

.DESCRIPTION
Allows interactive control of a browser tab previously selected using the
Select-WebbrowserTab cmdlet. Provides access to the Microsoft Playwright Page
object properties and methods.

.PARAMETER UseCurrent
Use the currently assigned tab instead of selecting a new one.

.PARAMETER Force
Restart webbrowser (closes all tabs) if no debugging server is detected.

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

        # inform user that control sequence is starting
        # Write-Verbose "Initializing browser tab control sequence..."

        $pwshW = Get-PowershellMainWindow
        $pwshP = Get-PowershellMainWindowProcess
    }

    process {

        if (-not $UseCurrent) {

            Clear-Host

            # Write-Verbose "Prompting user to select a browser tab..."
            Write-Host "Select to which browser tab you want to send commands to"

            # attempt to select available browser tabs
            Select-WebbrowserTab -Force:$Force | Out-Host

            if ($Global:ChromeSessions.Length -eq 0) {

                Write-Host "No browser tabs are open"
                return
            }

            # get valid tab selection from user
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

            # select the specified tab
            Select-WebbrowserTab $tabNumber
        }

        if (-not $Global:chromeController) {

            Write-Host "No ChromeController object found"
            return
        }

        try {

            $pwshW.maximize();
        }
        catch {

        }

        # create job to send keyboard commands in background
        $null = Start-Job {

            # send sequence to reveal chrome controller object
            $null = Send-Keys `
                "{Escape}", "Clear-Host", "{Enter}", "`$ChromeController", ".", "^( )", "y" `
                -DelayMilliSeconds 500

            # wait for commands to complete
            $null = Start-Sleep 3
        }

        try {
            # attempt to focus the powershell window
            $null = Get-PowershellMainWindow | ForEach-Object {

                $null = $_.setForeground()
                Set-ForegroundWindow $_.handle
            }
        }
        catch {
            # Write-Verbose "Failed to set PowerShell window focus: $_"
        }
    }

    end {
    }
}
################################################################################
################################################################################