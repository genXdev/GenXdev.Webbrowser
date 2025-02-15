################################################################################
<#
.SYNOPSIS
Updates browser shortcuts to enable remote debugging ports.

.DESCRIPTION
Modifies Chrome and Edge browser shortcuts to include remote debugging port
parameters. This enables automation scripts to interact with the browsers through
their debugging interfaces. Handles both user-specific and system-wide shortcuts.

The function:
- Removes any existing debugging port parameters
- Adds current debugging ports for Chrome and Edge
- Updates shortcuts in common locations (Desktop, Start Menu, Quick Launch)
- Requires administrative rights for system-wide shortcuts

.EXAMPLE
Set-RemoteDebuggerPortInBrowserShortcuts
Updates all Chrome and Edge shortcuts with their respective debugging ports.

.NOTES
Requires administrative access to modify system shortcuts.
#>
function Set-RemoteDebuggerPortInBrowserShortcuts {

    [CmdletBinding()]
    [Alias("Set-BrowserDebugPorts")]
    param()

    begin {

        # initialize windows shell automation object for shortcut manipulation
        $shell = New-Object -ComObject WScript.Shell
        Write-Verbose "Created WScript.Shell COM object for shortcut management"
    }

    process {

        ########################################################################
        <#
        .SYNOPSIS
        Sanitizes shortcut arguments by removing existing debugging port settings.

        .DESCRIPTION
        Removes any existing remote debugging port parameters from shortcut
        arguments to prevent duplicate or conflicting port settings.

        .PARAMETER Arguments
        The current shortcut arguments string to clean.

        .EXAMPLE
        Remove-PreviousPortParam "--remote-debugging-port=9222 --other-param"
        Returns: "--other-param"
        #>
        function Remove-PreviousPortParam {

            [CmdletBinding()]
            param(
                [Parameter(
                    Mandatory = $true,
                    Position = 0,
                    HelpMessage = "Shortcut arguments string to sanitize"
                )]
                [string] $Arguments
            )

            # initialize working copy of arguments
            $cleanedArgs = $Arguments

            # find first occurrence of port parameter
            $portParamIndex = $cleanedArgs.IndexOf("--remote-debugging-port=")

            # continue cleaning while port parameters exist
            while ($portParamIndex -ge 0) {

                # remove port parameter and preserve other arguments
                $cleanedArgs = $cleanedArgs.Substring(0, $portParamIndex).Trim() `
                    + " " + $cleanedArgs.Substring($portParamIndex + 25).Trim()

                # remove any remaining port number digits
                while ($cleanedArgs.Length -ge 0 -and
                    "012345679".IndexOf($cleanedArgs[0]) -ge 0) {

                    $cleanedArgs = if ($cleanedArgs.Length -ge 1) {
                        $cleanedArgs.Substring(1)
                    }
                    else {
                        ""
                    }
                }

                # check for additional port parameters
                $portParamIndex = $cleanedArgs.IndexOf("--remote-debugging-port=")
            }

            return $cleanedArgs
        }

        # configure chrome debugging settings
        $chromePort = Get-ChromeRemoteDebuggingPort
        $chromeParam = " --remote-allow-origins=* --remote-debugging-port=$chromePort"
        Write-Verbose "Configuring Chrome debugging port: $chromePort"

        # define chrome shortcut paths to process
        $chromePaths = @(
            "$Env:AppData\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Google Chrome.lnk",
            "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk",
            (Join-Path (Get-KnownFolderPath StartMenu) "Google Chrome.lnk"),
            (Join-Path (Get-KnownFolderPath Desktop) "Google Chrome.lnk")
        )

        # update chrome shortcuts
        $chromePaths | ForEach-Object {
            Get-ChildItem $PSItem -File -Recurse -ErrorAction SilentlyContinue |
            ForEach-Object {
                try {
                    $shortcut = $shell.CreateShortcut($PSItem.FullName)
                    $shortcut.Arguments = $shortcut.Arguments.Replace("222", "")
                    $shortcut.Arguments = "$(Remove-PreviousPortParam $shortcut.Arguments) $chromeParam".Trim()
                    $null = $shortcut.Save()
                    Write-Verbose "Updated Chrome shortcut: $($PSItem.FullName)"
                }
                catch {
                    Write-Verbose "Failed to update Chrome shortcut: $($PSItem.FullName)"
                }
            }
        }

        # configure edge debugging settings
        $edgePort = Get-EdgeRemoteDebuggingPort
        $edgeParam = " --remote-allow-origins=* --remote-debugging-port=$edgePort"
        Write-Verbose "Configuring Edge debugging port: $edgePort"

        # define edge shortcut paths to process
        $edgePaths = @(
            "$Env:AppData\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Microsoft Edge.lnk",
            "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk",
            (Join-Path (Get-KnownFolderPath StartMenu) "Microsoft Edge.lnk"),
            (Join-Path (Get-KnownFolderPath Desktop) "Microsoft Edge.lnk")
        )

        # update edge shortcuts
        $edgePaths | ForEach-Object {
            Get-ChildItem $PSItem -File -Recurse -ErrorAction SilentlyContinue |
            ForEach-Object {
                try {
                    $shortcut = $shell.CreateShortcut($PSItem.FullName)
                    $shortcut.Arguments = "$(Remove-PreviousPortParam $shortcut.Arguments.Replace($edgeParam, '').Trim())$edgeParam"
                    $null = $shortcut.Save()
                    Write-Verbose "Updated Edge shortcut: $($PSItem.FullName)"
                }
                catch {
                    Write-Verbose "Failed to update Edge shortcut: $($PSItem.FullName)"
                }
            }
        }
    }

    end {
    }
}
################################################################################
