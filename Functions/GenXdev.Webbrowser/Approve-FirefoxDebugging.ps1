<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser
Original cmdlet filename  : Approve-FirefoxDebugging.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.272.2025
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
Configures Firefox's debugging and standalone app mode features.

.DESCRIPTION
Enables remote debugging and standalone app mode (SSB) capabilities in Firefox by
modifying user preferences in the prefs.js file of all Firefox profile
directories. This function updates or adds required debugging preferences to
enable development tools and remote debugging while disabling connection prompts.

.EXAMPLE
Approve-FirefoxDebugging

Enables remote debugging and SSB features across all Firefox profiles found in
the current user's AppData directory.
#>
function Approve-FirefoxDebugging {

    [CmdletBinding()]
    [OutputType([void])]
    param()

    begin {
        # construct the path to firefox profiles using environment variables
        $profilesPath = Microsoft.PowerShell.Management\Join-Path -Path $env:APPDATA -ChildPath 'Mozilla\Firefox\Profiles'
        Microsoft.PowerShell.Utility\Write-Verbose "Searching for Firefox profiles in: $profilesPath"

        # define new preferences to be added to firefox configuration
        $newPrefs = @(
            'user_pref("devtools.chrome.enabled", true);',
            'user_pref("devtools.debugger.remote-enabled", true);',
            'user_pref("devtools.debugger.prompt-connection", false);',
            'user_pref("browser.ssb.enabled", true);'
        )

        # define preference keys that need to be removed before adding new ones
        $prefsToFilter = @(
            '"browser.ssb.enabled"',
            '"devtools.chrome.enabled"',
            '"devtools.debugger.remote-enabled"',
            '"devtools.debugger.prompt-connection"'
        )
    }


    process {

        try {
            # locate all firefox preference files recursively
            $prefFiles = Microsoft.PowerShell.Management\Get-ChildItem -LiteralPath $profilesPath `
                -Filter "prefs.js" `
                -File `
                -Recurse `
                -ErrorAction SilentlyContinue

            foreach ($prefFile in $prefFiles) {
                Microsoft.PowerShell.Utility\Write-Verbose "Processing preferences file: $($prefFile.FullName)"

                # safely read existing preferences using system io
                $prefLines = [System.IO.File]::ReadAllLines($prefFile.FullName)

                # filter out existing debug/app-mode preferences
                $prefLines = $prefLines | Microsoft.PowerShell.Core\Where-Object {
                    $line = $_
                    -not ($prefsToFilter | Microsoft.PowerShell.Core\Where-Object { $line.Contains($_) })
                }

                # append new preferences to the filtered configuration
                $prefLines += $newPrefs

                # safely write updated preferences back to file
                [System.IO.File]::WriteAllLines($prefFile.FullName, $prefLines)
                Microsoft.PowerShell.Utility\Write-Verbose "Successfully updated preferences in: $($prefFile.FullName)"
            }
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Error "Failed to update Firefox preferences: $_"
            throw
        }
    }

    end {
    }
}