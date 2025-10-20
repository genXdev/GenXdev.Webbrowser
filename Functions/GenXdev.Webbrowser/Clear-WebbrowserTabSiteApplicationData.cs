// ################################################################################
// Part of PowerShell module : GenXdev.Webbrowser
// Original cmdlet filename  : Clear-WebbrowserTabSiteApplicationData.cs
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



using System.Management.Automation;

namespace GenXdev.Webbrowser
{
    /// <summary>
    /// <para type="synopsis">
    /// Clears all browser storage data for the current tab in Edge or Chrome.
    /// </para>
    ///
    /// <para type="description">
    /// The Clear-WebbrowserTabSiteApplicationData cmdlet executes a JavaScript snippet
    /// that clears various types of browser storage for the current tab, including:
    /// - Local storage
    /// - Session storage
    /// - Cookies
    /// - IndexedDB databases
    /// - Cache storage
    /// - Service worker registrations
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -Edge &lt;SwitchParameter&gt;<br/>
    /// Specifies to clear data in Microsoft Edge browser.<br/>
    /// - <b>Position</b>: Named<br/>
    /// - <b>Default</b>: False<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Chrome &lt;SwitchParameter&gt;<br/>
    /// Specifies to clear data in Google Chrome browser.<br/>
    /// - <b>Position</b>: Named<br/>
    /// - <b>Default</b>: False<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Clears all browser storage data in the current Edge tab.</para>
    /// <code>
    /// Clear-WebbrowserTabSiteApplicationData -Edge
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Clears all browser storage data in the current Chrome tab using the alias.</para>
    /// <code>
    /// clearsitedata -Chrome
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Clear, "WebbrowserTabSiteApplicationData")]
    [Alias("clearsitedata")]
    [OutputType(typeof(void))]
    public class ClearWebbrowserTabSiteApplicationDataCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Specifies to clear data in Microsoft Edge browser.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Clear in Microsoft Edge")]
        public SwitchParameter Edge { get; set; }

        /// <summary>
        /// Specifies to clear data in Google Chrome browser.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Clear in Google Chrome")]
        public SwitchParameter Chrome { get; set; }

        private string locationJSScriptLet;

        /// <summary>
        /// Begin processing - prepare JavaScript code to clear browser storage
        /// </summary>
        protected override void BeginProcessing()
        {
            // Prepare JavaScript code to clear browser storage
            WriteVerbose("Preparing JavaScript code to clear browser storage");

            // JavaScript snippet that clears all browser storage types
            locationJSScriptLet = "javascript:(function(){localStorage.clear();sessionStorage.clear();document.cookie.split(\";\").forEach(function(c){document.cookie=c.replace(/^ +/,\"\").replace(/=.*/,\"=;expires=\"+new Date().toUTCString()+\";path=/\")});window.indexedDB.databases().then((dbs)=>{dbs.forEach((db)=>{indexedDB.deleteDatabase(db.name)})}).catch(() => {});if('caches' in window){caches.keys().then((names)=>{names.forEach(name=>{caches.delete(name)})}).catch(() => {})}if('serviceWorker' in navigator){navigator.serviceWorker.getRegistrations().then((registrations)=>{registrations.forEach((registration)=>{registration.unregister()})}).catch(() => {})}alert('All browser storage cleared!')})()";
        }

        /// <summary>
        /// Process record - execute clear storage script in browser tab
        /// </summary>
        protected override void ProcessRecord()
        {
            // Add URL parameter to execute JavaScript in browser
            WriteVerbose("Adding URL parameter to execute JavaScript in browser");

            // Execute the JavaScript in the browser tab using Set-WebbrowserTabLocation
            WriteVerbose("Executing clear storage script in browser tab");

            // Use ScriptBlock to call the PowerShell cmdlet with parameters
            var scriptBlock = ScriptBlock.Create("param($Edge, $Chrome, $Url) GenXdev.Webbrowser\\Set-WebbrowserTabLocation -Edge:$Edge -Chrome:$Chrome -Url $Url");
            scriptBlock.Invoke(Edge.ToBool(), Chrome.ToBool(), locationJSScriptLet);
        }

        /// <summary>
        /// End processing - no cleanup needed
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}