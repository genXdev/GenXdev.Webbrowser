<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser.Playwright
Original cmdlet filename  : Get-PlaywrightProfileDirectory.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.276.2025
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