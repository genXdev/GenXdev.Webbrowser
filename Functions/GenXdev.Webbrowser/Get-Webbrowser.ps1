################################################################################
<#
.SYNOPSIS
Returns a collection of installed modern webbrowsers.

.DESCRIPTION
Returns a collection of objects each describing an installed modern webbrowser,
including name, description, icon path, executable path and default browser status.
Only returns browsers that have the required capabilities registered in Windows.

.EXAMPLE
Get-Webbrowser | Select-Object Name, Description | Format-Table

.NOTES
Requires Windows 10 or later Operating System
#>
function Get-Webbrowser {

    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable[]])]
    param()

    begin {

        # ensure HKCU registry drive is mounted
        if (!(Test-Path HKCU:\)) {
            $null = New-PSDrive -Name HKCU `
                -PSProvider Registry `
                -Root HKEY_CURRENT_USER
        }

        # ensure HKLM registry drive is mounted
        if (!(Test-Path HKLM:\)) {
            $null = New-PSDrive -Name HKLM `
                -PSProvider Registry `
                -Root HKEY_LOCAL_MACHINE
        }

        # get handler id for https urls from user preferences
        Write-Verbose "Retrieving default browser URL handler ID from registry"
        $urlHandlerId = Get-ItemProperty `
            "HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" |
            Select-Object -ExpandProperty ProgId
    }

    process {

        # get list of installed browsers from registry
        Write-Verbose "Enumerating installed browsers"
        Get-ChildItem "HKLM:\SOFTWARE\WOW6432Node\Clients\StartMenuInternet" |
            ForEach-Object {

                # construct full registry path for current browser
                $browserRoot = "HKLM:\SOFTWARE\WOW6432Node\Clients\StartMenuInternet\" +
                    "$($PSItem.PSChildName)"

                # check if browser has required capabilities registered
                if ((Test-Path "$browserRoot\shell\open\command") -and
                    (Test-Path "$browserRoot\Capabilities")) {

                    Write-Verbose "Processing browser at: $browserRoot"

                    # get browser capabilities from registry
                    $capabilities = Get-ItemProperty "$browserRoot\Capabilities"

                    # get browser executable path
                    $browserPath = Get-ItemProperty "$browserRoot\shell\open\command" |
                        Select-Object -ExpandProperty "(default)" |
                        ForEach-Object { $_.Trim('"') }

                    # check if this is the default browser
                    $isDefault = (Test-Path "$browserRoot\Capabilities\URLAssociations") -and
                        ((Get-ItemProperty "$browserRoot\Capabilities\URLAssociations" |
                            Select-Object -ExpandProperty https) -eq $urlHandlerId)

                    # return browser details
                    @{
                        Name             = $capabilities.ApplicationName
                        Description      = $capabilities.ApplicationDescription
                        Icon            = $capabilities.ApplicationIcon
                        Path            = $browserPath
                        IsDefaultBrowser = $isDefault
                    }
                }
            }
    }

    end {
    }
}
################################################################################
