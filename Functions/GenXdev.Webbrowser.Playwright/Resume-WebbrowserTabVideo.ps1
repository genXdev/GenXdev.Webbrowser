################################################################################
<#
.SYNOPSIS
Resumes video playback in a YouTube browser tab.

.DESCRIPTION
Finds the current YouTube browser tab and resumes video playback by executing the
play() method on any video elements found in the page.

.EXAMPLE
Resume-WebbrowserTabVideo

.NOTES
Requires an active Chrome browser session with at least one YouTube tab open.
#>
function Resume-WebbrowserTabVideo {

    [CmdletBinding()]
    [Alias("wbvideoplay")]
    param (
        ########################################################################
    )

    begin {

        # attempt to find a youtube tab
        Write-Verbose "Searching for YouTube tab..."
        $null = Select-WebbrowserTab -Name "*youtube*"
    }

    process {

        # verify that a youtube tab was found
        if ($null -eq $Global:chromeSession) {

            throw "No YouTube tab found in current browser session"
        }

        Write-Verbose "Found YouTube tab, attempting to resume video playback..."

        # execute play() method on all video elements in the page
        $null = Get-WebbrowserTabDomNodes "video" "e.play()"

        Write-Verbose "Video playback resumed"
    }

    end {
    }
}
################################################################################
