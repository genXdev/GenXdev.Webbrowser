################################################################################
<#
.SYNOPSIS
Closes one or more webbrowser instances.

.DESCRIPTION
Closes one or more webbrowser instances in a selective manner, using commandline
switches to specify which browser(s) to close.

.PARAMETER Edge
Closes Microsoft Edge browser instances.

.PARAMETER Chrome
Closes Google Chrome browser instances.

.PARAMETER Chromium
Closes Microsoft Edge or Google Chrome, depending on the default browser.

.PARAMETER Firefox
Closes Firefox browser instances.

.PARAMETER All
Closes all registered modern browsers.

.PARAMETER IncludeBackgroundProcesses
Closes all instances of the webbrowser, including background tasks.

.EXAMPLE
Close-Webbrowser -Chrome -Firefox -IncludeBackgroundProcesses

.EXAMPLE
wbc -ch -ff -bg
#>
function Close-Webbrowser {

    [CmdletBinding(DefaultParameterSetName = 'Specific')]
    [Alias("wbc")]

    param(
        ########################################################################
        [Alias("e")]
        [parameter(
            Mandatory = $false,
            Position = 0,
            ParameterSetName = 'Specific',
            HelpMessage = "Closes Microsoft Edge browser instances"
        )]
        [switch] $Edge,
        ########################################################################
        [Alias("ch")]
        [parameter(
            Mandatory = $false,
            Position = 1,
            ParameterSetName = 'Specific',
            HelpMessage = "Closes Google Chrome browser instances"
        )]
        [switch] $Chrome,
        ########################################################################
        [Alias("c")]
        [parameter(
            Mandatory = $false,
            Position = 2,
            ParameterSetName = 'Specific',
            HelpMessage = "Closes default chromium-based browser"
        )]
        [switch] $Chromium,
        ########################################################################
        [Alias("ff")]
        [parameter(
            Mandatory = $false,
            Position = 3,
            ParameterSetName = 'Specific',
            HelpMessage = "Closes Firefox browser instances"
        )]
        [switch] $Firefox,
        ########################################################################
        [Alias("a")]
        [parameter(
            Mandatory = $false,
            Position = 0,
            ParameterSetName = 'All',
            HelpMessage = "Closes all registered modern browsers"
        )]
        [switch] $All,
        ########################################################################
        [Alias("bg", "Force")]
        [parameter(
            Mandatory = $false,
            Position = 4,
            HelpMessage = "Closes all instances including background tasks"
        )]
        [switch] $IncludeBackgroundProcesses
        ########################################################################
    )

    begin {

        # get installed browsers
        $installedBrowsers = Get-Webbrowser

        # get default browser
        $defaultBrowser = Get-DefaultWebbrowser

        Write-Verbose "Found $($installedBrowsers.Count) installed browsers"
        Write-Verbose "Default browser: $($defaultBrowser.Name)"
    }

    process {

        function Close-BrowserInstance {
            param (
                [object] $Browser
            )

            Write-Verbose "Attempting to close $($Browser.Name)"

            # get the browser executable name without extension
            $processName = [System.IO.Path]::GetFileNameWithoutExtension($Browser.Path)

            # find all processes for this browser
            Get-Process -Name $processName -ErrorAction SilentlyContinue |
                ForEach-Object {

                    $currentProcess = $_

                    # skip background processes unless specified
                    if ((-not $IncludeBackgroundProcesses) -and
                        ($currentProcess.MainWindowHandle -eq 0)) {
                        Write-Verbose "Skipping background process $($currentProcess.Id)"
                        return
                    }

                    # get main window handle
                    [GenXdev.Helpers.WindowObj]::GetMainWindow($currentProcess) |
                        ForEach-Object {

                            $startTime = [DateTime]::UtcNow
                            $window = $_

                            # try graceful close first
                            $null = $window.Close()

                            # wait for process to exit
                            while (!$currentProcess.HasExited -and
                                ([datetime]::UtcNow - $startTime -lt
                                    [TimeSpan]::FromSeconds(4))) {
                                Start-Sleep -Milliseconds 20
                            }

                            if ($currentProcess.HasExited) {
                                Set-Variable -Scope Global `
                                    -Name "_LastClose$($Browser.Name)" `
                                    -Value ([DateTime]::UtcNow.AddSeconds(-1))
                                return
                            }
                        }

                    # force kill if still running
                    try {
                        $currentProcess.Kill()
                        Set-Variable -Scope Global -Name "_LastClose$($Browser.Name)" `
                            -Value ([DateTime]::UtcNow)
                    }
                    catch {
                        Write-Warning "Failed to kill $($Browser.Name) process: $_"
                    }
                }
        }

        # handle All parameter
        if ($All) {
            Write-Verbose "Closing all browsers"
            $installedBrowsers | ForEach-Object { Close-BrowserInstance $_ }
            return
        }

        # handle Chromium parameter
        if ($Chromium) {
            if ($defaultBrowser.Name -like "*Chrome*" -or
                $defaultBrowser.Name -like "*Edge*") {
                Close-BrowserInstance $defaultBrowser
                return
            }

            # try Edge then Chrome if default is not chromium
            $installedBrowsers |
                Where-Object { $_.Name -like "*Edge*" -or $_.Name -like "*Chrome*" } |
                Select-Object -First 1 |
                ForEach-Object {
                    Close-BrowserInstance $_
                }
            return
        }

        # handle individual browser parameters
        if ($Chrome) {
            $installedBrowsers |
                Where-Object { $_.Name -like "*Chrome*" } |
                ForEach-Object { Close-BrowserInstance $_ }
        }

        if ($Edge) {
            $installedBrowsers |
                Where-Object { $_.Name -like "*Edge*" } |
                ForEach-Object { Close-BrowserInstance $_ }
        }

        if ($Firefox) {
            $installedBrowsers |
                Where-Object { $_.Name -like "*Firefox*" } |
                ForEach-Object { Close-BrowserInstance $_ }
        }

        # if no browser specified, close default
        if (-not ($Chromium -or $Chrome -or $Edge -or $Firefox)) {
            Close-BrowserInstance $defaultBrowser
        }
    }

    end {
    }
}
################################################################################
