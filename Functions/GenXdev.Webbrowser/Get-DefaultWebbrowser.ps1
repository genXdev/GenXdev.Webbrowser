###############################################################################
<#
.SYNOPSIS
Returns the configured default web browser for the current user.

.DESCRIPTION
Retrieves information about the system's default web browser by querying the
Windows Registry. Returns a hashtable containing the browser's name, description,
icon path, and executable path. The function checks both user preferences and
system-wide browser registrations to determine the default browser.

.EXAMPLE
        ###############################################################################Get detailed information about the default browser
Get-DefaultWebbrowser | Format-List

.EXAMPLE
        ###############################################################################Launch the default browser with a specific URL
$browser = Get-DefaultWebbrowser
& $browser.Path https://www.github.com/

.OUTPUTS
System.Collections.Hashtable with keys: Name, Description, Icon, Path

.NOTES
Requires Windows 10 or later operating system
        ###############################################################################>
function Get-DefaultWebbrowser {

    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param()

    begin {
        # define registry paths for url associations and browser information
        $urlAssocPath = "HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\" +
        "UrlAssociations\https\UserChoice"
        $browserPath = "HKLM:\SOFTWARE\WOW6432Node\Clients\StartMenuInternet"

        # ensure HKCU registry drive is available
        if (!(Microsoft.PowerShell.Management\Test-Path HKCU:)) {
            $null = Microsoft.PowerShell.Management\New-PSDrive -Name HKCU -PSProvider Registry `
                -Root HKEY_CURRENT_USER
        }

        # ensure HKLM registry drive is available
        if (!(Microsoft.PowerShell.Management\Test-Path HKLM:)) {
            $null = Microsoft.PowerShell.Management\New-PSDrive -Name HKLM -PSProvider Registry `
                -Root HKEY_LOCAL_MACHINE
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Retrieving default browser URL handler configuration"

        # get the default handler ID for HTTPS URLs from user preferences
        $urlHandlerId = Microsoft.PowerShell.Management\Get-ItemProperty -Path $urlAssocPath |
        Microsoft.PowerShell.Utility\Select-Object -ExpandProperty ProgId

        Microsoft.PowerShell.Utility\Write-Verbose "URL handler ID: $urlHandlerId"
    }


process {

        Microsoft.PowerShell.Utility\Write-Verbose "Scanning installed browsers in registry"

        # iterate through all registered browsers in the system
        foreach ($browser in (Microsoft.PowerShell.Management\Get-ChildItem -Path $browserPath)) {

            # construct the full registry path for the current browser
            $browserRoot = Microsoft.PowerShell.Management\Join-Path $browserPath $browser.PSChildName

            # verify browser has required registry keys for URL handling
            if ((Microsoft.PowerShell.Management\Test-Path "$browserRoot\shell\open\command") -and
                (Microsoft.PowerShell.Management\Test-Path "$browserRoot\Capabilities\URLAssociations")) {

                # get the HTTPS handler ID for this browser
                $browserHandler = Microsoft.PowerShell.Management\Get-ItemProperty `
                    -Path "$browserRoot\Capabilities\URLAssociations" |
                Microsoft.PowerShell.Utility\Select-Object -ExpandProperty https

                # check if this browser is the default handler
                if ($browserHandler -eq $urlHandlerId) {
                    Microsoft.PowerShell.Utility\Write-Verbose "Found default browser: $browserRoot"

                    # return browser details in a hashtable
                    return @{
                        Name        = (Microsoft.PowerShell.Management\Get-ItemProperty "$browserRoot\Capabilities" |
                            Microsoft.PowerShell.Utility\Select-Object -ExpandProperty ApplicationName)
                        Description = (Microsoft.PowerShell.Management\Get-ItemProperty "$browserRoot\Capabilities" |
                            Microsoft.PowerShell.Utility\Select-Object -ExpandProperty ApplicationDescription)
                        Icon        = (Microsoft.PowerShell.Management\Get-ItemProperty "$browserRoot\Capabilities" |
                            Microsoft.PowerShell.Utility\Select-Object -ExpandProperty ApplicationIcon)
                        Path        = (Microsoft.PowerShell.Management\Get-ItemProperty "$browserRoot\shell\open\command" |
                            Microsoft.PowerShell.Utility\Select-Object -ExpandProperty "(default)").Trim('"')
                    }
                }
            }
        }
    }

    end {
    }
}
        ###############################################################################