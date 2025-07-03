###############################################################################
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
        ###############################################################################>
function Set-BrowserVideoFullscreen {

    [CmdletBinding(SupportsShouldProcess)]
    [Alias("fsvideo")]
    param()

    begin {

        # prepare the javascript command that will handle video manipulation
        $script = @(
            "window.video = document.getElementsByTagName('video')[0];" +
            "video.setAttribute('style','position:fixed;left:0;top:0;bottom:0;" +
            "right:0;z-index:10000;width:100vw;height:100vh');" +
            "document.body.appendChild(video);" +
            "document.body.setAttribute('style', 'overflow:hidden');"
        ) -join ''

        Microsoft.PowerShell.Utility\Write-Verbose "Prepared JavaScript code for video fullscreen manipulation"
    }


process {

        # check if we should proceed with the operation
        if ($PSCmdlet.ShouldProcess("browser video", "Set to fullscreen mode")) {

            Microsoft.PowerShell.Utility\Write-Verbose "Executing JavaScript to maximize video element"
            GenXdev.Webbrowser\Invoke-WebbrowserEvaluation $script
        }
    }

    end {
    }
}
        ###############################################################################