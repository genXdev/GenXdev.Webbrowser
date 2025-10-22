// ################################################################################
// Part of PowerShell module : GenXdev.Webbrowser
// Original cmdlet filename  : Get-ChromeRemoteDebuggingPort.cs
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
    /// Returns the configured remote debugging port for Google Chrome.
    /// </para>
    ///
    /// <para type="description">
    /// Retrieves and manages the remote debugging port configuration for Google Chrome.
    /// The cmdlet first checks for a custom port number stored in $Global:ChromeDebugPort.
    /// If not found or invalid, it defaults to port 9222. The port number is then stored
    /// globally for use by other Chrome automation functions.
    /// </para>
    ///
    /// <para type="description">
    /// OUTPUTS
    /// </para>
    ///
    /// <para type="description">
    /// System.Int32<br/>
    /// Returns the configured Chrome debugging port number.
    /// </para>
    ///
    /// <example>
    /// <para>Get the Chrome debugging port</para>
    /// <para>This example retrieves the current Chrome debugging port configuration.</para>
    /// <code>
    /// $port = Get-ChromeRemoteDebuggingPort
    /// Write-Host "Chrome debug port: $port"
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Get the Chrome debugging port using alias</para>
    /// <para>This example demonstrates using the cmdlet alias to get the port.</para>
    /// <code>
    /// $port = Get-ChromePort
    /// Write-Host "Chrome debug port: $port"
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "ChromeRemoteDebuggingPort")]
    [OutputType(typeof(System.Int32))]
    public class GetChromeRemoteDebuggingPortCommand : PSGenXdevCmdlet
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
            // Initialize the default chrome debugging port
            int port = 9222;

            // Get the current value of the global ChromeDebugPort variable
            var globalPortResult = InvokeCommand.InvokeScript("$Global:ChromeDebugPort");

            // Check if a custom port is configured in the global scope
            if (globalPortResult != null && globalPortResult.Count > 0)
            {
                var globalPortValue = globalPortResult[0]?.ToString();

                // Attempt to parse the global port value
                if (int.TryParse(globalPortValue, out int parsedPort))
                {
                    port = parsedPort;
                    WriteVerbose($"Using configured Chrome debug port: {port}");
                }
                else
                {
                    WriteVerbose($"Invalid port config, using default port: {port}");
                }
            }
            else
            {
                WriteVerbose($"No custom port configured, using default port: {port}");
            }

            // Ensure the port is available in global scope
            InvokeCommand.InvokeScript($"$Global:ChromeDebugPort = {port}");

            // Output the port
            WriteObject(port);
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}