// ################################################################################
// Part of PowerShell module : GenXdev.Webbrowser
// Original cmdlet filename  : Approve-FirefoxDebugging.cs
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
using System.IO;
using System.Linq;
using System.Management.Automation;

namespace GenXdev.Webbrowser
{
    /// <summary>
    /// <para type="synopsis">
    /// Configures Firefox's debugging and standalone app mode features.
    /// </para>
    ///
    /// <para type="description">
    /// Enables remote debugging and standalone app mode (SSB) capabilities in Firefox by
    /// modifying user preferences in the prefs.js file of all Firefox profile
    /// directories. This cmdlet updates or adds required debugging preferences to
    /// enable development tools and remote debugging while disabling connection prompts.
    /// </para>
    ///
    /// <example>
    /// <para>Enables remote debugging and SSB features across all Firefox profiles found in the current user's AppData directory.</para>
    /// <code>
    /// Approve-FirefoxDebugging
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsLifecycle.Approve, "FirefoxDebugging")]
    [OutputType(typeof(void))]
    public class ApproveFirefoxDebuggingCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Construct the path to firefox profiles using environment variables
            string profilesPath = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
                "Mozilla",
                "Firefox",
                "Profiles");

            WriteVerbose($"Searching for Firefox profiles in: {profilesPath}");

            // Define new preferences to be added to firefox configuration
            string[] newPrefs = new string[]
            {
                "user_pref(\"devtools.chrome.enabled\", true);",
                "user_pref(\"devtools.debugger.remote-enabled\", true);",
                "user_pref(\"devtools.debugger.prompt-connection\", false);",
                "user_pref(\"browser.ssb.enabled\", true);"
            };

            // Define preference keys that need to be removed before adding new ones
            string[] prefsToFilter = new string[]
            {
                "\"browser.ssb.enabled\"",
                "\"devtools.chrome.enabled\"",
                "\"devtools.debugger.remote-enabled\"",
                "\"devtools.debugger.prompt-connection\""
            };

            try
            {
                // Locate all firefox preference files recursively
                string[] prefFiles = Directory.GetFiles(
                    profilesPath,
                    "prefs.js",
                    SearchOption.AllDirectories);

                foreach (string prefFile in prefFiles)
                {
                    WriteVerbose($"Processing preferences file: {prefFile}");

                    // Safely read existing preferences using system io
                    string[] prefLines = File.ReadAllLines(prefFile);

                    // Filter out existing debug/app-mode preferences
                    string[] filteredLines = prefLines
                        .Where(line => !prefsToFilter.Any(pref => line.Contains(pref)))
                        .ToArray();

                    // Append new preferences to the filtered configuration
                    string[] updatedLines = filteredLines.Concat(newPrefs).ToArray();

                    // Safely write updated preferences back to file
                    File.WriteAllLines(prefFile, updatedLines);

                    WriteVerbose($"Successfully updated preferences in: {prefFile}");
                }
            }
            catch (Exception ex)
            {
                WriteError(new ErrorRecord(
                    ex,
                    "FailedToUpdateFirefoxPreferences",
                    ErrorCategory.InvalidOperation,
                    null));

                throw;
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