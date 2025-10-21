// ################################################################################
// Part of PowerShell module : GenXdev.Webbrowser.Playwright
// Original cmdlet filename  : Resume-WebbrowserTabVideo.cs
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
    /// Resumes video playback in a YouTube browser tab.
    /// </para>
    ///
    /// <para type="description">
    /// Finds the active YouTube browser tab and resumes video playback by executing the
    /// play() method on any video elements found in the page. If no YouTube tab is
    /// found, the function throws an error. This function is particularly useful for
    /// automating video playback control in browser sessions.
    /// </para>
    ///
    /// <example>
    /// <para>Resume video playback in the active YouTube tab</para>
    /// <para>This example finds the active YouTube browser tab and resumes video playback.</para>
    /// <code>
    /// Resume-WebbrowserTabVideo
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Resume video playback using the alias</para>
    /// <para>This example demonstrates using the wbvideoplay alias to resume video playback.</para>
    /// <code>
    /// wbvideoplay
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet("Resume", "WebbrowserTabVideo")]
    [Alias("wbvideoplay")]
    public class ResumeWebbrowserTabVideoCommand : PSGenXdevCmdlet
    {

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {

            // Search for a youtube tab in the current browser session
            WriteVerbose("Attempting to locate an active YouTube tab...");

            InvokeCommand.InvokeScript("GenXdev.Webbrowser\\Select-WebbrowserTab -Name '*youtube*'");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {

            // Verify that a youtube tab was successfully found and selected
            var chromeSession = SessionState.PSVariable.GetValue("chromeSession");
            if (chromeSession == null)
            {
                // Throw terminating error matching original PowerShell behavior
                ThrowTerminatingError(new ErrorRecord(
                    new Exception("No YouTube tab found in current browser session"),
                    "NoYouTubeTab",
                    ErrorCategory.ObjectNotFound,
                    null));
            }

            WriteVerbose("YouTube tab found - initiating video playback...");

            // Execute the play() method on all video elements in the current page
            InvokeCommand.InvokeScript("GenXdev.Webbrowser\\Get-WebbrowserTabDomNodes 'video' 'e.play()'");

            WriteVerbose("Video playback successfully resumed");
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}