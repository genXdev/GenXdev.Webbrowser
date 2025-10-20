// ################################################################################
// Part of PowerShell module : GenXdev.Webbrowser
// Original cmdlet filename  : Export-BrowserBookmarks.cs
// Original author           : René Vaessen / GenXdev
// Version                   : 1.302.2025
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



using System;
using System.Collections;
using System.Management.Automation;

namespace GenXdev.Webbrowser
{

    /// <summary>
    /// <para type="synopsis">
    /// Exports browser bookmarks to a JSON file.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -OutputFile &lt;string&gt;<br/>
    /// Path to the JSON file where bookmarks will be saved.<br/>
    /// - <b>Position</b>: 0<br/>
    /// - <b>Default</b>: (none)<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Chrome &lt;SwitchParameter&gt;<br/>
    /// Export bookmarks from Google Chrome.<br/>
    /// - <b>Position</b>: (named)<br/>
    /// - <b>Default</b>: False<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Edge &lt;SwitchParameter&gt;<br/>
    /// Export bookmarks from Microsoft Edge.<br/>
    /// - <b>Position</b>: (named)<br/>
    /// - <b>Default</b>: False<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Firefox &lt;SwitchParameter&gt;<br/>
    /// Export bookmarks from Mozilla Firefox.<br/>
    /// - <b>Position</b>: (named, set "Firefox")<br/>
    /// - <b>Default</b>: False<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Export Edge bookmarks to a JSON file.</para>
    /// <para>Writes the Edge bookmarks as formatted JSON to the provided path.</para>
    /// <code>
    /// Export-BrowserBookmarks -OutputFile "C:\\MyBookmarks.json" -Edge
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Export Chrome bookmarks via positional OutputFile.</para>
    /// <para>Demonstrates positional binding of the OutputFile parameter.</para>
    /// <code>
    /// Export-BrowserBookmarks "C:\\MyBookmarks.json" -Chrome
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsData.Export, "BrowserBookmarks")]
    [OutputType(typeof(void))]
    public class ExportBrowserBookmarksCommand : PSGenXdevCmdlet
    {

        // Holds the expanded output file path resolved in BeginProcessing.
        private string resolvedOutputFilePath = string.Empty;

        /// <summary>
        /// Gets or sets the path to the JSON output file.
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Path to the JSON file where bookmarks will be saved"
        )]
        [ValidateNotNullOrEmpty]
        public string OutputFile { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets a value indicating whether Chrome bookmarks are exported.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Export bookmarks from Google Chrome"
        )]
        public SwitchParameter Chrome { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether Edge bookmarks are exported.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Export bookmarks from Microsoft Edge"
        )]
        public SwitchParameter Edge { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether Firefox bookmarks are exported.
        /// </summary>
        [Parameter(
            Mandatory = false,
            ParameterSetName = "Firefox",
            HelpMessage = "Export bookmarks from Mozilla Firefox"
        )]
        public SwitchParameter Firefox { get; set; }

        /// <summary>
        /// Performs initialization work identical to the PowerShell begin block.
        /// </summary>
        protected override void BeginProcessing()
        {

            // Resolve the supplied output path using the base class method.
            resolvedOutputFilePath = ExpandPath(OutputFile);

            // Emit the same verbose message as the original PowerShell implementation.
            WriteVerbose("Exporting bookmarks to: " + resolvedOutputFilePath);
        }

        /// <summary>
        /// Executes the main export pipeline equivalent to the PowerShell process block.
        /// </summary>
        protected override void ProcessRecord()
        {

            // Allocate a hashtable to hold the Get-BrowserBookmark parameter flags.
            var bookmarkArguments = new Hashtable(StringComparer.OrdinalIgnoreCase);

            // Mirror the PowerShell logic for the Chrome switch flag.
            if (Chrome.ToBool())
            {

                // Add the Chrome flag expected by Get-BrowserBookmark.
                bookmarkArguments["Chrome"] = true;

                // Emit the original verbose message for the Chrome path.
                WriteVerbose("Exporting Chrome bookmarks");
            }

            // Mirror the PowerShell logic for the Edge switch flag.
            if (Edge.ToBool())
            {

                // Add the Edge flag expected by Get-BrowserBookmark.
                bookmarkArguments["Edge"] = true;

                // Emit the original verbose message for the Edge path.
                WriteVerbose("Exporting Edge bookmarks");
            }

            // Mirror the PowerShell logic for the Firefox switch flag.
            if (Firefox.ToBool())
            {

                // Add the Firefox flag expected by Get-BrowserBookmark.
                bookmarkArguments["Firefox"] = true;

                // Emit the original verbose message for the Firefox path.
                WriteVerbose("Exporting Firefox bookmarks");
            }

            // Invoke Get-BrowserBookmark cmdlet to retrieve bookmark data.
            var getBookmarksScript = ScriptBlock.Create(
                "param($arguments) GenXdev.Webbrowser\\Get-BrowserBookmark @arguments"
            );

            var bookmarkResults = InvokeCommand.InvokeScript(
                useLocalScope: false,
                scriptBlock: getBookmarksScript,
                input: null,
                args: new object[] { bookmarkArguments }
            );

            // Convert bookmark data to JSON using base class method.
            string jsonContent = ConvertToJson(bookmarkResults, 100);

            // Write JSON content to the output file.
            System.IO.File.WriteAllText(resolvedOutputFilePath, jsonContent);
        }

        /// <summary>
        /// Completes execution matching the PowerShell end block semantics.
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}