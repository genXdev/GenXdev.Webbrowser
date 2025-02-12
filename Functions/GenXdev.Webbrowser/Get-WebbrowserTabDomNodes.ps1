################################################################################

<#
.SYNOPSIS
Returns the outer HTML of DOM nodes matching a CSS query selector.

.DESCRIPTION
Uses browser automation to find elements matching a CSS selector and return
their HTML content. Optionally executes JavaScript on each matched element.

.PARAMETER QuerySelector
CSS selector string to find matching DOM elements.

.PARAMETER ModifyScript
Optional JavaScript code to execute on each matched element. The script runs in
the context of a lambda function with parameters (e, i) where:
- e: The matched DOM element
- i: Index of the element in the result set
- n: The full NodeList of matching elements
- modifyScript: The script being executed

.EXAMPLE
Get-WebbrowserTabDomNodes -QuerySelector "div.header"

.EXAMPLE
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

        # convert the modify script and query selector to json to prevent injection
        $jsonModifyScript = $ModifyScript | ConvertTo-Json -Compress -Depth 100 |
            ConvertTo-Json -Compress
        $jsonQuerySelector = $QuerySelector | ConvertTo-Json -Compress -Depth 100 |
            ConvertTo-Json -Compress

        # prepare the javascript code to execute in the browser
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

        # log the script being executed for debugging
        Write-Verbose "Executing browser script: $browserScript"

        # invoke the javascript in the browser and return results
        Invoke-WebbrowserEvaluation -Scripts $browserScript
    }

    end {
    }
}
################################################################################
