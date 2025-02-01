################################################################################
<#
.SYNOPSIS
Gets a serializable reference to the current browser tab session.

.DESCRIPTION
Returns a hashtable containing debugger URI, port, and data for the current
browser tab that can be used with Select-WebbrowserTab -ByReference. This is
useful for accessing the browser tab from within background jobs.

.EXAMPLE
Get-ChromiumSessionReference
#>
function Get-ChromiumSessionReference {

    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    begin {

        # check if browser session exists
        Write-Verbose "Checking for active browser session"

        # initialize global data hashtable if needed
        if ($Global:Data -isnot [Hashtable]) {
            $globalData = @{}
            $null = Set-Variable -Name "Data" -Value $globalData -Scope Global -Force
        }
        else {
            $globalData = $Global:Data
        }
    }

    process {

        # validate that an active chrome session exists
        if (($null -eq $Global:chromeSession) -or
            ($Global:chromeSession -isnot [PSCustomObject])) {

            throw "No active browser session. Use Select-WebbrowserTab first."
        }

        Write-Verbose "Found active session"

        if (($null -eq $Global:chromeController) -or ($Global:chromeController.IsClosed)) {

            throw "Browser session expired. Use Select-WebbrowserTab to select a new session."
        }

        Write-Verbose "Session is still active"

        # return hashtable with session reference data
        if (-not ($Global:chromeSession.data -is [hashtable])) {

            Add-Member -InputObject $Global:chromeSession -MemberType NoteProperty -Name "data" -Value $globalData -Force
        }

        return ($Global:chromeSession);
    }

    end {
    }
}
################################################################################
