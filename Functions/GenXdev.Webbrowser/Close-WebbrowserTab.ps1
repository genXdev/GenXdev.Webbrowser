################################################################################

<#
.SYNOPSIS
Closes the currently selected webbrowser tab.

.DESCRIPTION
Closes the currently selected webbrowser tab by executing a window.close()
command in the browser context. If no tab is currently selected, it will attempt
to select the last used one.

.EXAMPLE
Close-WebbrowserTab

.EXAMPLE
ct
#>
function Close-WebbrowserTab {

    [CmdletBinding()]
    [Alias("ct", "CloseTab")]
    param()

    begin {

        # attempt to get reference to existing chrome session
        try {
            Write-Verbose "Attempting to locate active browser session"
            $null = Get-ChromiumSessionReference
        }
        catch {
            Write-Verbose "No active session found, selecting last used tab"
            $null = Select-WebbrowserTab
        }
    }

    process {

        # get current tab info for logging
        Write-Verbose ("Closing browser tab: '$($Global:chromeSession.title)' " +
            "at URL: $($Global:chromeSession.url)")

        # execute javascript close command in browser context
        $null = $Global:chromeController.CloseAsync().Wait();
    }

    end {
    }
}
################################################################################
