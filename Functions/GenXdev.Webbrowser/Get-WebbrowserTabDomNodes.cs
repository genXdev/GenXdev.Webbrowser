// ################################################################################
// Part of PowerShell module : GenXdev.Webbrowser
// Original cmdlet filename  : Get-WebbrowserTabDomNodes.cs
// Original author           : René Vaessen / GenXdev
// Version                   : 2.1.2025
// ################################################################################
// Copyright (c)  René Vaessen / GenXdev
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ################################################################################



using System.Collections;
using System.Management.Automation;

namespace GenXdev.Webbrowser
{
    /// <summary>
    /// <para type="synopsis">
    /// Queries and manipulates DOM nodes in the active browser tab using CSS selectors.
    /// </para>
    ///
    /// <para type="description">
    /// Uses browser automation to find elements matching a CSS selector and returns their
    /// HTML content or executes custom JavaScript on each matched element. This function
    /// is useful for web scraping and browser automation tasks.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -QuerySelector &lt;System.String[]&gt;<br/>
    /// CSS selector string to find matching DOM elements. Uses standard CSS selector
    /// syntax like '#id', '.class', 'tag', etc.<br/>
    /// - <b>Position</b>: 0<br/>
    /// - <b>Mandatory</b>: true<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -ModifyScript &lt;System.String&gt;<br/>
    /// JavaScript code to execute on each matched element. The code runs as an async
    /// function with parameters:
    /// - e: The matched DOM element
    /// - i: Index of the element (0-based)
    /// - n: Complete NodeList of matching elements
    /// - modifyScript: The script being executed<br/>
    /// - <b>Position</b>: 1<br/>
    /// - <b>Default</b>: ""<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Edge &lt;System.Management.Automation.SwitchParameter&gt;<br/>
    /// Use Microsoft Edge browser<br/>
    /// - <b>Aliases</b>: e<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Chrome &lt;System.Management.Automation.SwitchParameter&gt;<br/>
    /// Use Google Chrome browser<br/>
    /// - <b>Aliases</b>: ch<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Page &lt;System.Object&gt;<br/>
    /// Browser page object reference<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -ByReference &lt;System.Management.Automation.PSCustomObject&gt;<br/>
    /// Browser session reference object<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -NoAutoSelectTab &lt;System.Management.Automation.SwitchParameter&gt;<br/>
    /// Prevent automatic tab selection<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Get HTML of all header divs</para>
    /// <para>Get-WebbrowserTabDomNodes -QuerySelector "div.header"</para>
    /// <code>
    /// Get-WebbrowserTabDomNodes -QuerySelector "div.header"
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Pause all videos on the page</para>
    /// <para>wl "video" "e.pause()"</para>
    /// <code>
    /// wl "video" "e.pause()"
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "WebbrowserTabDomNodes")]
    [Alias("wl")]
    [OutputType(typeof(PSObject))]
    public class GetWebbrowserTabDomNodesCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// CSS selector string to find matching DOM elements
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "The query selector string or array of strings to use for selecting DOM nodes")]
        [ValidateNotNullOrEmpty]
        public string[] QuerySelector { get; set; }

        /// <summary>
        /// JavaScript code to execute on each matched element
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 1,
            ValueFromRemainingArguments = false,
            HelpMessage = "The script to modify the output of the query selector, e.g. e.outerHTML or e.outerHTML='hello world'")]
        public string ModifyScript { get; set; } = "";

        /// <summary>
        /// Use Microsoft Edge browser
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Use Microsoft Edge browser")]
        [Alias("e")]
        public SwitchParameter Edge { get; set; }

        /// <summary>
        /// Use Google Chrome browser
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Use Google Chrome browser")]
        [Alias("ch")]
        public SwitchParameter Chrome { get; set; }

        /// <summary>
        /// Browser page object reference
        /// </summary>
        [Parameter(
            HelpMessage = "Browser page object reference",
            ValueFromPipeline = false)]
        public object Page { get; set; }

        /// <summary>
        /// Browser session reference object
        /// </summary>
        [Parameter(
            HelpMessage = "Browser session reference object",
            ValueFromPipeline = false)]
        public PSObject ByReference { get; set; }

        /// <summary>
        /// Prevent automatic tab selection
        /// </summary>
        [Parameter(
            Mandatory = false,
            ValueFromPipeline = false,
            HelpMessage = "Prevent automatic tab selection")]
        public SwitchParameter NoAutoSelectTab { get; set; }

        private string browserScript;

        /// <summary>
        /// Initialize the cmdlet and prepare the browser script
        /// </summary>
        protected override void BeginProcessing()
        {
            // Convert input parameters to json to prevent script injection attacks
            var convertToJsonScript = ScriptBlock.Create("param($InputObject) $InputObject | Microsoft.PowerShell.Utility\\ConvertTo-Json -Compress -Depth 100 | Microsoft.PowerShell.Utility\\ConvertTo-Json -Compress");

            var jsonModifyScriptResult = convertToJsonScript.Invoke(ModifyScript);
            var jsonModifyScript = jsonModifyScriptResult.Count > 0 ? jsonModifyScriptResult[0].ToString() : "\"\"";

            var jsonQuerySelectorResult = convertToJsonScript.Invoke(QuerySelector);
            var jsonQuerySelector = jsonQuerySelectorResult.Count > 0 ? jsonQuerySelectorResult[0].ToString() : "\"\"";

            // JavaScript that will be executed in the browser context
            browserScript = $@"
debugger;
let modifyScript = JSON.parse({jsonModifyScript});
let selectors = JSON.parse({jsonQuerySelector});
selectors = selectors instanceof Array ? selectors : [selectors];
let currentSelector = selectors[0];
async function* traverseNodes(node, selectorIndex) {{
    if (selectorIndex >= selectors.length) return;

    let currentSelector = selectors[selectorIndex];
    let nodes = node.querySelectorAll(currentSelector);

    for (let i = 0; i < nodes.length; i++) {{
        let currentNode = nodes[i];

        // Check for Shadow DOM
        if (currentNode.shadowRoot) {{
            yield* traverseNodes(currentNode.shadowRoot, selectorIndex + 1);
            continue;
        }}

        // Check for IFrames
        if (currentNode.tagName === 'IFRAME') {{
            try {{
                let iframeDoc = currentNode.contentDocument || currentNode.contentWindow.document;
                yield* traverseNodes(iframeDoc, selectorIndex + 1);
            }} catch(e) {{
                // Handle cross-origin iframe access errors
                console.warn('Cannot access iframe content');
            }}
            continue;
        }}

        // If this is the last selector, process the node
        if (selectorIndex === selectors.length - 1) {{
            if (!!modifyScript && modifyScript != """") {{
                try {{
                    yield await (async function(e, i, n, modifyScript) {{
                        return eval(modifyScript);
                    }})(currentNode, i, nodes, modifyScript);
                }} catch (e) {{
                    yield e+'';
                }}
            }} else {{
                yield currentNode.outerHTML;
            }}
        }} else {{
            // Continue traversing with next selector
            yield* traverseNodes(currentNode, selectorIndex + 1);
        }}
    }}
}}

// Start traversal from document root
for await (let result of traverseNodes(document, 0)) {{
    yield result;
}}
";
        }

        /// <summary>
        /// Execute the browser evaluation with the prepared script
        /// </summary>
        protected override void ProcessRecord()
        {
            // Log the operation for debugging purposes
            WriteVerbose($"Executing query '{string.Join(", ", QuerySelector)}' with modifier script:\n{ModifyScript}");

            // Execute the javascript in browser and return results
            var invocationParams = CopyIdenticalParamValues("GenXdev.Webbrowser\\Invoke-WebbrowserEvaluation");

            // Add the Scripts parameter
            invocationParams["Scripts"] = browserScript;

            // Invoke the webbrowser evaluation
            var invokeScript = ScriptBlock.Create("param($params) GenXdev.Webbrowser\\Invoke-WebbrowserEvaluation @params");
            var results = invokeScript.Invoke(invocationParams);

            // Write the results to the pipeline
            foreach (var result in results)
            {
                WriteObject(result);
            }
        }

        /// <summary>
        /// Clean up resources if needed
        /// </summary>
        protected override void EndProcessing()
        {
            // No cleanup needed
        }
    }
}