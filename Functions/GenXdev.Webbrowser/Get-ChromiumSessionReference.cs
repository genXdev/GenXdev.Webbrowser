// ################################################################################
// Part of PowerShell module : GenXdev.Webbrowser
// Original cmdlet filename  : Get-ChromiumSessionReference.cs
// Original author           : René Vaessen / GenXdev
// Version                   : 1.302.2025
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

namespace GenXdev.Webbrowser
{
    /// <summary>
    /// <para type="synopsis">
    /// Gets a serializable reference to the current browser tab session.
    /// </para>
    ///
    /// <para type="description">
    /// Returns a hashtable containing debugger URI, port, and session data for the
    /// current browser tab. This reference can be used with Select-WebbrowserTab
    /// -ByReference to reconnect to the same tab, especially useful in background jobs
    /// or across different PowerShell sessions.
    ///
    /// The function validates the existence of an active chrome session and ensures
    /// the browser controller is still running before returning the session reference.
    /// </para>
    ///
    /// <example>
    /// <para>Get a reference to the current chrome tab session</para>
    /// <para>$sessionRef = Get-ChromiumSessionReference</para>
    /// <code>
    /// Get-ChromiumSessionReference
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Store the reference and use it later to reconnect</para>
    /// <para>$ref = Get-ChromiumSessionReference</para>
    /// <para>Select-WebbrowserTab -ByReference $ref</para>
    /// <code>
    /// $ref = Get-ChromiumSessionReference
    /// Select-WebbrowserTab -ByReference $ref
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "ChromiumSessionReference")]
    [OutputType(typeof(PSObject))]
    public class GetChromiumSessionReferenceCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Begin processing - initialize global data storage if needed
        /// </summary>
        protected override void BeginProcessing()
        {
            // Verify if global data storage exists and create if it doesn't
            var dataIsHashtable = InvokeCommand.InvokeScript("$Global:Data -is [Hashtable]");
            bool isHashtable = dataIsHashtable != null && dataIsHashtable.Count > 0 && LanguagePrimitives.IsTrue(dataIsHashtable[0]);
            if (!isHashtable)
            {
                InvokeCommand.InvokeScript("$Global:Data = @{}");
            }
        }

        /// <summary>
        /// Process record - get the chromium session reference
        /// </summary>
        protected override void ProcessRecord()
        {
            // Check for active browser session
            WriteVerbose("Checking for active browser session");

            // Get the chrome session from global scope
            var chromeSessionResult = InvokeCommand.InvokeScript("$Global:chromeSession");

            // Ensure chrome session exists and is of correct type
            if (chromeSessionResult == null || chromeSessionResult.Count == 0 || chromeSessionResult[0] == null)
            {
                throw new Exception("No browser available with open debugging port, use -Force to restart");
            }

            var chromeSession = chromeSessionResult[0];

            WriteVerbose("Found active session");

            // Verify chrome controller is still active
            var chromeController = InvokeCommand.InvokeScript("$Global:chromeController");

            var isClosedResult = InvokeCommand.InvokeScript("$Global:chromeController.IsClosed");
            bool isClosed = isClosedResult != null && isClosedResult.Count > 0 && LanguagePrimitives.IsTrue(isClosedResult[0]);

            if (chromeController == null || isClosed)
            {
                throw new Exception("Browser session expired. Use Select-WebbrowserTab to select a new session.");
            }

            WriteVerbose("Session is still active");

            // Ensure session has data property and return reference
            var isDataHashtableResult = InvokeCommand.InvokeScript("$Global:chromeSession.data -is [hashtable]");
            bool isDataHashtable = isDataHashtableResult != null && isDataHashtableResult.Count > 0 && LanguagePrimitives.IsTrue(isDataHashtableResult[0]);
            if (!isDataHashtable)
            {
                InvokeCommand.InvokeScript("$Global:chromeSession | Add-Member -MemberType NoteProperty -Name 'data' -Value $Global:Data -Force");
            }

            WriteObject(chromeSession);
        }
    }
}