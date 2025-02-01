################################################################################
<#
.SYNOPSIS
Gets the Playwright browser profile directory for persistent sessions.

.DESCRIPTION
Retrieves or creates the profile directory used by Playwright for persistent
browser sessions. The directory is created under LocalAppData if it doesn't exist.

.PARAMETER BrowserType
The type of browser to get or create a profile directory for. Valid values are
Chromium, Firefox, or Webkit.

.EXAMPLE
Get-PlaywrightProfileDirectory -BrowserType Chromium

.EXAMPLE
Get-PlaywrightProfileDirectory Firefox
#>
function Get-PlaywrightProfileDirectory {

    [CmdletBinding()]
    param(
        #######################################################################
        [Parameter(
            Position = 0,
            HelpMessage = "The browser type (Chromium, Firefox, or Webkit)"
        )]
        [ValidateSet("Chromium", "Firefox", "Webkit")]
        [string]$BrowserType = "Chromium"
        #######################################################################
    )

    begin {
        # construct the base directory path under LocalAppData
        $baseDir = Join-Path -Path $env:LOCALAPPDATA `
            -ChildPath "GenXdev.Powershell\Playwright.profiles\"
    }

    process {
        # combine the base directory with the specific browser type
        $browserDir = Join-Path -Path $baseDir -ChildPath $BrowserType

        # create the directory if it doesn't exist
        if (-not (Test-Path -Path $browserDir)) {
            $null = New-Item -ItemType Directory -Path $browserDir -Force
            Write-Host "Created profile directory for $BrowserType at: $browserDir"
        }

        # return the full path to the browser profile directory
        return $browserDir
    }

    end {
    }
}
################################################################################
