// ################################################################################
// Part of PowerShell module : GenXdev.Webbrowser
// Original cmdlet filename  : Get-ChromiumRemoteDebuggingPort.cs
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
    /// Returns the remote debugging port for the system's default Chromium browser.
    /// </para>
    ///
    /// <para type="description">
    /// Detects whether Microsoft Edge or Google Chrome is the default browser and
    /// returns the appropriate debugging port number. If Chrome is the default browser,
    /// returns the Chrome debugging port. Otherwise returns the Edge debugging port
    /// (also used when no default browser is detected).
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -Chrome &lt;SwitchParameter&gt;<br/>
    /// Forces the cmdlet to return the Chrome debugging port.<br/>
    /// - <b>Position</b>: named<br/>
    /// - <b>Default</b>: false<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Edge &lt;SwitchParameter&gt;<br/>
    /// Forces the cmdlet to return the Edge debugging port.<br/>
    /// - <b>Position</b>: named<br/>
    /// - <b>Default</b>: false<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Get debugging port using full command name</para>
    /// <para></para>
    /// <code>
    /// Get-ChromiumRemoteDebuggingPort
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Get debugging port using alias</para>
    /// <para></para>
    /// <code>
    /// Get-BrowserDebugPort
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "ChromiumRemoteDebuggingPort")]
    [OutputType(typeof(int))]
    public class GetChromiumRemoteDebuggingPortCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Forces the cmdlet to return the Chrome debugging port
        /// </summary>
        [Parameter(
            HelpMessage = "Forces the cmdlet to return the Chrome debugging port")]
        public SwitchParameter Chrome { get; set; }

        /// <summary>
        /// Forces the cmdlet to return the Edge debugging port
        /// </summary>
        [Parameter(
            HelpMessage = "Forces the cmdlet to return the Edge debugging port")]
        public SwitchParameter Edge { get; set; }

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Starting detection of default Chromium browser type");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            if (Chrome)
            {
                WriteVerbose("Using Chrome debugging port");

                var result = InvokeCommand.InvokeScript("GenXdev.Webbrowser\\Get-ChromeRemoteDebuggingPort");

                WriteObject(result[0].BaseObject);

                return;
            }

            if (Edge)
            {
                WriteVerbose("Using Edge debugging port");

                var result = InvokeCommand.InvokeScript("GenXdev.Webbrowser\\Get-EdgeRemoteDebuggingPort");

                WriteObject(result[0].BaseObject);

                return;
            }

            var defaultBrowser = InvokeCommand.InvokeScript("GenXdev.Webbrowser\\Get-DefaultWebbrowser");

            PSObject browserObj = null;

            if (defaultBrowser.Count > 0)
            {
                browserObj = defaultBrowser[0] as PSObject;
            }

            string browserName = null;

            if (browserObj != null && browserObj.Properties["Name"] != null)
            {
                browserName = browserObj.Properties["Name"].Value?.ToString();
            }

            WriteVerbose($"Default browser detected: {browserName ?? "None"}");

            if (!string.IsNullOrEmpty(browserName) &&
                browserName.IndexOf("Chrome", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                WriteVerbose("Using Chrome debugging port");

                var result = InvokeCommand.InvokeScript("GenXdev.Webbrowser\\Get-ChromeRemoteDebuggingPort");

                WriteObject(result[0].BaseObject);
            }
            else
            {
                WriteVerbose("Using Edge debugging port");

                var result = InvokeCommand.InvokeScript("GenXdev.Webbrowser\\Get-EdgeRemoteDebuggingPort");

                WriteObject(result[0].BaseObject);
            }
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}