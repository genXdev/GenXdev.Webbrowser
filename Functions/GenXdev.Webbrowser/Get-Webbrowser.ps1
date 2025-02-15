################################################################################
<#
.SYNOPSIS
Returns a collection of installed modern web browsers.

.DESCRIPTION
Discovers and returns details about modern web browsers installed on the system.
Retrieves information including name, description, icon path, executable path and
default browser status by querying the Windows registry. Only returns browsers
that have the required capabilities registered in Windows.

.OUTPUTS
System.Collections.Hashtable[]
Returns an array of hashtables containing browser details:
- Name: Browser application name
- Description: Browser description
- Icon: Path to browser icon
- Path: Path to browser executable
- IsDefaultBrowser: Boolean indicating if this is the default browser

.EXAMPLE
Get-Webbrowser | Select-Object Name, Description | Format-Table

.EXAMPLE
# Get just the default browser
Get-Webbrowser | Where-Object { $_.IsDefaultBrowser }

.NOTES
Requires Windows 10 or later Operating System
#>
function Get-Webbrowser {

    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable[]])]
    param()

    begin {

        # ensure the HKEY_CURRENT_USER registry drive is mounted
        if (!(Test-Path HKCU:\)) {
            $null = New-PSDrive -Name HKCU `
                -PSProvider Registry `
                -Root HKEY_CURRENT_USER
        }

        # ensure the HKEY_LOCAL_MACHINE registry drive is mounted
        if (!(Test-Path HKLM:\)) {
            $null = New-PSDrive -Name HKLM `
                -PSProvider Registry `
                -Root HKEY_LOCAL_MACHINE
        }

        # get the user's default handler for https URLs from registry settings
        Write-Verbose "Retrieving default browser URL handler ID from registry"
        $urlHandlerId = Get-ItemProperty `
            "HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" |
        Select-Object -ExpandProperty ProgId
    }

    process {

        # enumerate all browser entries in the Windows registry
        Write-Verbose "Enumerating installed browsers from registry"
        Get-ChildItem "HKLM:\SOFTWARE\WOW6432Node\Clients\StartMenuInternet" |
        ForEach-Object {

            # construct the full registry path for the current browser
            $browserRoot = "HKLM:\SOFTWARE\WOW6432Node\Clients\StartMenuInternet\" +
            "$($PSItem.PSChildName)"

            # verify browser has required capabilities and command info
            if ((Test-Path "$browserRoot\shell\open\command") -and
                    (Test-Path "$browserRoot\Capabilities")) {

                Write-Verbose "Processing browser details at: $browserRoot"

                # get browser capabilities metadata from registry
                $capabilities = Get-ItemProperty "$browserRoot\Capabilities"

                # extract the browser executable path, removing quotes
                $browserPath = Get-ItemProperty "$browserRoot\shell\open\command" |
                Select-Object -ExpandProperty "(default)" |
                ForEach-Object { $_.Trim('"') }

                # determine if this browser is set as the system default
                $isDefault = (Test-Path "$browserRoot\Capabilities\URLAssociations") -and
                        ((Get-ItemProperty "$browserRoot\Capabilities\URLAssociations" |
                    Select-Object -ExpandProperty https) -eq $urlHandlerId)

                # return a hashtable with the browser's details
                @{
                    Name             = $capabilities.ApplicationName
                    Description      = $capabilities.ApplicationDescription
                    Icon             = $capabilities.ApplicationIcon
                    Path             = $browserPath
                    IsDefaultBrowser = $isDefault
                }
            }
        }
    }

    end {
    }
}
################################################################################
