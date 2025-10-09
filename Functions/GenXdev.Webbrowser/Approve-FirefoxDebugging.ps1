<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser
Original cmdlet filename  : Approve-FirefoxDebugging.ps1
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