<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser
Original cmdlet filename  : Get-Webbrowser.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.300.2025
################################################################################
Copyright (c)  René Vaessen / GenXdev

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
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

    [CmdletBinding(DefaultParameterSetName = 'Default', SupportsShouldProcess = $false, ConfirmImpact = 'None')]
    [OutputType([System.Collections.Hashtable[]])]
    param(
         ########################################################################
        [Alias('e')]
        [parameter(
            Mandatory = $false,
            Position = 0,
            ParameterSetName = 'Specific',
            HelpMessage = 'Selects Microsoft Edge browser instances'
        )]
        [switch] $Edge,
        ########################################################################
        [Alias('ch')]
        [parameter(
            Mandatory = $false,
            Position = 1,
            ParameterSetName = 'Specific',
            HelpMessage = 'Selects Google Chrome browser instances'
        )]
        [switch] $Chrome,
        ########################################################################
        [Alias('c')]
        [parameter(
            Mandatory = $false,
            Position = 2,
            ParameterSetName = 'Specific',
            HelpMessage = 'Selects default chromium-based browser'
        )]
        [switch] $Chromium,
        ########################################################################
        [Alias('ff')]
        [parameter(
            Mandatory = $false,
            Position = 3,
            ParameterSetName = 'Specific',
            HelpMessage = 'Selects Firefox browser instances'
        )]
        [switch] $Firefox
    )

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
                            } | Microsoft.PowerShell.Core\Where-Object {

                                $IsEdge = ($capabilities.ApplicationName -like '*Edge*');
                                $IsChrome = ($capabilities.ApplicationName -like '*Chrome*');
                                $IsFirefox = ($capabilities.ApplicationName -like '*Firefox*');
                                $IsChromium = $IsEdge -or $IsChrome;

                                # if no specific browser is requested, return all
                                # filter results based on parameters
                                ($PSCmdlet.ParameterSetName -eq 'Specific' -and
                                    ( ($Edge -and $IsEdge) -or
                                      ($Chrome -and $IsChrome) -or
                                      ($Chromium -and $IsChromium) -or
                                      ($Firefox -and $IsFirefox)
                                    )
                                ) -or
                                ($PSCmdlet.ParameterSetName -eq 'Default' )
                            }
                        }
                    }
    }

    end {
    }
}