<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser.Playwright
Original cmdlet filename  : Get-PlaywrightProfileDirectory.ps1
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
Gets the Playwright browser profile directory for persistent sessions.

.DESCRIPTION
Creates and manages browser profile directories for Playwright automated testing.
Profiles are stored in LocalAppData under GenXdev.Powershell/Playwright.profiles.
These profiles enable persistent sessions across browser automation runs.

.PARAMETER BrowserType
Specifies the browser type to create/get a profile directory for. Can be
Chromium, Firefox, or Webkit. Defaults to Chromium if not specified.

.EXAMPLE
Get-PlaywrightProfileDirectory -BrowserType Chromium
Creates or returns path: %LocalAppData%\GenXdev.Powershell\Playwright.profiles\Chromium

.EXAMPLE
Get-PlaywrightProfileDirectory Firefox
Creates or returns Firefox profile directory using positional parameter.
#>
function Get-PlaywrightProfileDirectory {

    [CmdletBinding()]
    param(
        ########################################################################
        [Parameter(
            Position = 0,
            HelpMessage = 'The browser type (Chromium, Firefox, or Webkit)'
        )]
        [ValidateSet('Chromium', 'Firefox', 'Webkit')]
        [string]$BrowserType = 'Chromium'
        ########################################################################
    )

    begin {
        # construct the base directory path for all browser profiles
        $baseDir = Microsoft.PowerShell.Management\Join-Path -Path $env:LOCALAPPDATA `
            -ChildPath 'GenXdev.Powershell\Playwright.profiles\'

        Microsoft.PowerShell.Utility\Write-Verbose "Base profile directory: $baseDir"
    }


    process {

        # generate the specific browser profile directory path
        $browserDir = Microsoft.PowerShell.Management\Join-Path -Path $baseDir -ChildPath $BrowserType

        Microsoft.PowerShell.Utility\Write-Verbose "Browser profile directory: $browserDir"

        # ensure the profile directory exists
        if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $browserDir)) {

            Microsoft.PowerShell.Utility\Write-Verbose "Creating new profile directory for $BrowserType"
            $null = Microsoft.PowerShell.Management\New-Item -ItemType Directory -Path $browserDir -Force
            Microsoft.PowerShell.Utility\Write-Host "Created profile directory for $BrowserType at: $browserDir"
        }

        # return the full profile directory path
        return $browserDir
    }

    end {
    }
}