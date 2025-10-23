// ################################################################################
// Part of PowerShell module : GenXdev.Webbrowser
// Original cmdlet filename  : Close-Webbrowser.cs
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
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Management.Automation;
using GenXdev.Helpers;

namespace GenXdev.Webbrowser
{
    /// <summary>
    /// <para type="synopsis">
    /// Closes one or more webbrowser instances selectively.
    /// </para>
    ///
    /// <para type="description">
    /// Provides granular control over closing web browser instances. Can target
    /// specific browsers (Edge, Chrome, Firefox) or close all browsers. Supports
    /// closing both main windows and background processes.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -Edge &lt;SwitchParameter&gt;<br/>
    /// Closes all Microsoft Edge browser instances.<br/>
    /// - <b>Aliases</b>: e<br/>
    /// - <b>Position</b>: 0<br/>
    /// - <b>ParameterSetName</b>: Specific<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Chrome &lt;SwitchParameter&gt;<br/>
    /// Closes all Google Chrome browser instances.<br/>
    /// - <b>Aliases</b>: ch<br/>
    /// - <b>Position</b>: 1<br/>
    /// - <b>ParameterSetName</b>: Specific<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Chromium &lt;SwitchParameter&gt;<br/>
    /// Closes the default Chromium-based browser (Edge or Chrome).<br/>
    /// - <b>Aliases</b>: c<br/>
    /// - <b>Position</b>: 2<br/>
    /// - <b>ParameterSetName</b>: Specific<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Firefox &lt;SwitchParameter&gt;<br/>
    /// Closes all Firefox browser instances.<br/>
    /// - <b>Aliases</b>: ff<br/>
    /// - <b>Position</b>: 3<br/>
    /// - <b>ParameterSetName</b>: Specific<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -All &lt;SwitchParameter&gt;<br/>
    /// Closes all detected modern browser instances.<br/>
    /// - <b>Aliases</b>: a<br/>
    /// - <b>Position</b>: 0<br/>
    /// - <b>ParameterSetName</b>: All<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -IncludeBackgroundProcesses &lt;SwitchParameter&gt;<br/>
    /// Also closes background processes and tasks for the selected browsers.<br/>
    /// - <b>Aliases</b>: bg, Force<br/>
    /// - <b>Position</b>: 4<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Closes all Chrome and Firefox instances including background
    /// processes</para>
    /// <code>
    /// Close-Webbrowser -Chrome -Firefox -IncludeBackgroundProcesses
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Closes all browser instances including background processes using
    /// aliases</para>
    /// <code>
    /// wbc -a -bg
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Close, "Webbrowser",
        DefaultParameterSetName = "Specific")]
    [Alias("wbc")]
    public class CloseWebbrowserCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Closes Microsoft Edge browser instances
        /// </summary>
        [Alias("e")]
        [Parameter(
            Mandatory = false,
            Position = 0,
            ParameterSetName = "Specific",
            HelpMessage = "Closes Microsoft Edge browser instances")]
        public SwitchParameter Edge { get; set; }

        /// <summary>
        /// Closes Google Chrome browser instances
        /// </summary>
        [Alias("ch")]
        [Parameter(
            Mandatory = false,
            Position = 1,
            ParameterSetName = "Specific",
            HelpMessage = "Closes Google Chrome browser instances")]
        public SwitchParameter Chrome { get; set; }

        /// <summary>
        /// Closes default chromium-based browser
        /// </summary>
        [Alias("c")]
        [Parameter(
            Mandatory = false,
            Position = 2,
            ParameterSetName = "Specific",
            HelpMessage = "Closes default chromium-based browser")]
        public SwitchParameter Chromium { get; set; }

        /// <summary>
        /// Closes Firefox browser instances
        /// </summary>
        [Alias("ff")]
        [Parameter(
            Mandatory = false,
            Position = 3,
            ParameterSetName = "Specific",
            HelpMessage = "Closes Firefox browser instances")]
        public SwitchParameter Firefox { get; set; }

        /// <summary>
        /// Closes all registered modern browsers
        /// </summary>
        [Alias("a")]
        [Parameter(
            Mandatory = false,
            Position = 0,
            ParameterSetName = "All",
            HelpMessage = "Closes all registered modern browsers")]
        public SwitchParameter All { get; set; }

        /// <summary>
        /// Closes all instances including background tasks
        /// </summary>
        [Alias("bg", "Force")]
        [Parameter(
            Mandatory = false,
            Position = 4,
            HelpMessage = "Closes all instances including background tasks")]
        public SwitchParameter IncludeBackgroundProcesses { get; set; }

        private List<PSObject> installedBrowsers;
        private PSObject defaultBrowser;

        /// <summary>
        /// Begin processing - query system for installed browser information
        /// </summary>
        protected override void BeginProcessing()
        {

            // copy identical parameters for Get-Webbrowser call
            var getWebbrowserParams = CopyIdenticalParamValues(
                "GenXdev.Webbrowser\\Get-Webbrowser");

            // query system for installed browser information
            var getWebbrowserScript = ScriptBlock.Create(
                "param($params) GenXdev.Webbrowser\\Get-Webbrowser @params");

            var installedBrowserResults = getWebbrowserScript.Invoke(getWebbrowserParams);

            installedBrowsers = installedBrowserResults.ToList();

            // determine system default browser
            defaultBrowser = InvokeScript<PSObject>(
                "GenXdev.Webbrowser\\Get-DefaultWebbrowser");

            WriteVerbose($"Found {installedBrowsers.Count} installed browsers");

            WriteVerbose($"Default browser: {defaultBrowser.Properties["Name"].Value}");
        }

        /// <summary>
        /// Process record - close selected browser instances
        /// </summary>
        protected override void ProcessRecord()
        {

            // close all browsers if requested
            if (All.ToBool())
            {

                WriteVerbose("Closing all browsers");

                foreach (var browser in installedBrowsers)
                {

                    CloseBrowserInstance(browser);
                }

                return;
            }

            // handle default chromium browser closure
            if (Chromium.ToBool() && !Chrome.ToBool() && !Edge.ToBool())
            {

                var defaultBrowserName =
                    defaultBrowser.Properties["Name"].Value?.ToString() ?? string.Empty;

                if (defaultBrowserName.Contains("Chrome") ||
                    defaultBrowserName.Contains("Edge"))
                {

                    CloseBrowserInstance(defaultBrowser);

                    return;
                }

                // fallback to first available chromium browser
                var chromiumBrowser = installedBrowsers
                    .FirstOrDefault(b =>
                    {
                        var name = b.Properties["Name"].Value?.ToString() ?? string.Empty;

                        return name.Contains("Edge") || name.Contains("Chrome");
                    });

                if (chromiumBrowser != null)
                {

                    CloseBrowserInstance(chromiumBrowser);
                }

                return;
            }

            // handle specific browser closures
            if (Chrome.ToBool())
            {

                var chromeBrowsers = installedBrowsers
                    .Where(b =>
                    {
                        var name = b.Properties["Name"].Value?.ToString() ?? string.Empty;

                        return name.Contains("Chrome");
                    });

                foreach (var browser in chromeBrowsers)
                {

                    CloseBrowserInstance(browser);
                }
            }

            if (Edge.ToBool())
            {

                var edgeBrowsers = installedBrowsers
                    .Where(b =>
                    {
                        var name = b.Properties["Name"].Value?.ToString() ?? string.Empty;

                        return name.Contains("Edge");
                    });

                foreach (var browser in edgeBrowsers)
                {

                    CloseBrowserInstance(browser);
                }
            }

            if (Firefox.ToBool())
            {

                var firefoxBrowsers = installedBrowsers
                    .Where(b =>
                    {
                        var name = b.Properties["Name"].Value?.ToString() ?? string.Empty;

                        return name.Contains("Firefox");
                    });

                foreach (var browser in firefoxBrowsers)
                {

                    CloseBrowserInstance(browser);
                }
            }

            // close default browser if no specific browser selected
            if (!Chromium.ToBool() && !Chrome.ToBool() &&
                !Edge.ToBool() && !Firefox.ToBool())
            {

                CloseBrowserInstance(defaultBrowser);
            }
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }

        /// <summary>
        /// Closes a specific browser instance
        /// </summary>
        /// <param name="browser">Browser object containing path and name</param>
        private void CloseBrowserInstance(PSObject browser)
        {

            var browserName = browser.Properties["Name"].Value?.ToString() ?? "Unknown";

            var browserPath = browser.Properties["Path"].Value?.ToString();

            WriteVerbose($"Attempting to close {browserName}");

            if (string.IsNullOrEmpty(browserPath))
            {

                WriteWarning($"Browser path not found for {browserName}");

                return;
            }

            // extract process name without extension for matching
            var processName = Path.GetFileNameWithoutExtension(browserPath);

            // find and process all matching browser instances
            Process[] processes;

            try
            {
                processes = Process.GetProcessesByName(processName);
            }
            catch
            {
                return;
            }

            foreach (var currentProcess in processes)
            {

                try
                {
                    // handle background processes based on user preference
                    if (!IncludeBackgroundProcesses.ToBool() &&
                        currentProcess.MainWindowHandle == IntPtr.Zero)
                    {

                        WriteVerbose($"Skipping background process {currentProcess.Id}");

                        continue;
                    }
                    else if (currentProcess.MainWindowHandle != IntPtr.Zero)
                    {

                        // attempt graceful window close for processes with UI
                        var windows = WindowObj.GetMainWindow(currentProcess);

                        foreach (var window in windows)
                        {

                            var startTime = System.DateTime.UtcNow;

                            // try graceful close
                            window.Close();

                            // wait up to 4 seconds for process to exit
                            while (!currentProcess.HasExited &&
                                (System.DateTime.UtcNow - startTime < TimeSpan.FromSeconds(4)))
                            {

                                System.Threading.Thread.Sleep(20);
                            }

                            if (currentProcess.HasExited)
                            {

                                SetGlobalVariable(
                                    $"_LastClose{browserName}",
                                    System.DateTime.UtcNow.AddSeconds(-1));

                                continue;
                            }
                        }
                    }

                    // force terminate if process still running
                    try
                    {
                        currentProcess.Kill();

                        SetGlobalVariable($"_LastClose{browserName}", System.DateTime.UtcNow);
                    }
                    catch (Exception ex)
                    {

                        WriteWarning($"Failed to kill {browserName} process: {ex.Message}");
                    }
                }
                catch
                {
                }
            }
        }
    }
}
