################################################################################
<#
.SYNOPSIS
Pauses video playback in all active Chromium sessions.

.DESCRIPTION
This function iterates through all active Chrome sessions and pauses any playing
videos by executing a JavaScript command.

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
    param(
    )

    begin {
        # Write-Verbose "Starting video pause operation across Chrome sessions"
        $origReference = $Global:chromeSession

        if (($null -eq $Global:chromeSessions) -or ($Global:chromeSessions.Count -eq 0)) {

            $null = Select-WebbrowserTab
        }
    }

    process {
        # iterate through each chrome session and pause videos
        $chromeSessions | ForEach-Object {

            try {
                # Write-Verbose "Pausing videos in session: $_"

                # select tab and execute pause command
                Select-WebbrowserTab -ByReference $_

                # pause any playing videos on the page
                Get-WebbrowserTabDomNodes "video" "e.pause()"
            }
            catch {
                # Write-Warning "Failed to pause videos in session: $_"
            }
        }
    }

    end {
        # Write-Verbose "Completed pausing videos in all Chrome sessions"
        $Global:chromeSession = $origReference;
    }
}
################################################################################