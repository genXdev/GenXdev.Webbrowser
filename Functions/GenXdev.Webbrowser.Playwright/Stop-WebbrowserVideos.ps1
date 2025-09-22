<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser.Playwright
Original cmdlet filename  : Stop-WebbrowserVideos.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.280.2025
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
Pauses video playback in all active browser sessions.

.DESCRIPTION
Iterates through all active browser sessions and pauses any playing videos by
executing JavaScript commands. The function maintains the original session state
and handles errors gracefully.

.EXAMPLE
Stop-WebbrowserVideos

.EXAMPLE
wbsst
###############################################################################>
function Stop-WebbrowserVideos {

    [CmdletBinding(SupportsShouldProcess)]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [Alias('wbsst')]
    [Alias('ssst')]
    [Alias('wbvideostop')]
    param(
        [Alias('e')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in Microsoft Edge'
        )]
        [switch] $Edge,
        ###############################################################################
        [Alias('ch')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in Google Chrome'
        )]
        [switch] $Chrome
    )

    begin {
        Microsoft.PowerShell.Utility\Write-Verbose 'Starting video pause operation across browser sessions'

        # store the current session reference to restore it later
        $originalSession = $Global:chromeSession
        $originalController = $Global:chromeController

        # ensure we have an active browser session
        if (($null -eq $Global:chromeSessions) -or
            ($Global:chromeSessions.Count -eq 0)) {

            # select a browser tab if none are active
            $null = GenXdev.Webbrowser\Select-WebbrowserTab -Chrome:$chrome -Edge:$edge
        }
    }


    process {
        # iterate through each browser session and pause videos
        $Global:chromeSessions | Microsoft.PowerShell.Core\ForEach-Object {

            $currentSession = $_
            if ($null -eq $_) { return }
            if ($PSCmdlet.ShouldProcess('Browser session', 'Pause videos')) {

                try {
                    Microsoft.PowerShell.Utility\Write-Verbose "Attempting to pause videos in session: $currentSession"

                    # select the current tab for processing
                    $null = GenXdev.Webbrowser\Select-WebbrowserTab -ByReference $currentSession

                    # execute pause() command on all video elements
                    GenXdev.Webbrowser\Get-WebbrowserTabDomNodes 'video' 'e.pause()' -NoAutoSelectTab
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Warning "Failed to pause videos in session: $currentSession  `r`n$($_.Exception.Message)"
                }
            }
        }
    }

    end {
        Microsoft.PowerShell.Utility\Write-Verbose 'Restoring original browser session reference'
        $Global:chromeSession = $originalSession
        $Global:chromeController = $originalController
    }
}