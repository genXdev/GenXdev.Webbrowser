###############################################################################
<#
.SYNOPSIS
Gets a serializable reference to the current browser tab session.

.DESCRIPTION
Returns a hashtable containing debugger URI, port, and session data for the
current browser tab. This reference can be used with Select-WebbrowserTab
-ByReference to reconnect to the same tab, especially useful in background jobs
or across different PowerShell sessions.

The function validates the existence of an active chrome session and ensures
the browser controller is still running before returning the session reference.

.EXAMPLE
Get a reference to the current chrome tab session
$sessionRef = Get-ChromiumSessionReference

.EXAMPLE
Store the reference and use it later to reconnect
$ref = Get-ChromiumSessionReference
Select-WebbrowserTab -ByReference $ref
#>
function Get-ChromiumSessionReference {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [OutputType([hashtable])]
    param()

    begin {
        # verify if a browser session exists in global scope
        Microsoft.PowerShell.Utility\Write-Verbose 'Checking for active browser session'

        # create global data storage if it doesn't exist
        if ($Global:Data -isnot [Hashtable]) {
            $globalData = @{}
            $null = Microsoft.PowerShell.Utility\Set-Variable -Name 'Data' -Value $globalData `
                -Scope Global -Force
        }
        else {
            $globalData = $Global:Data
        }
    }


    process {

        # ensure chrome session exists and is of correct type
        if (($null -eq $Global:chromeSession) -or
            ($Global:chromeSession -isnot [PSCustomObject])) {

            throw 'No browser available with open debugging port, use -Force to restart'
        }

        Microsoft.PowerShell.Utility\Write-Verbose 'Found active session'

        # verify chrome controller is still active
        if (($null -eq $Global:chromeController) -or
            ($Global:chromeController.IsClosed)) {

            throw 'Browser session expired. Use Select-WebbrowserTab to select' +
            ' a new session.'
        }

        Microsoft.PowerShell.Utility\Write-Verbose 'Session is still active'

        # ensure session has data property and return reference
        if (-not ($Global:chromeSession.data -is [hashtable])) {

            Microsoft.PowerShell.Utility\Add-Member -InputObject $Global:chromeSession `
                -MemberType NoteProperty -Name 'data' -Value $globalData -Force
        }

        return ($Global:chromeSession);
    }

    end {
    }
}