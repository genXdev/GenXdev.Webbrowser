// ################################################################################
// Part of PowerShell module : GenXdev.Webbrowser
// Original cmdlet filename  : Set-RemoteDebuggerPortInBrowserShortcuts.cs
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
using System.IO;
using System.Management.Automation;

namespace GenXdev.Webbrowser
{
    /// <summary>
    /// <para type="synopsis">
    /// Updates browser shortcuts to enable remote debugging ports.
    /// </para>
    ///
    /// <para type="description">
    /// Modifies Chrome and Edge browser shortcuts to include remote debugging
    /// port parameters. This enables automation scripts to interact with the
    /// browsers through their debugging interfaces. Handles both user-specific
    /// and system-wide shortcuts.
    /// </para>
    ///
    /// <para type="description">
    /// The function:<br/>
    /// - Removes any existing debugging port parameters<br/>
    /// - Adds current debugging ports for Chrome and Edge<br/>
    /// - Updates shortcuts in common locations (Desktop, Start Menu, Quick
    ///   Launch)<br/>
    /// - Requires administrative rights for system-wide shortcuts
    /// </para>
    ///
    /// <example>
    /// <para>Update all browser shortcuts with debugging ports</para>
    /// <para>
    /// This example updates all Chrome and Edge shortcuts with their
    /// respective debugging ports.
    /// </para>
    /// <code>
    /// Set-RemoteDebuggerPortInBrowserShortcuts
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Preview changes without applying them</para>
    /// <para>
    /// This example uses WhatIf to preview what changes would be made without
    /// actually modifying any shortcuts.
    /// </para>
    /// <code>
    /// Set-RemoteDebuggerPortInBrowserShortcuts -WhatIf
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Set, "RemoteDebuggerPortInBrowserShortcuts",
        SupportsShouldProcess = true)]
    public class SetRemoteDebuggerPortInBrowserShortcutsCommand :
        PSGenXdevCmdlet
    {
        private dynamic shell;

        /// <summary>
        /// Initialize the cmdlet by creating the WScript.Shell COM object for
        /// shortcut manipulation
        /// </summary>
        protected override void BeginProcessing()
        {

            // Create COM object for Windows Script Host shell automation
            var shellType = Type.GetTypeFromProgID("WScript.Shell");
            shell = Activator.CreateInstance(shellType);

            WriteVerbose(
                "Created WScript.Shell COM object for shortcut management"
            );
        }

        /// <summary>
        /// Process record - main cmdlet logic that updates browser shortcuts
        /// </summary>
        protected override void ProcessRecord()
        {

            // Configure Chrome debugging settings
            var chromePort = InvokeScript<int>(
                "GenXdev.Webbrowser\\Get-ChromeRemoteDebuggingPort"
            );

            var chromeParam = $" --remote-allow-origins=* " +
                $"--remote-debugging-port={chromePort}";

            WriteVerbose($"Configuring Chrome debugging port: {chromePort}");

            // Get environment variables for path construction
            var appData = Environment.GetEnvironmentVariable("AppData");
            var programData =
                Environment.GetEnvironmentVariable("ProgramData");

            // Get StartMenu and Desktop paths from Get-KnownFolderPath
            var getKnownFolderScript = ScriptBlock.Create(
                "param($folder) GenXdev.Windows\\Get-KnownFolderPath " +
                "-KnownFolder $folder"
            );

            var startMenuPath = getKnownFolderScript.Invoke("StartMenu")
                .Count > 0 ? getKnownFolderScript.Invoke("StartMenu")[0]
                .BaseObject.ToString() : null;

            var desktopPath = getKnownFolderScript.Invoke("Desktop")
                .Count > 0 ? getKnownFolderScript.Invoke("Desktop")[0]
                .BaseObject.ToString() : null;

            // Define Chrome shortcut paths to process
            var chromePaths = new[]
            {
                Path.Combine(appData, "Microsoft", "Internet Explorer",
                    "Quick Launch", "User Pinned", "TaskBar",
                    "Google Chrome.lnk"),
                Path.Combine(programData, "Microsoft", "Windows",
                    "Start Menu", "Programs", "Google Chrome.lnk"),
                startMenuPath != null ?
                    Path.Combine(startMenuPath, "Google Chrome.lnk") : null,
                desktopPath != null ?
                    Path.Combine(desktopPath, "Google Chrome.lnk") : null
            };

            // Update Chrome shortcuts
            foreach (var pathPattern in chromePaths)
            {

                if (string.IsNullOrEmpty(pathPattern)) continue;

                // Use Get-ChildItem to find shortcuts (handles recursion)
                var getItemScript = ScriptBlock.Create(
                    "param($path) Microsoft.PowerShell.Management\\" +
                    "Get-ChildItem -LiteralPath $path -File -Recurse " +
                    "-ErrorAction SilentlyContinue"
                );

                var items = getItemScript.Invoke(pathPattern);

                foreach (PSObject item in items)
                {

                    var fullName = item.Properties["FullName"]?.Value?
                        .ToString();

                    if (string.IsNullOrEmpty(fullName)) continue;

                    if (ShouldProcess(
                        fullName,
                        $"Update Chrome shortcut with debug port " +
                        $"{chromePort}"))
                    {

                        try
                        {

                            // Load the shortcut
                            dynamic shortcut =
                                shell.CreateShortcut(fullName);

                            // Get current arguments
                            string currentArgs = shortcut.Arguments ?? "";

                            // Remove '222' artifact from arguments
                            currentArgs = currentArgs.Replace("222", "");

                            // Remove previous port parameters
                            string cleanedArgs =
                                RemovePreviousPortParam(currentArgs);

                            // Add Chrome debugging parameters
                            shortcut.Arguments =
                                $"{cleanedArgs} {chromeParam}".Trim();

                            // Save the shortcut
                            shortcut.Save();

                            WriteVerbose(
                                $"Updated Chrome shortcut: {fullName}"
                            );
                        }
                        catch (Exception ex)
                        {

                            WriteVerbose(
                                $"Failed to update Chrome shortcut: " +
                                $"{fullName} - {ex.Message}"
                            );
                        }
                    }
                }
            }

            // Configure Edge debugging settings
            var edgePort = InvokeScript<int>(
                "GenXdev.Webbrowser\\Get-EdgeRemoteDebuggingPort"
            );

            var edgeParam = $" --remote-allow-origins=* " +
                $"--remote-debugging-port={edgePort}";

            WriteVerbose($"Configuring Edge debugging port: {edgePort}");

            // Define Edge shortcut paths to process
            var edgePaths = new[]
            {
                Path.Combine(appData, "Microsoft", "Internet Explorer",
                    "Quick Launch", "User Pinned", "TaskBar",
                    "Microsoft Edge.lnk"),
                Path.Combine(programData, "Microsoft", "Windows",
                    "Start Menu", "Programs", "Microsoft Edge.lnk"),
                startMenuPath != null ?
                    Path.Combine(startMenuPath, "Microsoft Edge.lnk") : null,
                desktopPath != null ?
                    Path.Combine(desktopPath, "Microsoft Edge.lnk") : null
            };

            // Update Edge shortcuts
            foreach (var pathPattern in edgePaths)
            {

                if (string.IsNullOrEmpty(pathPattern)) continue;

                // Use Get-ChildItem to find shortcuts (handles recursion)
                var getItemScript = ScriptBlock.Create(
                    "param($path) Microsoft.PowerShell.Management\\" +
                    "Get-ChildItem -LiteralPath $path -File -Recurse " +
                    "-ErrorAction SilentlyContinue"
                );

                var items = getItemScript.Invoke(pathPattern);

                foreach (PSObject item in items)
                {

                    var fullName = item.Properties["FullName"]?.Value?
                        .ToString();

                    if (string.IsNullOrEmpty(fullName)) continue;

                    if (ShouldProcess(
                        fullName,
                        $"Update Edge shortcut with debug port {edgePort}"))
                    {

                        try
                        {

                            // Load the shortcut
                            dynamic shortcut =
                                shell.CreateShortcut(fullName);

                            // Get current arguments and remove edge param
                            string currentArgs = shortcut.Arguments ?? "";
                            currentArgs = currentArgs.Replace(edgeParam, "")
                                .Trim();

                            // Remove previous port parameters
                            string cleanedArgs =
                                RemovePreviousPortParam(currentArgs);

                            // Add Edge debugging parameters
                            shortcut.Arguments =
                                $"{cleanedArgs}{edgeParam}";

                            // Save the shortcut
                            shortcut.Save();

                            WriteVerbose(
                                $"Updated Edge shortcut: {fullName}"
                            );
                        }
                        catch (Exception ex)
                        {

                            WriteVerbose(
                                $"Failed to update Edge shortcut: " +
                                $"{fullName} - {ex.Message}"
                            );
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
        }

        /// <summary>
        /// Sanitizes shortcut arguments by removing existing debugging port
        /// settings
        /// </summary>
        /// <param name="arguments">
        /// The current shortcut arguments string to clean
        /// </param>
        /// <returns>Cleaned arguments string</returns>
        private string RemovePreviousPortParam(string arguments)
        {

            // Initialize working copy of arguments
            string cleanedArgs = arguments ?? "";

            // Find first occurrence of port parameter
            int portParamIndex =
                cleanedArgs.IndexOf("--remote-debugging-port=");

            // Continue cleaning while port parameters exist
            while (portParamIndex >= 0)
            {

                if (ShouldProcess(
                    $"Removing debug port parameter at position " +
                    $"{portParamIndex}",
                    "Remove port parameter?",
                    "Cleaning shortcut arguments"))
                {

                    // Remove port parameter and preserve other arguments
                    cleanedArgs = cleanedArgs.Substring(0, portParamIndex)
                        .Trim() + " " + (portParamIndex + 25 <
                        cleanedArgs.Length ?
                        cleanedArgs.Substring(portParamIndex + 25) : "")
                        .Trim();

                    // Remove any remaining port number digits
                    while (cleanedArgs.Length > 0 &&
                        "012345679".IndexOf(cleanedArgs[0]) >= 0)
                    {

                        cleanedArgs = cleanedArgs.Length > 1 ?
                            cleanedArgs.Substring(1) : "";
                    }
                }

                // Check for additional port parameters
                portParamIndex =
                    cleanedArgs.IndexOf("--remote-debugging-port=");
            }

            return cleanedArgs;
        }
    }
}
