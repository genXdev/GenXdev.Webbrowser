// ################################################################################
// Part of PowerShell module : GenXdev.Webbrowser
// Original cmdlet filename  : Get-DefaultWebbrowser.cs
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



using System.Collections;
using System.Management.Automation;
using Microsoft.Win32;

namespace GenXdev.Webbrowser
{
    /// <summary>
    /// <para type="synopsis">
    /// Returns the configured default web browser for the current user.
    /// </para>
    ///
    /// <para type="description">
    /// Retrieves information about the system's default web browser by querying the
    /// Windows Registry. Returns a hashtable containing the browser's name, description,
    /// icon path, and executable path. The function checks both user preferences and
    /// system-wide browser registrations to determine the default browser.
    /// </para>
    ///
    /// <example>
    /// <para>Get detailed information about the default browser</para>
    /// <para>Get-DefaultWebbrowser | Format-List</para>
    /// <code>
    /// Get-DefaultWebbrowser | Format-List
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Launch the default browser with a specific URL</para>
    /// <para>$browser = Get-DefaultWebbrowser; & $browser.Path https://www.github.com/</para>
    /// <code>
    /// $browser = Get-DefaultWebbrowser
    /// & $browser.Path https://www.github.com/
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "DefaultWebbrowser")]
    [OutputType(typeof(Hashtable))]
    public class GetDefaultWebbrowserCommand : PSGenXdevCmdlet
    {
        private string urlHandlerId;

        /// <summary>
        /// Begin processing - retrieve default browser URL handler configuration
        /// </summary>
        protected override void BeginProcessing()
        {
            // Define registry paths for url associations and browser information
            string urlAssocPath = @"SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice";

            WriteVerbose("Retrieving default browser URL handler configuration");

            // Get the default handler ID for HTTPS URLs from user preferences
            using (RegistryKey hkcu = RegistryKey.OpenBaseKey(RegistryHive.CurrentUser, RegistryView.Default))
            {
                using (RegistryKey urlAssocKey = hkcu.OpenSubKey(urlAssocPath))
                {
                    if (urlAssocKey != null)
                    {
                        urlHandlerId = urlAssocKey.GetValue("ProgId") as string;
                    }
                }
            }

            WriteVerbose($"URL handler ID: {urlHandlerId}");
        }

        /// <summary>
        /// Process record - scan installed browsers and return default browser info
        /// </summary>
        protected override void ProcessRecord()
        {
            if (string.IsNullOrEmpty(urlHandlerId))
            {
                return;
            }

            WriteVerbose("Scanning installed browsers in registry");

            // Iterate through all registered browsers in the system
            using (RegistryKey browsersKey = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\WOW6432Node\Clients\StartMenuInternet"))
            {
                if (browsersKey == null)
                {
                    return;
                }

                foreach (string browserName in browsersKey.GetSubKeyNames())
                {
                    using (RegistryKey browserRoot = browsersKey.OpenSubKey(browserName))
                    {
                        if (browserRoot == null)
                        {
                            continue;
                        }

                        // Construct the full registry path for the current browser
                        string browserRootPath = @"SOFTWARE\WOW6432Node\Clients\StartMenuInternet\" + browserName;

                        // Verify browser has required registry keys for URL handling
                        using (RegistryKey commandKey = browserRoot.OpenSubKey(@"shell\open\command"))
                        {
                            using (RegistryKey urlAssocKey = browserRoot.OpenSubKey(@"Capabilities\URLAssociations"))
                            {
                                if (commandKey == null || urlAssocKey == null)
                                {
                                    continue;
                                }

                                // Get the HTTPS handler ID for this browser
                                string browserHandler = urlAssocKey.GetValue("https") as string;

                                // Check if this browser is the default handler
                                if (browserHandler == urlHandlerId)
                                {
                                    WriteVerbose($"Found default browser: {browserRootPath}");

                                    // Get browser details
                                    using (RegistryKey capabilities = browserRoot.OpenSubKey("Capabilities"))
                                    {
                                        if (capabilities == null)
                                        {
                                            continue;
                                        }

                                        string name = capabilities.GetValue("ApplicationName") as string;
                                        string description = capabilities.GetValue("ApplicationDescription") as string;
                                        string icon = capabilities.GetValue("ApplicationIcon") as string;
                                        string path = (commandKey.GetValue(null) as string)?.Trim('"');

                                        // Return browser details in a hashtable
                                        Hashtable result = new Hashtable
                                        {
                                            ["Name"] = name,
                                            ["Description"] = description,
                                            ["Icon"] = icon,
                                            ["Path"] = path
                                        };

                                        WriteObject(result);
                                        return;
                                    }
                                }
                            }
                        }
                    }
                }
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