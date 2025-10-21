// ################################################################################
// Part of PowerShell module : GenXdev.Webbrowser.Playwright
// Original cmdlet filename  : Stop-WebbrowserVideos.cs
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



using System;
using System.Management.Automation;

namespace GenXdev.Webbrowser.Playwright
{
    /// <summary>
    /// <para type="synopsis">
    /// Pauses video playback in all active browser sessions.
    /// </para>
    ///
    /// <para type="description">
    /// Iterates through all active browser sessions and pauses any playing videos by
    /// executing JavaScript commands. The function maintains the original session state
    /// and handles errors gracefully.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -Edge &lt;SwitchParameter&gt;<br/>
    /// Opens in Microsoft Edge<br/>
    /// - <b>Aliases</b>: e<br/>
    /// - <b>Position</b>: Named<br/>
    /// - <b>Default</b>: False<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Chrome &lt;SwitchParameter&gt;<br/>
    /// Opens in Google Chrome<br/>
    /// - <b>Aliases</b>: ch<br/>
    /// - <b>Position</b>: Named<br/>
    /// - <b>Default</b>: False<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Stop-WebbrowserVideos</para>
    /// <para>Pauses video playback in all active browser sessions.</para>
    /// <code>
    /// Stop-WebbrowserVideos
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>wbsst</para>
    /// <para>Pauses video playback using the alias.</para>
    /// <code>
    /// wbsst
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet("Stop", "WebbrowserVideos", SupportsShouldProcess = true)]
    [Alias("wbsst", "ssst", "wbvideostop")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    public class StopWebbrowserVideosCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Opens in Microsoft Edge
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Opens in Microsoft Edge")]
        [Alias("e")]
        public SwitchParameter Edge { get; set; }

        /// <summary>
        /// Opens in Google Chrome
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Opens in Google Chrome")]
        [Alias("ch")]
        public SwitchParameter Chrome { get; set; }

        private object originalSession;
        private object originalController;

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Starting video pause operation across browser sessions");

            // Store the current session reference to restore it later
            originalSession = SessionState.PSVariable.GetValue("chromeSession");
            originalController = SessionState.PSVariable.GetValue("chromeController");

            // Ensure we have an active browser session
            var sessions = SessionState.PSVariable.GetValue("chromeSessions") as PSObject[];
            if (sessions == null || sessions.Length == 0)
            {
                // Select a browser tab if none are active
                var selectScript = ScriptBlock.Create("param($chrome, $edge) GenXdev.Webbrowser\\Select-WebbrowserTab -Chrome:$chrome -Edge:$edge");
                selectScript.Invoke(Chrome.ToBool(), Edge.ToBool());
            }
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Iterate through each browser session and pause videos
            var sessions = SessionState.PSVariable.GetValue("chromeSessions") as PSObject[];
            if (sessions != null)
            {
                foreach (var currentSession in sessions)
                {
                    if (currentSession == null) continue;
                    if (ShouldProcess("Browser session", "Pause videos"))
                    {
                        try
                        {
                            WriteVerbose($"Attempting to pause videos in session: {currentSession}");

                            // Select the current tab for processing
                            SessionState.PSVariable.Set("chromeSession", currentSession);
                            var selectScript = ScriptBlock.Create("param($session) GenXdev.Webbrowser\\Select-WebbrowserTab -ByReference $session");
                            selectScript.Invoke(currentSession);

                            // Execute pause() command on all video elements
                            var domScript = ScriptBlock.Create("GenXdev.Webbrowser\\Get-WebbrowserTabDomNodes 'video' 'e.pause()' -NoAutoSelectTab");
                            domScript.Invoke();
                        }
                        catch (Exception ex)
                        {
                            WriteWarning($"Failed to pause videos in session: {currentSession}  \r\n{ex.Message}");
                        }
                    }
                }
            }
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
            WriteVerbose("Restoring original browser session reference");
            SessionState.PSVariable.Set("chromeSession", originalSession);
            SessionState.PSVariable.Set("chromeController", originalController);
        }
    }
}