################################################################################
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
#>
function Stop-WebbrowserVideos {

    [CmdletBinding()]
    [Alias("wbsst")]
    [Alias("ssst")]
    [Alias("wbvideostop")]
    param()

    begin {

        Write-Verbose "Starting video pause operation across browser sessions"

        # store the current chrome session reference to restore it later
        $origReference = $Global:chromeSession

        # ensure we have an active browser session
        if (($null -eq $Global:chromeSessions) -or
            ($Global:chromeSessions.Count -eq 0)) {

            # select a browser tab if none are active
            $null = Select-WebbrowserTab
        }
    }

    process {

        # iterate through each browser session and pause videos
        $chromeSessions | ForEach-Object {

            try {
                Write-Verbose "Attempting to pause videos in session: $_"

                # select the current tab for processing
                Select-WebbrowserTab -ByReference $_

                # execute pause() command on all video elements
                Get-WebbrowserTabDomNodes "video" "e.pause()"
            }
            catch {
                Write-Warning "Failed to pause videos in session: $_"
            }
        }
    }

    end {

        Write-Verbose "Restoring original browser session reference"
        $Global:chromeSession = $origReference
    }
}
################################################################################