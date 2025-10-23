// ################################################################################
// Part of PowerShell module : GenXdev.Webbrowser
// Original cmdlet filename  : Set-BrowserVideoFullscreen.cs
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
using System.Diagnostics;
using System.Linq;
using System.Management.Automation;
using System.Threading;

namespace GenXdev.Webbrowser
{
    /// <summary>
    /// <para type="synopsis">
    /// Sets the first video element on the current webpage to fullscreen mode by manipulating its CSS properties and DOM position.
    /// </para>
    ///
    /// <para type="description">
    /// This cmdlet modifies the first &lt;video&gt; element found on the current webpage to display in fullscreen mode.
    /// It achieves this by:
    /// 1. Selecting the first video element using document.getElementsByTagName('video')[0]
    /// 2. Applying fixed positioning CSS to cover the entire viewport
    /// 3. Moving the video element to the document body for proper layering
    /// 4. Hiding body overflow to prevent scrolling
    ///
    /// The cmdlet uses JavaScript injection to execute these DOM manipulations directly in the browser.
    /// </para>
    ///
    /// <example>
    /// <para>Set the current webpage's video to fullscreen</para>
    /// <para>This example makes the first video element on the active browser tab display in fullscreen mode.</para>
    /// <code>
    /// Set-BrowserVideoFullscreen
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Use the alias for convenience</para>
    /// <para>The cmdlet can also be called using its alias 'fsvideo'.</para>
    /// <code>
    /// fsvideo
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Set, "BrowserVideoFullscreen")]
    [Alias("fsvideo")]
    public class SetBrowserVideoFullscreenCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Begin processing - prepare the JavaScript command for video manipulation
        /// </summary>
        protected override void BeginProcessing()
        {
            // Build the JavaScript command that will handle video manipulation
            // This script selects the first video element, applies fullscreen CSS styling,
            // moves it to the document body, and prevents body scrolling
            script = string.Join("", new[] {
                "window.video = document.getElementsByTagName('video')[0];",
                "video.setAttribute('style','position:fixed;left:0;top:0;bottom:0;",
                "right:0;z-index:10000;width:100vw;height:100vh');",
                "document.body.appendChild(video);",
                "document.body.setAttribute('style', 'overflow:hidden');"
            });

            WriteVerbose("Prepared JavaScript code for video fullscreen manipulation");
        }

        /// <summary>
        /// Process record - execute the video fullscreen operation
        /// </summary>
        protected override void ProcessRecord()
        {
            // Check if we should proceed with the operation
            if (ShouldProcess("browser video", "Set to fullscreen mode"))
            {
                WriteVerbose("Executing JavaScript to maximize video element");

                // Create and invoke the script block to call the PowerShell cmdlet
                // This safely executes the JavaScript in the browser context
                var scriptBlock = ScriptBlock.Create("GenXdev.Webbrowser\\Invoke-WebbrowserEvaluation $script");
                scriptBlock.InvokeWithContext(null, new List<PSVariable> { new PSVariable("script", script) });
            }
        }

        /// <summary>
        /// End processing - no cleanup needed
        /// </summary>
        protected override void EndProcessing()
        {
        }

        // Private field to store the prepared JavaScript script
        private string script;
    }
}