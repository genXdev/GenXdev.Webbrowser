<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser.Playwright
Original cmdlet filename  : Stop-WebbrowserVideos.ps1
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