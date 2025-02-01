################################################################################
<#
.SYNOPSIS
Updates browser shortcuts to enable remote debugging by default.

.DESCRIPTION
Modifies Chrome and Edge browser shortcuts to include remote debugging port
parameters. This enables automation scripts to interact with the browsers through
their debugging interfaces.

.EXAMPLE
Set-RemoteDebuggerPortInBrowserShortcuts

.NOTES
Requires administrative access to modify system shortcuts.
#>
function Set-RemoteDebuggerPortInBrowserShortcuts {

    [CmdletBinding()]
    [Alias("Set-BrowserDebugPorts")]

    param()

    begin {

        # initialize shell com object for shortcut manipulation
        $shell = New-Object -ComObject WScript.Shell
        Write-Verbose "Initialized WScript.Shell for shortcut manipulation"
    }

    process {

        # helper function to clean existing port parameters from shortcut
        function Remove-PreviousPortParam {
            [CmdletBinding()]
            param(
                [Parameter(
                    Mandatory = $true,
                    Position = 0,
                    HelpMessage = "Shortcut arguments to clean"
                )]
                [string] $Arguments
            )

            $cleanedArgs = $Arguments
            $portParamIndex = $cleanedArgs.IndexOf("--remote-debugging-port=")

            # loop while we find instances of the port parameter
            while ($portParamIndex -ge 0) {

                # remove the parameter and port number
                $cleanedArgs = $cleanedArgs.Substring(0, $portParamIndex).Trim() `
                    + " " + $cleanedArgs.Substring($portParamIndex + 25).Trim()

                # remove remaining port digits
                while ($cleanedArgs.Length -ge 0 -and
                    "012345679".IndexOf($cleanedArgs[0]) -ge 0) {

                    $cleanedArgs = if ($cleanedArgs.Length -ge 1) {
                        $cleanedArgs.Substring(1)
                    }
                    else {
                        ""
                    }
                }

                $portParamIndex = $cleanedArgs.IndexOf("--remote-debugging-port=")
            }

            return $cleanedArgs
        }

        # get chrome debugging port
        $chromePort = Get-ChromeRemoteDebuggingPort
        $chromeParam = " --remote-allow-origins=* --remote-debugging-port=$chromePort"
        Write-Verbose "Using Chrome debugging port: $chromePort"

        # chrome shortcut paths to update
        $chromePaths = @(
            "$Env:AppData\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Google Chrome.lnk",
            "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk",
            (Join-Path (Get-KnownFolderPath StartMenu) "Google Chrome.lnk"),
            (Join-Path (Get-KnownFolderPath Desktop) "Google Chrome.lnk")
        )

        # update each chrome shortcut
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

        # get edge debugging port
        $edgePort = Get-EdgeRemoteDebuggingPort
        $edgeParam = " --remote-allow-origins=* --remote-debugging-port=$edgePort"
        Write-Verbose "Using Edge debugging port: $edgePort"

        # edge shortcut paths to update
        $edgePaths = @(
            "$Env:AppData\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Microsoft Edge.lnk",
            "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk",
            (Join-Path (Get-KnownFolderPath StartMenu) "Microsoft Edge.lnk"),
            (Join-Path (Get-KnownFolderPath Desktop) "Microsoft Edge.lnk")
        )

        # update each edge shortcut
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
