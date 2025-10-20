// ################################################################################
// Part of PowerShell module : GenXdev.Webbrowser
// Original cmdlet filename  : Import-GenXdevBookmarkletMenu.cs
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
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Management.Automation;

namespace GenXdev.Webbrowser
{
    /// <summary>
    /// <para type="synopsis">
    /// Imports GenXdev JavaScript bookmarklets into browser bookmark collections.
    /// </para>
    ///
    /// <para type="description">
    /// This cmdlet scans a directory for GenXdev bookmarklet files with the
    /// .bookmarklet.txt extension and imports them into the specified web browser
    /// as bookmarks. The bookmarklets are placed in browser-specific folders and
    /// can be used as interactive tools in web pages. The cmdlet supports Edge,
    /// Chrome, and Firefox browsers and provides a preview mode for safety.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -SnippetsPath &lt;String&gt;<br/>
    /// The file system path to the directory containing bookmarklet snippet files.
    /// Each file should have a .bookmarklet.txt extension and contain JavaScript
    /// code that can be executed as a bookmarklet in web browsers.<br/>
    /// - <b>Position</b>: 0<br/>
    /// - <b>Default</b>: "$PSScriptRoot\..\..\Bookmarklets"<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -TargetFolder &lt;String&gt;<br/>
    /// The target browser bookmark folder where the bookmarklets will be imported.
    /// If not specified, the folder is automatically determined based on the
    /// selected browser type. Uses browser-specific default bookmark bar
    /// locations.<br/>
    /// - <b>Position</b>: 1<br/>
    /// - <b>Default</b>: ""<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Edge &lt;SwitchParameter&gt;<br/>
    /// Specifies Microsoft Edge as the target browser for importing bookmarklets.
    /// When used, bookmarklets are placed in the Edge Bookmarks Bar folder for
    /// easy access from the browser toolbar.<br/>
    /// - <b>Default</b>: false<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Chrome &lt;SwitchParameter&gt;<br/>
    /// Specifies Google Chrome as the target browser for importing bookmarklets.
    /// When used, bookmarklets are placed in the Chrome Bookmarks Bar folder for
    /// easy access from the browser toolbar.<br/>
    /// - <b>Default</b>: false<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Firefox &lt;SwitchParameter&gt;<br/>
    /// Specifies Mozilla Firefox as the target browser for importing bookmarklets.
    /// When used, bookmarklets are placed in the Firefox bookmarks folder
    /// structure for browser integration.<br/>
    /// - <b>Default</b>: false<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -WhatIf &lt;SwitchParameter&gt;<br/>
    /// Performs a dry run of the import operation without actually creating any
    /// bookmarks. Displays what bookmarklets would be imported and where they
    /// would be placed for verification before executing the actual import.<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Import bookmarklets into Microsoft Edge</para>
    /// <para>Imports all bookmarklet files from the default snippets directory
    /// into Microsoft Edge's bookmark bar folder.</para>
    /// <code>
    /// Import-GenXdevBookmarkletMenu -Edge
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Preview bookmarklet import to Chrome</para>
    /// <para>Shows what bookmarklets would be imported from the specified path
    /// into Google Chrome without actually performing the import operation.</para>
    /// <code>
    /// Import-GenXdevBookmarkletMenu -SnippetsPath "C:\MyBookmarklets" -Chrome -WhatIf
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsData.Import, "GenXdevBookmarkletMenu",
        SupportsShouldProcess = true,
        ConfirmImpact = ConfirmImpact.Medium)]
    public class ImportGenXdevBookmarkletMenuCommand : PSGenXdevCmdlet
    {

        /// <summary>
        /// Path to directory containing bookmarklet snippet files
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 0,
            HelpMessage = "Path to directory containing bookmarklet snippet files")]
        public string SnippetsPath { get; set; }

        /// <summary>
        /// Target bookmark folder in browser bookmark structure
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 1,
            HelpMessage = "Target bookmark folder in browser bookmark structure")]
        public string TargetFolder { get; set; } = "";

        /// <summary>
        /// Import bookmarklets into Microsoft Edge browser
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Import bookmarklets into Microsoft Edge browser")]
        public SwitchParameter Edge { get; set; }

        /// <summary>
        /// Import bookmarklets into Google Chrome browser
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Import bookmarklets into Google Chrome browser")]
        public SwitchParameter Chrome { get; set; }

        /// <summary>
        /// Import bookmarklets into Mozilla Firefox browser
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Import bookmarklets into Mozilla Firefox browser")]
        public SwitchParameter Firefox { get; set; }

        private string resolvedSnippetsPath;
        private bool snippetsPathValid;

        /// <summary>
        /// Begin processing - validates snippets directory and changes location
        /// </summary>
        protected override void BeginProcessing()
        {

            // set default snippets path if not provided by user
            if (string.IsNullOrEmpty(SnippetsPath))
            {

                // construct path relative to module script root directory
                var moduleBase = GetGenXdevModuleBase("GenXdev.Webbrowser");

                SnippetsPath = Path.Combine(moduleBase, "Bookmarklets");
            }

            // expand and validate the snippets directory path
            resolvedSnippetsPath = ExpandPath(SnippetsPath);

            // validate the snippets directory exists before proceeding
            if (Directory.Exists(resolvedSnippetsPath))
            {

                snippetsPathValid = true;

                // change to the snippets directory for file operations
                var setLocationScript = ScriptBlock.Create(
                    "param($path) Microsoft.PowerShell.Management\\Set-Location $path"
                );

                setLocationScript.Invoke(resolvedSnippetsPath);

                WriteVerbose(
                    $"Changed directory to snippets path: {resolvedSnippetsPath}"
                );
            }
            else
            {

                snippetsPathValid = false;

                // output error message when snippets directory is not found
                WriteError(new ErrorRecord(
                    new DirectoryNotFoundException(
                        $"Snippets path not found: {resolvedSnippetsPath}"
                    ),
                    "SnippetsPathNotFound",
                    ErrorCategory.ObjectNotFound,
                    resolvedSnippetsPath
                ));
            }
        }

        /// <summary>
        /// Process record - main cmdlet logic for importing bookmarklets
        /// </summary>
        protected override void ProcessRecord()
        {

            // skip processing if snippets directory validation failed
            if (!snippetsPathValid)
            {

                return;
            }

            // find all bookmarklet files with the expected extension
            var bookmarkletFiles = Directory.GetFiles(
                resolvedSnippetsPath,
                "*.bookmarklet.txt",
                SearchOption.TopDirectoryOnly
            );

            // check if any bookmarklet files were found in the directory
            if (bookmarkletFiles.Length == 0)
            {

                WriteWarning(
                    $"No bookmarklet files found in {resolvedSnippetsPath}"
                );

                return;
            }

            WriteVerbose(
                $"Found {bookmarkletFiles.Length} snippet files to import"
            );

            // determine target folder path based on selected browser
            string effectiveTargetFolder = TargetFolder;

            if (string.IsNullOrEmpty(effectiveTargetFolder))
            {

                if (Edge.ToBool())
                {

                    // set default Edge bookmark bar folder path
                    effectiveTargetFolder = "Edge\\Bookmarks Bar\\▼";
                }
                else if (Chrome.ToBool())
                {

                    // set default Chrome bookmark bar folder path
                    effectiveTargetFolder = "Chrome\\Bookmarks Bar\\▼";
                }
                else if (Firefox.ToBool())
                {

                    // set default Firefox bookmark folder path
                    effectiveTargetFolder = "Firefox\\▼";
                }
                else
                {

                    // default to Edge browser when no browser is specified
                    effectiveTargetFolder = "Edge\\Bookmarks Bar\\▼";

                    Edge = true;
                }
            }

            WriteVerbose($"Target folder: {effectiveTargetFolder}");

            // create bookmark objects from each bookmarklet file
            var bookmarksToImport = new List<PSObject>();

            foreach (var filePath in bookmarkletFiles)
            {

                // read the javascript content from the bookmarklet file
                var bookmarkletUrl = File.ReadAllText(filePath).Trim();

                // extract bookmark name by removing the file extension
                var fileName = Path.GetFileNameWithoutExtension(filePath);

                var bookmarkName = fileName.EndsWith(".bookmarklet")
                    ? fileName.Substring(0, fileName.Length - ".bookmarklet".Length)
                    : fileName;

                // get file metadata for timestamp information
                var fileInfo = new FileInfo(filePath);

                // create structured bookmark object for import operation
                var bookmark = new PSObject();

                bookmark.Properties.Add(new PSNoteProperty("Name", bookmarkName));

                bookmark.Properties.Add(new PSNoteProperty("URL", bookmarkletUrl));

                bookmark.Properties.Add(
                    new PSNoteProperty("Folder", effectiveTargetFolder)
                );

                bookmark.Properties.Add(
                    new PSNoteProperty("DateAdded", fileInfo.CreationTime)
                );

                bookmark.Properties.Add(
                    new PSNoteProperty("DateModified", fileInfo.LastWriteTime)
                );

                bookmarksToImport.Add(bookmark);
            }

            // check if user wants to proceed with the import operation
            if (!ShouldProcess(
                $"Import {bookmarksToImport.Count} bookmarklets to {effectiveTargetFolder}",
                "Import bookmarklets",
                "Confirm Bookmarklet Import"))
            {

                return;
            }

            // prepare parameters for the import browser bookmarks function
            var importParams = new Hashtable
            {
                ["Bookmarks"] = bookmarksToImport.ToArray()
            };

            // add browser-specific parameters to the import operation
            if (Edge.ToBool())
            {

                importParams["Edge"] = true;
            }

            if (Chrome.ToBool())
            {

                importParams["Chrome"] = true;
            }

            if (Firefox.ToBool())
            {

                importParams["Firefox"] = true;
            }

            WriteVerbose(
                $"Importing {bookmarksToImport.Count} bookmarks to folder " +
                $"'{effectiveTargetFolder}'"
            );

            // execute the bookmark import operation with error handling
            try
            {

                var importScript = ScriptBlock.Create(
                    "param($params) GenXdev.Webbrowser\\Import-BrowserBookmarks " +
                    "@params -Verbose"
                );

                importScript.Invoke(importParams);

                Host.UI.WriteLine(
                    ConsoleColor.Green,
                    Host.UI.RawUI.BackgroundColor,
                    "Successfully imported snippets as bookmarks!"
                );

                Host.UI.WriteLine(
                    ConsoleColor.Cyan,
                    Host.UI.RawUI.BackgroundColor,
                    $"Check your browser's '{effectiveTargetFolder}' folder for the " +
                    "imported bookmarks."
                );
            }
            catch (Exception ex)
            {

                WriteError(new ErrorRecord(
                    ex,
                    "BookmarkImportFailed",
                    ErrorCategory.OperationStopped,
                    bookmarksToImport
                ));
            }
        }

        /// <summary>
        /// End processing - closes browser instances if user confirms
        /// </summary>
        protected override void EndProcessing()
        {

            // check if user wants to proceed with browser closure
            if (!ShouldProcess(
                "Close any open browser instances",
                "Close browsers",
                "Confirm Browser Closure"))
            {

                return;
            }

            // copy identical parameters for Close-Webbrowser cmdlet
            var closeParams = CopyIdenticalParamValues(
                "GenXdev.Webbrowser\\Close-Webbrowser"
            );

            // invoke the Close-Webbrowser cmdlet with copied parameters
            var closeScript = ScriptBlock.Create(
                "param($params) GenXdev.Webbrowser\\Close-Webbrowser @params"
            );

            closeScript.Invoke(closeParams);
        }
    }
}
