// ################################################################################
// Part of PowerShell module : GenXdev.Webbrowser
// Original cmdlet filename  : Close-WebbrowserTab.cs
// Original author           : René Vaessen / GenXdev
// Version                   : 1.304.2025
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



using System.Linq;
using System.Management.Automation;

namespace GenXdev.Webbrowser
{
    /// <summary>
    /// <para type="synopsis">
    /// Closes the currently selected webbrowser tab.
    /// </para>
    ///
    /// <para type="description">
    /// Closes the currently selected webbrowser tab using ChromeDriver's CloseAsync()
    /// method. If no tab is currently selected, the function will automatically attempt
    /// to select the last used tab before closing it.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -Edge &lt;SwitchParameter&gt;<br/>
    /// Navigate using Microsoft Edge browser<br/>
    /// - <b>Aliases</b>: e<br/>
    /// - <b>Position</b>: named<br/>
    /// - <b>Default</b>: False<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Chrome &lt;SwitchParameter&gt;<br/>
    /// Navigate using Google Chrome browser<br/>
    /// - <b>Aliases</b>: ch<br/>
    /// - <b>Position</b>: named<br/>
    /// - <b>Default</b>: False<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Closes the currently active browser tab</para>
    /// <para></para>
    /// <code>
    /// Close-WebbrowserTab
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Uses the alias to close the currently active browser tab</para>
    /// <para></para>
    /// <code>
    /// ct
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Close, "WebbrowserTab")]
    [OutputType(typeof(void))]
    public class CloseWebbrowserTabCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Navigate using Microsoft Edge browser
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Navigate using Microsoft Edge browser"
        )]
        [Alias("e")]
        public SwitchParameter Edge { get; set; }

        /// <summary>
        /// Navigate using Google Chrome browser
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Navigate using Google Chrome browser"
        )]
        [Alias("ch")]
        public SwitchParameter Chrome { get; set; }

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            string chromeParam = Chrome.ToBool() ? " -Chrome" : "";
            string edgeParam = Edge.ToBool() ? " -Edge" : "";

            try
            {
                WriteVerbose("Attempting to locate active browser session");
                InvokeCommand.InvokeScript($"GenXdev.Webbrowser\\Get-ChromiumSessionReference{chromeParam}{edgeParam}");
            }
            catch
            {
                WriteVerbose("No active session found, selecting last used tab");
                InvokeCommand.InvokeScript($"GenXdev.Webbrowser\\Select-WebbrowserTab{chromeParam}{edgeParam}");
            }
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Retrieve title and URL from global variables
            var titleResult = InvokeCommand.InvokeScript("$Global:chromeSession.title");
            string title = titleResult.Any() ? titleResult.First().BaseObject.ToString() : "";

            var urlResult = InvokeCommand.InvokeScript("$Global:chromeSession.url");
            string url = urlResult.Any() ? urlResult.First().BaseObject.ToString() : "";

            WriteVerbose($"Closing browser tab: '{title}' at URL: {url}");

            // Close the tab asynchronously and wait
            InvokeCommand.InvokeScript("$Global:chromeController.CloseAsync().Wait()");
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
            // No cleanup needed
        }
    }
}