################################################################################
<#
.SYNOPSIS
Returns the configured default web browser for the current user.

.DESCRIPTION
Retrieves information about the system's default web browser by querying the
Windows Registry. Returns a hashtable containing the browser's name, description,
icon path, and executable path. The function checks both user preferences and
system-wide browser registrations to determine the default browser.

.EXAMPLE
# Get detailed information about the default browser
Get-DefaultWebbrowser | Format-List

.EXAMPLE
# Launch the default browser with a specific URL
$browser = Get-DefaultWebbrowser
& $browser.Path https://www.github.com/

.OUTPUTS
System.Collections.Hashtable with keys: Name, Description, Icon, Path

.NOTES
Requires Windows 10 or later operating system
#>
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
        if (!(Test-Path HKCU:)) {
            $null = New-PSDrive -Name HKCU -PSProvider Registry `
                -Root HKEY_CURRENT_USER
        }

        # ensure HKLM registry drive is available
        if (!(Test-Path HKLM:)) {
            $null = New-PSDrive -Name HKLM -PSProvider Registry `
                -Root HKEY_LOCAL_MACHINE
        }

        Write-Verbose "Retrieving default browser URL handler configuration"

        # get the default handler ID for HTTPS URLs from user preferences
        $urlHandlerId = Get-ItemProperty -Path $urlAssocPath |
        Select-Object -ExpandProperty ProgId

        Write-Verbose "URL handler ID: $urlHandlerId"
    }

    process {

        Write-Verbose "Scanning installed browsers in registry"

        # iterate through all registered browsers in the system
        foreach ($browser in (Get-ChildItem -Path $browserPath)) {

            # construct the full registry path for the current browser
            $browserRoot = Join-Path $browserPath $browser.PSChildName

            # verify browser has required registry keys for URL handling
            if ((Test-Path "$browserRoot\shell\open\command") -and
                (Test-Path "$browserRoot\Capabilities\URLAssociations")) {

                # get the HTTPS handler ID for this browser
                $browserHandler = Get-ItemProperty `
                    -Path "$browserRoot\Capabilities\URLAssociations" |
                Select-Object -ExpandProperty https

                # check if this browser is the default handler
                if ($browserHandler -eq $urlHandlerId) {
                    Write-Verbose "Found default browser: $browserRoot"

                    # return browser details in a hashtable
                    return @{
                        Name        = (Get-ItemProperty "$browserRoot\Capabilities" |
                            Select-Object -ExpandProperty ApplicationName)
                        Description = (Get-ItemProperty "$browserRoot\Capabilities" |
                            Select-Object -ExpandProperty ApplicationDescription)
                        Icon        = (Get-ItemProperty "$browserRoot\Capabilities" |
                            Select-Object -ExpandProperty ApplicationIcon)
                        Path        = (Get-ItemProperty "$browserRoot\shell\open\command" |
                            Select-Object -ExpandProperty "(default)").Trim('"')
                    }
                }
            }
        }
    }

    end {
    }
}
################################################################################
