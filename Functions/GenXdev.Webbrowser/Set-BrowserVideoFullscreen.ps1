################################################################################
<#
.SYNOPSIS
Maximizes the first video element found in the current browser tab.

.DESCRIPTION
Executes JavaScript code to locate and maximize the first video element on the
current webpage. The video is set to cover the entire viewport with maximum
z-index to ensure visibility. Page scrollbars are hidden for a clean fullscreen
experience.

.EXAMPLE
Set-BrowserVideoFullscreen
#>
function Set-BrowserVideoFullscreen {

    [CmdletBinding()]
    [Alias("fsvideo")]

    param()

    begin {

        # prepare the javascript that will handle the video manipulation
        Write-Verbose "Preparing JavaScript code for video fullscreen"
    }

    process {

        # find the first video element on the page
        # set its style to fixed position covering the viewport
        # move it to the top of the document body
        # hide page scrollbars
        Write-Verbose "Executing JavaScript to maximize video element"
        Invoke-WebbrowserEvaluation "window.video = document.getElementsByTagName('video')[0]; `
            video.setAttribute('style','position:fixed;left:0;top:0;bottom:0;right:0;`
            z-index:10000;width:100vw;height:100vh'); `
            document.body.appendChild(video);`
            document.body.setAttribute('style', 'overflow:hidden');"
    }

    end {
    }
}
################################################################################
