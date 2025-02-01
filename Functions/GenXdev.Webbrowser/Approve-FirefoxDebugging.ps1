################################################################################
<#
.SYNOPSIS
Configures Firefox to enable remote debugging and app-mode features.

.DESCRIPTION
Modifies Firefox user preferences to enable remote debugging capabilities and 
standalone app mode (SSB) features. Updates the prefs.js files in all Firefox 
profile directories by adding or updating required debugging preferences.

.EXAMPLE
Approve-FirefoxDebugging

Enables remote debugging and SSB features in all Firefox profiles.
#>
function Approve-FirefoxDebugging {

    [CmdletBinding()]
    [OutputType([void])]
    param()

    begin {

        # define firefox profiles directory path using environment variable
        $profilesPath = Join-Path -Path $env:APPDATA -ChildPath "Mozilla\Firefox\Profiles"
        Write-Verbose "Searching for Firefox profiles in: $profilesPath"

        # define the preferences that need to be added or updated
        $newPrefs = @(
            'user_pref("devtools.chrome.enabled", true);',
            'user_pref("devtools.debugger.remote-enabled", true);',
            'user_pref("devtools.debugger.prompt-connection", false);',
            'user_pref("browser.ssb.enabled", true);'
        )

        # define preference keys to remove before adding new ones
        $prefsToFilter = @(
            '"browser.ssb.enabled"',
            '"devtools.chrome.enabled"',
            '"devtools.debugger.remote-enabled"',
            '"devtools.debugger.prompt-connection"'
        )
    }

    process {

        try {
            # find all prefs.js files in firefox profile directories
            $prefFiles = Get-ChildItem -Path $profilesPath `
                -Filter "prefs.js" `
                -File `
                -Recurse `
                -ErrorAction SilentlyContinue

            foreach ($prefFile in $prefFiles) {
                Write-Verbose "Processing preferences file: $($prefFile.FullName)"

                # read existing preferences using safe io methods
                $prefLines = [System.IO.File]::ReadAllLines($prefFile.FullName)

                # remove any existing debug/app-mode preferences
                $prefLines = $prefLines | Where-Object {
                    $line = $_
                    -not ($prefsToFilter | Where-Object { $line.Contains($_) })
                }

                # add new preferences to the filtered list
                $prefLines += $newPrefs

                # save updated preferences using safe io methods
                [System.IO.File]::WriteAllLines($prefFile.FullName, $prefLines)
                Write-Verbose "Successfully updated preferences in: $($prefFile.FullName)"
            }
        }
        catch {
            Write-Error "Failed to update Firefox preferences: $_"
            throw
        }
    }

    end {
    }
}
################################################################################
