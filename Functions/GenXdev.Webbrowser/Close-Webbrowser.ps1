<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser
Original cmdlet filename  : Close-Webbrowser.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.286.2025
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
Closes one or more webbrowser instances selectively.

.DESCRIPTION
Provides granular control over closing web browser instances. Can target specific
browsers (Edge, Chrome, Firefox) or close all browsers. Supports closing both main
windows and background processes.

.PARAMETER Edge
Closes all Microsoft Edge browser instances.

.PARAMETER Chrome
Closes all Google Chrome browser instances.

.PARAMETER Chromium
Closes the default Chromium-based browser (Edge or Chrome).

.PARAMETER Firefox
Closes all Firefox browser instances.

.PARAMETER All
Closes all detected modern browser instances.

.PARAMETER IncludeBackgroundProcesses
Also closes background processes and tasks for the selected browsers.

.EXAMPLE
Close-Webbrowser -Chrome -Firefox -IncludeBackgroundProcesses
Closes all Chrome and Firefox instances including background processes

.EXAMPLE
wbc -a -bg
Closes all browser instances including background processes using aliases
#>
function Close-Webbrowser {

    [CmdletBinding(DefaultParameterSetName = 'Specific')]
    [Alias('wbc')]

    param(
        ########################################################################
        [Alias('e')]
        [parameter(
            Mandatory = $false,
            Position = 0,
            ParameterSetName = 'Specific',
            HelpMessage = 'Closes Microsoft Edge browser instances'
        )]
        [switch] $Edge,
        ########################################################################
        [Alias('ch')]
        [parameter(
            Mandatory = $false,
            Position = 1,
            ParameterSetName = 'Specific',
            HelpMessage = 'Closes Google Chrome browser instances'
        )]
        [switch] $Chrome,
        ########################################################################
        [Alias('c')]
        [parameter(
            Mandatory = $false,
            Position = 2,
            ParameterSetName = 'Specific',
            HelpMessage = 'Closes default chromium-based browser'
        )]
        [switch] $Chromium,
        ########################################################################
        [Alias('ff')]
        [parameter(
            Mandatory = $false,
            Position = 3,
            ParameterSetName = 'Specific',
            HelpMessage = 'Closes Firefox browser instances'
        )]
        [switch] $Firefox,
        ########################################################################
        [Alias('a')]
        [parameter(
            Mandatory = $false,
            Position = 0,
            ParameterSetName = 'All',
            HelpMessage = 'Closes all registered modern browsers'
        )]
        [switch] $All,
        ########################################################################
        [Alias('bg', 'Force')]
        [parameter(
            Mandatory = $false,
            Position = 4,
            HelpMessage = 'Closes all instances including background tasks'
        )]
        [switch] $IncludeBackgroundProcesses
        ########################################################################
    )

    begin {
        # query system for installed browser information
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.Webbrowser\Get-Webbrowser" `
            -DefaultValues (Get-Variable -Scope Local -ErrorAction SilentlyContinue)

        $installedBrowsers = GenXdev.Webbrowser\Get-Webbrowser @params

        # determine system default browser
        $defaultBrowser = GenXdev.Webbrowser\Get-DefaultWebbrowser

        Microsoft.PowerShell.Utility\Write-Verbose "Found $($installedBrowsers.Count) installed browsers"
        Microsoft.PowerShell.Utility\Write-Verbose "Default browser: $($defaultBrowser.Name)"
    }


    process {

        function Close-BrowserInstance {
            param (
                [object] $Browser
            )

            Microsoft.PowerShell.Utility\Write-Verbose "Attempting to close $($Browser.Name)"

            # extract process name without extension for matching
            $processName = [System.IO.Path]::GetFileNameWithoutExtension($Browser.Path)

            # find and process all matching browser instances
            Microsoft.PowerShell.Management\Get-Process -Name $processName -ErrorAction SilentlyContinue |
                Microsoft.PowerShell.Core\ForEach-Object {

                    $currentProcess = $_

                    # handle background processes based on user preference
                    if ((-not $IncludeBackgroundProcesses) -and
                    ($currentProcess.MainWindowHandle -eq 0)) {

                        Microsoft.PowerShell.Utility\Write-Verbose "Skipping background process $($currentProcess.Id)"
                        return
                    }
                    elseif ($currentProcess.MainWindowHandle -ne 0) {

                        # attempt graceful window close for processes with UI
                        [GenXdev.Helpers.WindowObj]::GetMainWindow($currentProcess) |
                            Microsoft.PowerShell.Core\ForEach-Object {

                                $startTime = [DateTime]::UtcNow
                                $window = $_

                                # try graceful close
                                $null = $window.Close()

                                # wait up to 4 seconds for process to exit
                                while (!$currentProcess.HasExited -and
                            ([datetime]::UtcNow - $startTime -lt
                                    [System.TimeSpan]::FromSeconds(4))) {

                                    Microsoft.PowerShell.Utility\Start-Sleep -Milliseconds 20
                                }

                                if ($currentProcess.HasExited) {
                                    Microsoft.PowerShell.Utility\Set-Variable -Scope Global `
                                        -Name "_LastClose$($Browser.Name)" `
                                        -Value ([DateTime]::UtcNow.AddSeconds(-1))
                                    return
                                }
                            }
                        }

                        # force terminate if process still running
                        try {
                            $null = $currentProcess.Kill()
                            Microsoft.PowerShell.Utility\Set-Variable -Scope Global -Name "_LastClose$($Browser.Name)" `
                                -Value ([DateTime]::UtcNow)
                        }
                        catch {
                            Microsoft.PowerShell.Utility\Write-Warning "Failed to kill $($Browser.Name) process: $_"
                        }
                    }
        }

        # close all browsers if requested
        if ($All) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Closing all browsers'
            $installedBrowsers | Microsoft.PowerShell.Core\ForEach-Object { Close-BrowserInstance $_ }
            return
        }

        # handle default chromium browser closure
        if ($Chromium -and -not ($Chrome -or $Edge)) {
            if ($defaultBrowser.Name -like '*Chrome*' -or
                $defaultBrowser.Name -like '*Edge*') {

                Close-BrowserInstance $defaultBrowser
                return
            }

            # fallback to first available chromium browser
            $installedBrowsers |
                Microsoft.PowerShell.Core\Where-Object { $_.Name -like '*Edge*' -or $_.Name -like '*Chrome*' } |
                Microsoft.PowerShell.Utility\Select-Object -First 1 |
                Microsoft.PowerShell.Core\ForEach-Object {
                    Close-BrowserInstance $_
                }
            return
        }

        # handle specific browser closures
        if ($Chrome) {
            $installedBrowsers |
                Microsoft.PowerShell.Core\Where-Object { $_.Name -like '*Chrome*' } |
                Microsoft.PowerShell.Core\ForEach-Object { Close-BrowserInstance $_ }
        }

        if ($Edge) {
            $installedBrowsers |
                Microsoft.PowerShell.Core\Where-Object { $_.Name -like '*Edge*' } |
                Microsoft.PowerShell.Core\ForEach-Object { Close-BrowserInstance $_ }
        }

        if ($Firefox) {
            $installedBrowsers |
                Microsoft.PowerShell.Core\Where-Object { $_.Name -like '*Firefox*' } |
                Microsoft.PowerShell.Core\ForEach-Object { Close-BrowserInstance $_ }
        }

        # close default browser if no specific browser selected
        if (-not ($Chromium -or $Chrome -or $Edge -or $Firefox)) {
            Close-BrowserInstance $defaultBrowser
        }
    }

    end {
    }
}