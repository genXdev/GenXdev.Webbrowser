###############################################################################

<#
.SYNOPSIS
Maximizes the first video element found in the current browser tab.

.DESCRIPTION
This function executes JavaScript code to find the first video element on the
current webpage and maximize it by setting its style properties to cover the
full viewport. It also adds a high z-index to ensure the video stays on top
and hides page scrollbars.

.EXAMPLE
Set-BrowserVideoFullscreen

.EXAMPLE
fsvideo
#>
function Set-BrowserVideoFullscreen {

    [CmdletBinding()]
    [Alias("fsvideo")]

    param()

    Invoke-WebbrowserEvaluation "window.video = document.getElementsByTagName('video')[0]; video.setAttribute('style','position:fixed;left:0;top:0;bottom:0;right:0;z-index:10000;width:100vw;height:100vh'); document.body.appendChild(video);document.body.setAttribute('style', 'overflow:hidden');"
}
