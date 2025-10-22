// ################################################################################
// Part of PowerShell module : GenXdev.Webbrowser.Playwright
// Original cmdlet filename  : Get-PlaywrightProfileDirectory.cs
// Original author           : René Vaessen / GenXdev
// Version                   : 1.308.2025
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
using System.IO;
using System.Management.Automation;

namespace GenXdev.Webbrowser.Playwright
{
    /// <summary>
    /// <para type="synopsis">
    /// Gets the Playwright browser profile directory for persistent sessions.
    /// </para>
    ///
    /// <para type="description">
    /// Creates and manages browser profile directories for Playwright automated testing.
    /// Profiles are stored in LocalAppData under GenXdev.Powershell/Playwright.profiles.
    /// These profiles enable persistent sessions across browser automation runs.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -BrowserType &lt;string&gt;<br/>
    /// Specifies the browser type to create/get a profile directory for. Can be Chromium, Firefox, or Webkit. Defaults to Chromium if not specified.<br/>
    /// - <b>Position</b>: 0<br/>
    /// - <b>Default</b>: "Chromium"<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Get Playwright profile directory for Chromium</para>
    /// <para>Creates or returns path: %LocalAppData%\GenXdev.Powershell\Playwright.profiles\Chromium</para>
    /// <code>
    /// Get-PlaywrightProfileDirectory -BrowserType Chromium
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Get Playwright profile directory for Firefox using positional parameter</para>
    /// <para>Creates or returns Firefox profile directory using positional parameter.</para>
    /// <code>
    /// Get-PlaywrightProfileDirectory Firefox
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "PlaywrightProfileDirectory")]
    [OutputType(typeof(string))]
    public class GetPlaywrightProfileDirectoryCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Specifies the browser type to create/get a profile directory for
        /// </summary>
        [Parameter(
            Position = 0,
            HelpMessage = "The browser type (Chromium, Firefox, or Webkit)")]
        [ValidateSet("Chromium", "Firefox", "Webkit")]
        public string BrowserType { get; set; } = "Chromium";

        private string baseDir;

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            // Construct the base directory path for all browser profiles
            baseDir = Path.Combine(GetGenXdevAppDataPath(), "Playwright.profiles");

            WriteVerbose($"Base profile directory: {baseDir}");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Generate the specific browser profile directory path
            string browserDir = ExpandPath(Path.Combine(baseDir, BrowserType)+"\\", CreateDirectory: true);

            WriteVerbose($"Browser profile directory: {browserDir}");

            // Return the full profile directory path
            WriteObject(browserDir);
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