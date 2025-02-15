################################################################################
<#
.SYNOPSIS
Queries and manipulates DOM nodes in the active browser tab using CSS selectors.

.DESCRIPTION
Uses browser automation to find elements matching a CSS selector and returns their
HTML content or executes custom JavaScript on each matched element. This function
is useful for web scraping and browser automation tasks.

.PARAMETER QuerySelector
CSS selector string to find matching DOM elements. Uses standard CSS selector
syntax like '#id', '.class', 'tag', etc.

.PARAMETER ModifyScript
JavaScript code to execute on each matched element. The code runs as an async
function with parameters:
- e: The matched DOM element
- i: Index of the element (0-based)
- n: Complete NodeList of matching elements
- modifyScript: The script being executed

.EXAMPLE
# Get HTML of all header divs
Get-WebbrowserTabDomNodes -QuerySelector "div.header"

.EXAMPLE
# Pause all videos on the page
wl "video" "e.pause()"
#>
function Get-WebbrowserTabDomNodes {

    [CmdletBinding()]
    [Alias("wl")]

    param(
        #######################################################################
        [parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "The query selector string to use for selecting DOM nodes"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $QuerySelector,
        #######################################################################
        [parameter(
            Mandatory = $false,
            Position = 1,
            ValueFromRemainingArguments = $false,
            HelpMessage = "The script to modify the output of the query selector"
        )]
        [string] $ModifyScript = ""
        #######################################################################
    )

    begin {

        # convert input parameters to json to prevent script injection attacks
        $jsonModifyScript = $ModifyScript |
        ConvertTo-Json -Compress -Depth 100 |
        ConvertTo-Json -Compress

        $jsonQuerySelector = $QuerySelector |
        ConvertTo-Json -Compress -Depth 100 |
        ConvertTo-Json -Compress

        # javascript that will be executed in the browser context
        # it handles both simple HTML extraction and custom modifications
        $browserScript = @"
let modifyScript = JSON.parse($jsonModifyScript);
let querySelector = JSON.parse($jsonQuerySelector);
let nodes = document.querySelectorAll(querySelector);

for (let i = 0; i < nodes.length; i++) {
    let node = nodes[i];
    if (!!modifyScript && modifyScript != "") {
        try {
            yield (
               await (
                   async function(e, i, n, modifyScript) {
                       return eval(modifyScript);
                   }
                 )(node, i, nodes, modifyScript)
            );
        }
        catch (e) {
            yield e+'';
        }
    }
    else {
       yield node.outerHTML;
    }
}
"@
    }

    process {

        # log the operation for debugging purposes
        Write-Verbose "Executing query '$QuerySelector' with modifier script:`n$ModifyScript"

        # execute the javascript in browser and return results
        Invoke-WebbrowserEvaluation -Scripts $browserScript
    }

    end {
    }
}
################################################################################
