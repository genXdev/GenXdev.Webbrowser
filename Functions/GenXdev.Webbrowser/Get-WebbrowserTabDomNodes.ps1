###############################################################################
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
        ###############################################################################Get HTML of all header divs
Get-WebbrowserTabDomNodes -QuerySelector "div.header"

.EXAMPLE
        ###############################################################################Pause all videos on the page
wl "video" "e.pause()"
        ###############################################################################>
function Get-WebbrowserTabDomNodes {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [Alias("wl")]
    param(
        #######################################################################
        [parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "The query selector string or array of strings to use for selecting DOM nodes"
        )]
        [ValidateNotNullOrEmpty()]
        [string[]] $QuerySelector,
        #######################################################################
        [parameter(
            Mandatory = $false,
            Position = 1,
            ValueFromRemainingArguments = $false,
            HelpMessage = "The script to modify the output of the query selector"
        )]
        [string] $ModifyScript = "",
        #######################################################################
        [Alias("e")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Use Microsoft Edge browser"
        )]
        [switch] $Edge,
        ###############################################################################
        [Alias("ch")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Use Google Chrome browser"
        )]
        [switch] $Chrome,
        ###############################################################################
        [Parameter(
            HelpMessage = "Browser page object reference",
            ValueFromPipeline = $false
        )]
        [object] $Page,
        ###############################################################################
        [Parameter(
            HelpMessage = "Browser session reference object",
            ValueFromPipeline = $false
        )]
        [PSCustomObject] $ByReference,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $false,
            HelpMessage = "Prevent automatic tab selection"
        )]
        [switch] $NoAutoSelectTab
        ###############################################################################
    )

    begin {
        # convert input parameters to json to prevent script injection attacks
        $jsonModifyScript = $ModifyScript |
        Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 100 |
        Microsoft.PowerShell.Utility\ConvertTo-Json -Compress

        $jsonQuerySelector = @($QuerySelector) |
        Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 100 |
        Microsoft.PowerShell.Utility\ConvertTo-Json -Compress

        # javascript that will be executed in the browser context
        # it handles both simple HTML extraction and custom modifications
        $browserScript = @"
        debugger;
let modifyScript = JSON.parse($jsonModifyScript);
let selectors = JSON.parse($jsonQuerySelector);
selectors = selectors instanceof Array ? selectors : [selectors];
let currentSelector = selectors[0];
async function* traverseNodes(node, selectorIndex) {
    if (selectorIndex >= selectors.length) return;

    let currentSelector = selectors[selectorIndex];
    let nodes = node.querySelectorAll(currentSelector);

    for (let i = 0; i < nodes.length; i++) {
        let currentNode = nodes[i];

        // Check for Shadow DOM
        if (currentNode.shadowRoot) {
            yield* traverseNodes(currentNode.shadowRoot, selectorIndex + 1);
            continue;
        }

        // Check for IFrames
        if (currentNode.tagName === 'IFRAME') {
            try {
                let iframeDoc = currentNode.contentDocument || currentNode.contentWindow.document;
                yield* traverseNodes(iframeDoc, selectorIndex + 1);
            } catch(e) {
                // Handle cross-origin iframe access errors
                console.warn('Cannot access iframe content');
            }
            continue;
        }

        // If this is the last selector, process the node
        if (selectorIndex === selectors.length - 1) {
            if (!!modifyScript && modifyScript != "") {
                try {
                    yield await (async function(e, i, n, modifyScript) {
                        return eval(modifyScript);
                    })(currentNode, i, nodes, modifyScript);
                } catch (e) {
                    yield e+'';
                }
            } else {
                yield currentNode.outerHTML;
            }
        } else {
            // Continue traversing with next selector
            yield* traverseNodes(currentNode, selectorIndex + 1);
        }
    }
}

// Start traversal from document root
for await (let result of traverseNodes(document, 0)) {
    yield result;
}
"@
    }


process {

        # log the operation for debugging purposes
        Microsoft.PowerShell.Utility\Write-Verbose "Executing query '$QuerySelector' with modifier script:`n$ModifyScript"

        # execute the javascript in browser and return results
        $invocationParams = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.Webbrowser\Invoke-WebbrowserEvaluation"

        $invocationParams.Scripts = $browserScript
        GenXdev.Webbrowser\Invoke-WebbrowserEvaluation @invocationParams
    }

    end {
    }
}
        ###############################################################################