<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser
Original cmdlet filename  : Get-Webbrowser.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.270.2025
################################################################################
MIT License

Copyright 2021-2025 GenXdev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
################################################################################>
###############################################################################
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
Get just the default browser
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
        if (!(Microsoft.PowerShell.Management\Test-Path HKCU:\)) {
            $null = Microsoft.PowerShell.Management\New-PSDrive -Name HKCU `
                -PSProvider Registry `
                -Root HKEY_CURRENT_USER
        }

        # ensure the HKEY_LOCAL_MACHINE registry drive is mounted
        if (!(Microsoft.PowerShell.Management\Test-Path HKLM:\)) {
            $null = Microsoft.PowerShell.Management\New-PSDrive -Name HKLM `
                -PSProvider Registry `
                -Root HKEY_LOCAL_MACHINE
        }

        # get the user's default handler for https URLs from registry settings
        Microsoft.PowerShell.Utility\Write-Verbose 'Retrieving default browser URL handler ID from registry'
        $urlHandlerId = Microsoft.PowerShell.Management\Get-ItemProperty `
            'HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice' |
            Microsoft.PowerShell.Utility\Select-Object -ExpandProperty ProgId
    }


    process {

        # enumerate all browser entries in the Windows registry
        Microsoft.PowerShell.Utility\Write-Verbose 'Enumerating installed browsers from registry'
        Microsoft.PowerShell.Management\Get-ChildItem 'HKLM:\SOFTWARE\WOW6432Node\Clients\StartMenuInternet' |
            Microsoft.PowerShell.Core\ForEach-Object {

                # construct the full registry path for the current browser
                $browserRoot = 'HKLM:\SOFTWARE\WOW6432Node\Clients\StartMenuInternet\' +
                "$($PSItem.PSChildName)"

                # verify browser has required capabilities and command info
                if ((Microsoft.PowerShell.Management\Test-Path -LiteralPath "$browserRoot\shell\open\command") -and
                    (Microsoft.PowerShell.Management\Test-Path -LiteralPath "$browserRoot\Capabilities")) {

                    Microsoft.PowerShell.Utility\Write-Verbose "Processing browser details at: $browserRoot"

                    # get browser capabilities metadata from registry
                    $capabilities = Microsoft.PowerShell.Management\Get-ItemProperty "$browserRoot\Capabilities"

                    # extract the browser executable path, removing quotes
                    $browserPath = Microsoft.PowerShell.Management\Get-ItemProperty "$browserRoot\shell\open\command" |
                        Microsoft.PowerShell.Utility\Select-Object -ExpandProperty '(default)' |
                        Microsoft.PowerShell.Core\ForEach-Object { $_.Trim('"') }

                        # determine if this browser is set as the system default
                        $isDefault = (Microsoft.PowerShell.Management\Test-Path -LiteralPath "$browserRoot\Capabilities\URLAssociations") -and
                        ((Microsoft.PowerShell.Management\Get-ItemProperty "$browserRoot\Capabilities\URLAssociations" |
                                Microsoft.PowerShell.Utility\Select-Object -ExpandProperty https) -eq $urlHandlerId)

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