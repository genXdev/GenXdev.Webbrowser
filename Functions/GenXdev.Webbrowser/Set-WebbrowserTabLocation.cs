// ################################################################################
// Part of PowerShell module : GenXdev.Webbrowser
// Original cmdlet filename  : Set-WebbrowserTabLocation.cs
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
using System.Management.Automation;

namespace GenXdev.Webbrowser
{
    /// <summary>
    /// <para type="synopsis">
    /// Navigates the current webbrowser tab to a specified URL.
    /// </para>
    ///
    /// <para type="description">
    /// Sets the location (URL) of the currently selected webbrowser tab. Supports both
    /// Edge and Chrome browsers through optional switches. The navigation includes
    /// validation of the URL and ensures proper page loading through async operations.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -Url &lt;String&gt;<br/>
    /// The target URL for navigation. Accepts pipeline input and must be a valid URL
    /// string. This parameter is required.<br/>
    /// - <b>Position</b>: 0<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -NoAutoSelectTab &lt;SwitchParameter&gt;<br/>
    /// Prevents automatic tab selection if no tab is currently selected.<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Edge &lt;SwitchParameter&gt;<br/>
    /// Switch parameter to specifically target Microsoft Edge browser. Cannot be used
    /// together with -Chrome parameter.<br/>
    /// - <b>Aliases</b>: e<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Chrome &lt;SwitchParameter&gt;<br/>
    /// Switch parameter to specifically target Google Chrome browser. Cannot be used
    /// together with -Edge parameter.<br/>
    /// - <b>Aliases</b>: ch<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Page &lt;Object&gt;<br/>
    /// Browser page object for execution when using ByReference mode.<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -ByReference &lt;PSCustomObject&gt;<br/>
    /// Session reference object when using ByReference mode.<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Example navigating to GitHub using Edge</para>
    /// <para>This example demonstrates how to navigate to a URL using Microsoft Edge browser.</para>
    /// <code>
    /// Set-WebbrowserTabLocation -Url "https://github.com/microsoft" -Edge
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Example using pipeline input with Chrome</para>
    /// <para>This example shows how to use pipeline input to navigate to a URL using Google Chrome.</para>
    /// <code>
    /// "https://github.com/microsoft" | Set-WebbrowserTabLocation -Chrome
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Set, "WebbrowserTabLocation")]
    [Alias("lt", "Nav")]
    [OutputType(typeof(void))]
    public class SetWebbrowserTabLocationCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The target URL for navigation. Accepts pipeline input and must be a valid URL string. This parameter is required.
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "The URL to navigate to")]
        [ValidateNotNullOrEmpty()]
        public string Url { get; set; }

        /// <summary>
        /// Prevents automatic tab selection if no tab is currently selected.
        /// </summary>
        [Parameter(
            Mandatory = false,
            ValueFromPipeline = false,
            HelpMessage = "Prevent automatic tab selection")]
        public SwitchParameter NoAutoSelectTab { get; set; }

        /// <summary>
        /// Switch parameter to specifically target Microsoft Edge browser. Cannot be used together with -Chrome parameter.
        /// </summary>
        [Parameter(
            Mandatory = false,
            ParameterSetName = "Edge",
            HelpMessage = "Navigate using Microsoft Edge browser")]
        [Alias("e")]
        public SwitchParameter Edge { get; set; }

        /// <summary>
        /// Switch parameter to specifically target Google Chrome browser. Cannot be used together with -Edge parameter.
        /// </summary>
        [Parameter(
            Mandatory = false,
            ParameterSetName = "Chrome",
            HelpMessage = "Navigate using Google Chrome browser")]
        [Alias("ch")]
        public SwitchParameter Chrome { get; set; }

        /// <summary>
        /// Browser page object for execution when using ByReference mode.
        /// </summary>
        [Parameter(
            HelpMessage = "Browser page object reference",
            ValueFromPipeline = false)]
        public object Page { get; set; }

        /// <summary>
        /// Browser session reference object when using ByReference mode.
        /// </summary>
        [Parameter(
            HelpMessage = "Browser session reference object",
            ValueFromPipeline = false)]
        public PSObject ByReference { get; set; }

        private object pageObject;
        private PSObject reference;

        /// <summary>
        /// Initialize reference tracking and handle browser session setup
        /// </summary>
        protected override void BeginProcessing()
        {
            // Initialize reference tracking
            reference = null;

            // Handle reference initialization
            if ((Page == null) || (ByReference == null))
            {
                try
                {
                    // Call Get-ChromiumSessionReference to get the session reference
                    var getRefScript = ScriptBlock.Create("GenXdev.Webbrowser\\Get-ChromiumSessionReference");
                    var refResult = getRefScript.Invoke();
                    reference = (PSObject)refResult[0];

                    // Get the global chrome controller page object
                    var getGlobalScript = ScriptBlock.Create("$Global:chromeController");
                    var globalResult = getGlobalScript.Invoke();
                    pageObject = globalResult[0];
                }
                catch
                {
                    if (NoAutoSelectTab.ToBool())
                    {
                        throw;
                    }

                    // Attempt auto-selection of browser tab
                    try
                    {
                        // Create script to select webbrowser tab with appropriate switches
                        var selectScriptText = $"GenXdev.Webbrowser\\Select-WebbrowserTab -Chrome:${Chrome.ToBool()} -Edge:${Edge.ToBool()}";
                        var selectScript = ScriptBlock.Create(selectScriptText);
                        selectScript.Invoke();

                        // Get the page object after selection
                        var getGlobalScript = ScriptBlock.Create("$Global:chromeController");
                        var globalResult = getGlobalScript.Invoke();
                        pageObject = globalResult[0];

                        // Get the session reference after selection
                        var getRefScript = ScriptBlock.Create("GenXdev.Webbrowser\\Get-ChromiumSessionReference");
                        var refResult = getRefScript.Invoke();
                        reference = (PSObject)refResult[0];
                    }
                    catch { }
                }
            }
            else
            {
                reference = ByReference;
                pageObject = Page;
            }

            // Validate browser context
            if ((pageObject == null) || (reference == null))
            {
                throw new Exception("No browser tab selected, use Select-WebbrowserTab to select a tab first.");
            }
        }

        /// <summary>
        /// Process the navigation request for each input URL
        /// </summary>
        protected override void ProcessRecord()
        {
            if (ShouldProcess(Url, "Navigate to URL"))
            {
                // Log verbose message about navigation
                WriteVerbose($"Navigating to URL: {Url}");

                // Navigate to the URL using the page object's GotoAsync method
                var gotoScript = ScriptBlock.Create("param($page, $url) $page.GotoAsync($url)");
                gotoScript.Invoke(pageObject, Url);

                // Wait for navigation to complete
                var waitScript = ScriptBlock.Create("param($page) $page.WaitForNavigationAsync().Result");
                waitScript.Invoke(pageObject);
            }
        }

        /// <summary>
        /// End processing - no cleanup needed
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}