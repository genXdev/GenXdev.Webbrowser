// ################################################################################
// Part of PowerShell module : GenXdev.Webbrowser
// Original cmdlet filename  : Find-BrowserBookmark.cs
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



using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Text.RegularExpressions;

namespace GenXdev.Webbrowser
{
    /// <summary>
    /// <para type="synopsis">
    /// Finds bookmarks from one or more web browsers.
    /// </para>
    ///
    /// <para type="description">
    /// Searches through bookmarks from Microsoft Edge, Google Chrome, or Mozilla Firefox.
    /// Returns bookmarks that match one or more search queries in their name, URL, or
    /// folder path. If no queries are provided, returns all bookmarks from the selected
    /// browsers.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -Queries &lt;System.String[]&gt;<br/>
    /// One or more search terms to find matching bookmarks. Matches are found in the
    /// bookmark name, URL, or folder path using wildcard pattern matching.<br/>
    /// - <b>Aliases</b>: q, Name, Text, Query<br/>
    /// - <b>Position</b>: 0<br/>
    /// - <b>Default</b>: (null)<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Edge &lt;System.Management.Automation.SwitchParameter&gt;<br/>
    /// Switch to include Microsoft Edge bookmarks in the search.<br/>
    /// - <b>Aliases</b>: e<br/>
    /// - <b>Position</b>: Named<br/>
    /// - <b>Default</b>: False<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Chrome &lt;System.Management.Automation.SwitchParameter&gt;<br/>
    /// Switch to include Google Chrome bookmarks in the search.<br/>
    /// - <b>Aliases</b>: ch<br/>
    /// - <b>Position</b>: Named<br/>
    /// - <b>Default</b>: False<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Firefox &lt;System.Management.Automation.SwitchParameter&gt;<br/>
    /// Switch to include Mozilla Firefox bookmarks in the search.<br/>
    /// - <b>Aliases</b>: ff<br/>
    /// - <b>Position</b>: Named<br/>
    /// - <b>Default</b>: False<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Count &lt;System.Int32&gt;<br/>
    /// Maximum number of results to return. Must be a positive integer.
    /// Default is 99999999.<br/>
    /// - <b>Position</b>: Named<br/>
    /// - <b>Default</b>: 99999999<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -PassThru &lt;System.Management.Automation.SwitchParameter&gt;<br/>
    /// Switch to return complete bookmark objects instead of just URLs. Each bookmark
    /// object contains Name, URL, and Folder properties.<br/>
    /// - <b>Position</b>: Named<br/>
    /// - <b>Default</b>: False<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Find-BrowserBookmark -Query "github" -Edge -Chrome -Count 10</para>
    /// <para>Searches Edge and Chrome bookmarks for "github", returns first 10 URLs</para>
    /// <code>
    /// Find-BrowserBookmark -Query "github" -Edge -Chrome -Count 10
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>bookmarks powershell -e -ff -PassThru</para>
    /// <para>Searches Edge and Firefox bookmarks for "powershell", returns full objects</para>
    /// <code>
    /// bookmarks powershell -e -ff -PassThru
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Find, "BrowserBookmark")]
    [Alias("bookmarks")]
    [OutputType(typeof(PSObject))]
    [OutputType(typeof(string))]
    public class FindBrowserBookmarkCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// One or more search terms to find matching bookmarks. Matches are found in the
        /// bookmark name, URL, or folder path using wildcard pattern matching.
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 0,
            ValueFromRemainingArguments = false,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "Search terms to find matching bookmarks")]
        [Alias("q", "Name", "Text", "Query")]
        [SupportsWildcards()]
        public string[] Queries { get; set; }

        /// <summary>
        /// Switch to include Microsoft Edge bookmarks in the search.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Search through Microsoft Edge bookmarks")]
        [Alias("e")]
        public SwitchParameter Edge { get; set; }

        /// <summary>
        /// Switch to include Google Chrome bookmarks in the search.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Search through Google Chrome bookmarks")]
        [Alias("ch")]
        public SwitchParameter Chrome { get; set; }

        /// <summary>
        /// Switch to include Mozilla Firefox bookmarks in the search.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Search through Firefox bookmarks")]
        [Alias("ff")]
        public SwitchParameter Firefox { get; set; }

        /// <summary>
        /// Maximum number of results to return. Must be a positive integer.
        /// Default is 99999999.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Maximum number of results to return")]
        [ValidateRange(1, int.MaxValue)]
        public int Count { get; set; } = 99999999;

        /// <summary>
        /// Switch to return complete bookmark objects instead of just URLs. Each bookmark
        /// object contains Name, URL, and Folder properties.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Return bookmark objects instead of just URLs")]
        public SwitchParameter PassThru { get; set; }

        private PSObject[] bookmarks;

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Initializing browser bookmark search");

            // Copy parameters to Get-BrowserBookmark
            var paramsDict = CopyIdenticalParamValues("GenXdev.Webbrowser\\Get-BrowserBookmark");

            // Get bookmarks
            WriteVerbose("Fetching bookmarks from selected browsers");
            var getBookmarksScript = ScriptBlock.Create("param($params) GenXdev.Webbrowser\\Get-BrowserBookmark @params");
            var bookmarksResult = getBookmarksScript.Invoke(paramsDict);
            bookmarks = bookmarksResult.Select(r => (PSObject)r).ToArray();
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Handle case when no search queries provided
            if (Queries == null || Queries.Length == 0)
            {
                WriteVerbose("No search terms specified - returning all bookmarks");
                var allBookmarks = bookmarks.Take(Count);
                foreach (var bookmark in allBookmarks)
                {
                    WriteObject(bookmark);
                }
                return;
            }

            // Search bookmarks for matches to any query terms
            WriteVerbose($"Searching bookmarks for matches to {Queries.Length} queries");
            var allResults = new List<PSObject>();

            foreach (var query in Queries)
            {
                var processedQuery = query;
                if (!query.Contains("*") && !query.Contains("?"))
                {
                    processedQuery = "*" + query + "*";
                }
                WriteVerbose($"Processing query: {processedQuery}");

                var pattern = WildcardToRegex(processedQuery);
                var regex = new Regex(pattern, RegexOptions.IgnoreCase);

                var matchingBookmarks = bookmarks.Where(b =>
                    regex.IsMatch(b.Properties["Folder"].Value?.ToString() ?? "") ||
                    regex.IsMatch(b.Properties["Name"].Value?.ToString() ?? "") ||
                    regex.IsMatch(b.Properties["URL"].Value?.ToString() ?? ""));

                allResults.AddRange(matchingBookmarks);
            }

            var results = allResults.Take(Count);

            // Return either full bookmark objects or just URLs
            if (PassThru.ToBool())
            {
                WriteVerbose($"Returning {results.Count()} bookmark objects");
                foreach (var bookmark in results)
                {
                    WriteObject(bookmark);
                }
            }
            else
            {
                WriteVerbose($"Returning {results.Count()} bookmark URLs");
                foreach (var bookmark in results)
                {
                    var url = bookmark.Properties["URL"].Value?.ToString();
                    if (url != null)
                    {
                        WriteObject(url);
                    }
                }
            }
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
            // No cleanup needed
        }

        /// <summary>
        /// Converts a PowerShell wildcard pattern to a regular expression pattern
        /// </summary>
        /// <param name="pattern">The wildcard pattern to convert</param>
        /// <returns>The equivalent regular expression pattern</returns>
        private static string WildcardToRegex(string pattern)
        {
            return "^" + Regex.Escape(pattern).Replace("\\*", ".*").Replace("\\?", ".") + "$";
        }
    }
}