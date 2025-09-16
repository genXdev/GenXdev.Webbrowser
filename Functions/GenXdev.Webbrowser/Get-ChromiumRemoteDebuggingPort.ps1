<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser
Original cmdlet filename  : Get-ChromiumRemoteDebuggingPort.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.264.2025
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
Returns the remote debugging port for the system's default Chromium browser.

.DESCRIPTION
Detects whether Microsoft Edge or Google Chrome is the default browser and
returns the appropriate debugging port number. If Chrome is the default browser,
returns the Chrome debugging port. Otherwise returns the Edge debugging port
(also used when no default browser is detected).

.OUTPUTS
[int] The remote debugging port number for the detected browser.

.EXAMPLE
Get debugging port using full command name
Get-ChromiumRemoteDebuggingPort

.EXAMPLE
Get debugging port using alias
Get-BrowserDebugPort
#>
function Get-ChromiumRemoteDebuggingPort {

    [CmdletBinding()]
    [OutputType([int])]
    param(

        [switch] $Chrome,
        [switch] $Edge
    )
    ############################################################################

    begin {
        # verbose output to indicate start of browser detection
        Microsoft.PowerShell.Utility\Write-Verbose 'Starting detection of default Chromium browser type'

        # get the system's default browser information
        $defaultBrowser = GenXdev.Webbrowser\Get-DefaultWebbrowser

        # log the detected default browser name
        Microsoft.PowerShell.Utility\Write-Verbose ('Default browser detected: {0}' -f `
            $(if ($null -eq $defaultBrowser) { 'None' }
                else { $defaultBrowser.Name }))
    }


    process {

        if ($Chrome) {
            # return chrome debugging port
            Microsoft.PowerShell.Utility\Write-Verbose 'Using Chrome debugging port'
            GenXdev.Webbrowser\Get-ChromeRemoteDebuggingPort
            return;
        }

        if ($Edge) {
            # return edge debugging port
            Microsoft.PowerShell.Utility\Write-Verbose 'Using Edge debugging port'
            GenXdev.Webbrowser\Get-EdgeRemoteDebuggingPort
            return;
        }

        # determine and return appropriate debugging port based on browser
        if (($null -ne $defaultBrowser) -and
            ($defaultBrowser.Name -like '*Chrome*')) {

            # chrome is default - return chrome debugging port
            Microsoft.PowerShell.Utility\Write-Verbose 'Using Chrome debugging port'
            GenXdev.Webbrowser\Get-ChromeRemoteDebuggingPort
        }
        else {

            # edge is default or no browser - return edge debugging port
            Microsoft.PowerShell.Utility\Write-Verbose 'Using Edge debugging port'
            GenXdev.Webbrowser\Get-EdgeRemoteDebuggingPort
        }
    }

    end {
    }
}