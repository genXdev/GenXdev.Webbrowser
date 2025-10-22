// ################################################################################
// Part of PowerShell module : GenXdev.Webbrowser.Playwright
// Original cmdlet filename  : Connect-PlaywrightViaDebuggingPort.cs
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
using System.Collections;
using System.Management.Automation;


namespace GenXdev.Webbrowser.Playwright
{
    /// <summary>
    /// <para type="synopsis">
    /// Connects to an existing browser instance via debugging port.
    /// </para>
    ///
    /// <para type="description">
    /// Establishes a connection to a running Chromium-based browser instance using the
    /// WebSocket debugger URL. Creates a Playwright instance and connects over CDP
    /// (Chrome DevTools Protocol). The connected browser instance is stored in a global
    /// dictionary for later reference. Automatically handles consent for
    /// Microsoft.Playwright NuGet package installation.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -WsEndpoint &lt;string&gt;<br/>
    /// The WebSocket URL for connecting to the browser's debugging port. This URL
    /// typically follows the format 'ws://hostname:port/devtools/browser/&lt;id&gt;'.<br/>
    /// - <b>Position</b>: 0<br/>
    /// - <b>Mandatory</b>: true<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -ForceConsent &lt;SwitchParameter&gt;<br/>
    /// Force consent for third-party software installation without prompting.<br/>
    /// - <b>Mandatory</b>: false<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -ConsentToThirdPartySoftwareInstallation &lt;SwitchParameter&gt;<br/>
    /// Provide consent to third-party software installation.<br/>
    /// - <b>Mandatory</b>: false<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Connect to a browser instance via debugging port</para>
    /// <para>This example connects to a Chromium browser running with remote debugging enabled on port 9222.</para>
    /// <code>
    /// Connect-PlaywrightViaDebuggingPort `
    ///     -WsEndpoint "ws://localhost:9222/devtools/browser/abc123"
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Connect with consent for third-party software installation</para>
    /// <para>This example connects to a browser and provides consent for installing the Microsoft.Playwright package.</para>
    /// <code>
    /// Connect-PlaywrightViaDebuggingPort `
    ///     -WsEndpoint "ws://localhost:9222/devtools/browser/abc123" `
    ///     -ConsentToThirdPartySoftwareInstallation
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommunications.Connect, "PlaywrightViaDebuggingPort")]
    [OutputType(typeof(PSObject))]
    public class ConnectPlaywrightViaDebuggingPortCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The WebSocket URL for connecting to the browser's debugging port
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "WebSocket URL for browser debugging connection"
        )]
        [ValidateNotNullOrEmpty]
        public string WsEndpoint { get; set; }

        /// <summary>
        /// Force consent for third-party software installation
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Force consent for third-party software installation"
        )]
        public SwitchParameter ForceConsent { get; set; }

        /// <summary>
        /// Consent to third-party software installation
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Consent to third-party software installation"
        )]
        public SwitchParameter ConsentToThirdPartySoftwareInstallation { get; set; }

        /// <summary>
        /// Begin processing - initialize Playwright package and global dictionary
        /// </summary>
        protected override void BeginProcessing()
        {
            // Prepare parameters for EnsureNuGetAssembly
            var boundParams = new Hashtable();
            boundParams.Add("ForceConsent", ForceConsent);
            boundParams.Add("ConsentToThirdPartySoftwareInstallation", ConsentToThirdPartySoftwareInstallation);

            // Use base method to copy identical parameters
            var paramsResult = CopyIdenticalParamValues("GenXdev.Helpers\\EnsureNuGetAssembly");

            var ensureScript =
                "param($params) " +
                "GenXdev.Helpers\\EnsureNuGetAssembly -PackageKey 'Microsoft.Playwright' -Description 'Browser automation library required for connecting to browser instances via CDP' -Publisher 'Microsoft' @params";
            InvokeCommand.InvokeScript(ensureScript, false, 1, null, new object[] { paramsResult });

            // Initialize global browser dictionary if it doesn't exist (PowerShell side)
            var initScript =
                "if (-not $Global:GenXdevPlaywrightBrowserDictionary) { $Global:GenXdevPlaywrightBrowserDictionary = @{} }";
            InvokeCommand.InvokeScript(initScript, false, 1, null, null);
        }

        /// <summary>
        /// Process record - connect to browser and store instance
        /// </summary>
        protected override void ProcessRecord()
        {
            try
            {
                // Log connection attempt
                WriteVerbose("Attempting to connect to browser at: " + WsEndpoint);

                // Use PowerShell to create Playwright instance, connect, and store in global dictionary
                var connectScript =
                    "param($wsEndpoint) " +
                    "Microsoft.PowerShell.Utility\\Write-Verbose 'Creating Playwright instance'; " +
                    "$playwright = [Microsoft.Playwright.Playwright]::CreateAsync().Result; " +
                    "Microsoft.PowerShell.Utility\\Write-Verbose 'Connecting to browser via CDP'; " +
                    "$browser = $playwright.Chromium.ConnectOverCDPAsync($wsEndpoint).Result; " +
                    "Microsoft.PowerShell.Utility\\Write-Verbose 'Storing browser instance in global dictionary'; " +
                    "$Global:GenXdevPlaywrightBrowserDictionary[$wsEndpoint] = $browser; " +
                    "$browser";
                var result = InvokeCommand.InvokeScript(connectScript, false, 1, null, new object[] { WsEndpoint });

                // Return the browser instance as PSObject
                if (result != null && result.Count > 0)
                {
                    WriteObject(result[0]);
                }
            }
            catch (Exception ex)
            {
                // Write error and re-throw to maintain original behavior
                WriteError(new ErrorRecord(ex, "ConnectionFailed", ErrorCategory.ConnectionError, WsEndpoint));
                throw;
            }
        }
    }
}