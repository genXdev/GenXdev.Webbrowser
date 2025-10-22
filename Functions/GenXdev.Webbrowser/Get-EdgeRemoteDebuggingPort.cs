// ################################################################################
// Part of PowerShell module : GenXdev.Webbrowser
// Original cmdlet filename  : Get-EdgeRemoteDebuggingPort.cs
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
using System.Management.Automation;

namespace GenXdev.Webbrowser
{
    /// <summary>
    /// <para type="synopsis">
    /// Returns the configured remote debugging port for Microsoft Edge browser.
    /// </para>
    ///
    /// <para type="description">
    /// Retrieves the remote debugging port number used for connecting to Microsoft Edge
    /// browser's debugging interface. If no custom port is configured via the global
    /// variable $Global:EdgeDebugPort, returns the default port 9223. The function
    /// validates any custom port configuration and falls back to the default if invalid.
    /// </para>
    ///
    /// <para type="description">
    /// OUTPUTS
    /// </para>
    ///
    /// <para type="description">
    /// System.Int32
    /// Returns the port number to use for Edge remote debugging
    /// </para>
    ///
    /// <example>
    /// <para>Get-EdgeRemoteDebuggingPort</para>
    /// <para>Returns the configured debug port (default 9223 if not configured)</para>
    /// <code>
    /// Get-EdgeRemoteDebuggingPort
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "EdgeRemoteDebuggingPort")]
    [OutputType(typeof(int))]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    public class GetEdgeRemoteDebuggingPortCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Starting Get-EdgeRemoteDebuggingPort");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // set default edge debugging port
            int port = 9223;

            // check if user has configured a custom port in global scope
            var edgeDebugPort = SessionState.PSVariable.GetValue("EdgeDebugPort");

            if (edgeDebugPort != null)
            {
                WriteVerbose("Found global EdgeDebugPort configuration");

                // attempt to parse the configured port value, keeping default if invalid
                if (int.TryParse(edgeDebugPort.ToString(), out int parsedPort))
                {
                    port = parsedPort;
                    WriteVerbose($"Using configured port: {port}");
                }
                else
                {
                    WriteVerbose($"Invalid port config, using default: {port}");
                }
            }
            else
            {
                WriteVerbose("No custom port configured, using default: {port}");
            }

            // ensure global variable matches returned port for consistency
            SessionState.PSVariable.Set("EdgeDebugPort", port);

            // return the resolved port number
            WriteObject(port);
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
            WriteVerbose("Completed Get-EdgeRemoteDebuggingPort");
        }
    }
}