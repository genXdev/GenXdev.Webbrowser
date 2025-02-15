################################################################################
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
#>
function Resume-WebbrowserTabVideo {

    [CmdletBinding()]
    [Alias("wbvideoplay")]
    param (
        ########################################################################
    )

    begin {

        # search for a youtube tab in the current browser session
        Write-Verbose "Attempting to locate an active YouTube tab..."
        $null = Select-WebbrowserTab -Name "*youtube*"
    }

    process {

        # verify that a youtube tab was successfully found and selected
        if ($null -eq $Global:chromeSession) {

            throw "No YouTube tab found in current browser session"
        }

        Write-Verbose "YouTube tab found - initiating video playback..."

        # execute the play() method on all video elements in the current page
        $null = Get-WebbrowserTabDomNodes "video" "e.play()"

        Write-Verbose "Video playback successfully resumed"
    }

    end {
    }
}
################################################################################
