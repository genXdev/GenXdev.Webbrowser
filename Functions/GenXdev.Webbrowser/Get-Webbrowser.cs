// ################################################################################
// Part of PowerShell module : GenXdev.Webbrowser
// Original cmdlet filename  : Get-Webbrowser.cs
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
using System.Management.Automation;
using Microsoft.Win32;

namespace GenXdev.Webbrowser
{
    /// <summary>
    /// <para type="synopsis">
    /// Returns a collection of installed modern web browsers.
    /// </para>
    ///
    /// <para type="description">
    /// Discovers and returns details about modern web browsers installed on the
    /// system. Retrieves information including name, description, icon path,
    /// executable path and default browser status by querying the Windows
    /// registry. Only returns browsers that have the required capabilities
    /// registered in Windows.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -Edge &lt;SwitchParameter&gt;<br/>
    /// Selects Microsoft Edge browser instances<br/>
    /// - <b>Aliases</b>: e<br/>
    /// - <b>Position</b>: 0<br/>
    /// - <b>Default</b>: False<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Chrome &lt;SwitchParameter&gt;<br/>
    /// Selects Google Chrome browser instances<br/>
    /// - <b>Aliases</b>: ch<br/>
    /// - <b>Position</b>: 1<br/>
    /// - <b>Default</b>: False<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Chromium &lt;SwitchParameter&gt;<br/>
    /// Selects default chromium-based browser<br/>
    /// - <b>Aliases</b>: c<br/>
    /// - <b>Position</b>: 2<br/>
    /// - <b>Default</b>: False<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Firefox &lt;SwitchParameter&gt;<br/>
    /// Selects Firefox browser instances<br/>
    /// - <b>Aliases</b>: ff<br/>
    /// - <b>Position</b>: 3<br/>
    /// - <b>Default</b>: False<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Get all installed browsers</para>
    /// <para>Returns a collection of all installed modern web browsers.</para>
    /// <code>
    /// Get-Webbrowser | Select-Object Name, Description | Format-Table
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Get just the default browser</para>
    /// <para>Filters to show only the system default browser.</para>
    /// <code>
    /// Get-Webbrowser | Where-Object { $_.IsDefaultBrowser }
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "Webbrowser", DefaultParameterSetName = "Default")]
    [OutputType(typeof(Hashtable[]))]
    public class GetWebbrowserCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Selects Microsoft Edge browser instances
        /// </summary>
        [Alias("e")]
        [Parameter(
            Mandatory = false,
            Position = 0,
            ParameterSetName = "Specific",
            HelpMessage = "Selects Microsoft Edge browser instances")]
        public SwitchParameter Edge { get; set; }

        /// <summary>
        /// Selects Google Chrome browser instances
        /// </summary>
        [Alias("ch")]
        [Parameter(
            Mandatory = false,
            Position = 1,
            ParameterSetName = "Specific",
            HelpMessage = "Selects Google Chrome browser instances")]
        public SwitchParameter Chrome { get; set; }

        /// <summary>
        /// Selects default chromium-based browser
        /// </summary>
        [Alias("c")]
        [Parameter(
            Mandatory = false,
            Position = 2,
            ParameterSetName = "Specific",
            HelpMessage = "Selects default chromium-based browser")]
        public SwitchParameter Chromium { get; set; }

        /// <summary>
        /// Selects Firefox browser instances
        /// </summary>
        [Alias("ff")]
        [Parameter(
            Mandatory = false,
            Position = 3,
            ParameterSetName = "Specific",
            HelpMessage = "Selects Firefox browser instances")]
        public SwitchParameter Firefox { get; set; }

        private string urlHandlerId;

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {

            // Get the user's default handler for https URLs from registry settings
            WriteVerbose("Retrieving default browser URL handler ID from registry");

            try
            {
                using (var userChoiceKey = Registry.CurrentUser.OpenSubKey(
                    @"SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice"))
                {
                    urlHandlerId = userChoiceKey?.GetValue("ProgId")?.ToString();
                }
            }
            catch
            {
                // If we can't read the default browser setting, continue without it
                urlHandlerId = null;
            }
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {

            // Enumerate all browser entries in the Windows registry
            WriteVerbose("Enumerating installed browsers from registry");

            var browsers = new List<Hashtable>();

            try
            {
                using (var browsersKey = Registry.LocalMachine.OpenSubKey(
                    @"SOFTWARE\WOW6432Node\Clients\StartMenuInternet"))
                {
                    if (browsersKey != null)
                    {
                        foreach (string browserName in browsersKey.GetSubKeyNames())
                        {
                            var browserInfo = ProcessBrowserEntry(browserName);
                            if (browserInfo != null)
                            {
                                browsers.Add(browserInfo);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                WriteError(new ErrorRecord(
                    ex,
                    "RegistryAccessError",
                    ErrorCategory.ReadError,
                    "Registry"));
                return;
            }

            // Write each browser hashtable to the output stream
            foreach (var browser in browsers)
            {
                WriteObject(browser);
            }
        }

        /// <summary>
        /// Process a single browser registry entry
        /// </summary>
        /// <param name="browserName">The browser registry key name</param>
        /// <returns>Browser information hashtable or null if browser should be filtered</returns>
        private Hashtable ProcessBrowserEntry(string browserName)
        {

            var browserRoot = $@"SOFTWARE\WOW6432Node\Clients\StartMenuInternet\{browserName}";

            try
            {
                using (var browserKey = Registry.LocalMachine.OpenSubKey(browserRoot))
                {
                    if (browserKey == null) return null;

                    // Verify browser has required capabilities and command info
                    using (var commandKey = browserKey.OpenSubKey(@"shell\open\command"))
                    using (var capabilitiesKey = browserKey.OpenSubKey("Capabilities"))
                    {
                        if (commandKey == null || capabilitiesKey == null) return null;

                        // Get browser capabilities metadata from registry
                        var applicationName = capabilitiesKey.GetValue("ApplicationName")?.ToString();
                        var applicationDescription = capabilitiesKey.GetValue("ApplicationDescription")?.ToString();
                        var applicationIcon = capabilitiesKey.GetValue("ApplicationIcon")?.ToString();

                        // Extract the browser executable path, removing quotes
                        var browserPath = commandKey.GetValue("")?.ToString()?.Trim('"');

                        // Determine if this browser is set as the system default
                        bool isDefault = false;
                        try
                        {
                            using (var urlAssociationsKey = capabilitiesKey.OpenSubKey("URLAssociations"))
                            {
                                if (urlAssociationsKey != null)
                                {
                                    var httpsHandler = urlAssociationsKey.GetValue("https")?.ToString();
                                    isDefault = !string.IsNullOrEmpty(urlHandlerId) && httpsHandler == urlHandlerId;
                                }
                            }
                        }
                        catch
                        {
                            // If we can't read URL associations, assume not default
                            isDefault = false;
                        }

                        // Create browser info hashtable
                        var browserInfo = new Hashtable
                        {
                            ["Name"] = applicationName,
                            ["Description"] = applicationDescription,
                            ["Icon"] = applicationIcon,
                            ["Path"] = browserPath,
                            ["IsDefaultBrowser"] = isDefault
                        };

                        // Apply browser type filtering
                        if (ShouldIncludeBrowser(applicationName))
                        {
                            return browserInfo;
                        }
                    }
                }
            }
            catch
            {
                // Skip browsers that can't be read
                return null;
            }

            return null;
        }

        /// <summary>
        /// Determine if a browser should be included based on filtering parameters
        /// </summary>
        /// <param name="applicationName">The browser application name</param>
        /// <returns>True if the browser should be included in results</returns>
        private bool ShouldIncludeBrowser(string applicationName)
        {

            if (string.IsNullOrEmpty(applicationName)) return false;

            var isEdge = applicationName.IndexOf("Edge", StringComparison.OrdinalIgnoreCase) >= 0;
            var isChrome = applicationName.IndexOf("Chrome", StringComparison.OrdinalIgnoreCase) >= 0;
            var isFirefox = applicationName.IndexOf("Firefox", StringComparison.OrdinalIgnoreCase) >= 0;
            var isChromium = isEdge || isChrome;

            // If no specific browser is requested (Default parameter set), return all
            if (ParameterSetName == "Default") return true;

            // Filter results based on specific browser parameters
            return (Edge.ToBool() && isEdge) ||
                   (Chrome.ToBool() && isChrome) ||
                   (Chromium.ToBool() && isChromium) ||
                   (Firefox.ToBool() && isFirefox);
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}