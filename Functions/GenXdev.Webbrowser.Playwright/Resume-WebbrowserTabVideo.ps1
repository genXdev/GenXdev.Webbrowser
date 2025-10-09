<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser.Playwright
Original cmdlet filename  : Resume-WebbrowserTabVideo.ps1
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
Resumes video playback in a YouTube browser tab.

.DESCRIPTION
Finds the active YouTube browser tab and resumes video playback by executing the
play() method on any video elements found in the page. If no YouTube tab is
found, the function throws an error. This function is particularly useful for
automating video playback control in browser sessions.

.EXAMPLE
Resume-WebbrowserTabVideo

.EXAMPLE
wbvideoplay

.NOTES
Requires an active Chrome browser session with at least one YouTube tab open.
The function will throw an error if no YouTube tab is found.
###############################################################################>
function Resume-WebbrowserTabVideo {

    [CmdletBinding()]
    [Alias('wbvideoplay')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    param (
        ########################################################################
    )

    begin {

        # search for a youtube tab in the current browser session
        Microsoft.PowerShell.Utility\Write-Verbose 'Attempting to locate an active YouTube tab...'
        $null = GenXdev.Webbrowser\Select-WebbrowserTab -Name '*youtube*'
    }


    process {

        # verify that a youtube tab was successfully found and selected
        if ($null -eq $Global:chromeSession) {

            throw 'No YouTube tab found in current browser session'
        }

        Microsoft.PowerShell.Utility\Write-Verbose 'YouTube tab found - initiating video playback...'

        # execute the play() method on all video elements in the current page
        $null = GenXdev.Webbrowser\Get-WebbrowserTabDomNodes 'video' 'e.play()'

        Microsoft.PowerShell.Utility\Write-Verbose 'Video playback successfully resumed'
    }

    end {
    }
}