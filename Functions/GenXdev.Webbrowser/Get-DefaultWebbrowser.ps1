################################################################################
<#
.SYNOPSIS
Returns the configured default web browser for the current user.

.DESCRIPTION
Retrieves information about the system's default web browser, including its name,
description, icon path, and executable path by querying the Windows Registry.

.EXAMPLE
Get-DefaultWebbrowser | Format-List

.EXAMPLE
$browser = Get-DefaultWebbrowser
& $browser.Path https://www.github.com/

.NOTES
Requires Windows 10 or later operating system
#>
function Get-DefaultWebbrowser {

    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param()

    begin {

        # registry paths for browser information
        $urlAssocPath = "HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\" +
            "UrlAssociations\https\UserChoice"
        $browserPath = "HKLM:\SOFTWARE\WOW6432Node\Clients\StartMenuInternet"

        # ensure registry drives are available
        if (!(Test-Path HKCU:)) {
            $null = New-PSDrive -Name HKCU -PSProvider Registry `
                -Root HKEY_CURRENT_USER
        }

        if (!(Test-Path HKLM:)) {
            $null = New-PSDrive -Name HKLM -PSProvider Registry `
                -Root HKEY_LOCAL_MACHINE
        }

        Write-Verbose "Retrieving default browser URL handler configuration"

        # get the handler id for https urls from user preferences
        $urlHandlerId = Get-ItemProperty -Path $urlAssocPath |
            Select-Object -ExpandProperty ProgId

        Write-Verbose "URL handler ID: $urlHandlerId"
    }

    process {

        Write-Verbose "Scanning installed browsers in registry"

        # iterate through all installed browsers
        foreach ($browser in (Get-ChildItem -Path $browserPath)) {

            # construct full registry path for current browser
            $browserRoot = Join-Path $browserPath $browser.PSChildName

            # check if this browser is the default handler
            if ((Test-Path "$browserRoot\shell\open\command") -and
                (Test-Path "$browserRoot\Capabilities\URLAssociations")) {

                $browserHandler = Get-ItemProperty `
                    -Path "$browserRoot\Capabilities\URLAssociations" |
                    Select-Object -ExpandProperty https

                if ($browserHandler -eq $urlHandlerId) {
                    Write-Verbose "Found default browser: $browserRoot"

                    # return browser details
                    return @{
                        Name = (Get-ItemProperty "$browserRoot\Capabilities" |
                            Select-Object -ExpandProperty ApplicationName)
                        Description = (Get-ItemProperty "$browserRoot\Capabilities" |
                            Select-Object -ExpandProperty ApplicationDescription)
                        Icon = (Get-ItemProperty "$browserRoot\Capabilities" |
                            Select-Object -ExpandProperty ApplicationIcon)
                        Path = (Get-ItemProperty "$browserRoot\shell\open\command" |
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
