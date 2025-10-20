// ################################################################################
// Part of PowerShell module : GenXdev.Webbrowser.Playwright
// Original cmdlet filename  : Unprotect-WebbrowserTab.cs
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

namespace GenXdev.Webbrowser.Playwright
{
    /// <summary>
    /// <para type="synopsis">
    /// Takes control of a selected web browser tab for interactive manipulation.
    /// </para>
    ///
    /// <para type="description">
    /// This function enables interactive control of a browser tab that was previously
    /// selected using Select-WebbrowserTab. It provides direct access to the Microsoft
    /// Playwright Page object's properties and methods, allowing for automated browser
    /// interaction.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -UseCurrent &lt;SwitchParameter&gt;<br/>
    /// When specified, uses the currently assigned browser tab instead of prompting to
    /// select a new one. This is useful for continuing work with the same tab.<br/>
    /// - <b>Aliases</b>: current<br/>
    /// - <b>Position</b>: 0<br/>
    /// - <b>Default</b>: False<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Force &lt;SwitchParameter&gt;<br/>
    /// Forces a browser restart by closing all tabs if no debugging server is detected.
    /// Use this when the browser connection is in an inconsistent state.<br/>
    /// - <b>Position</b>: 1<br/>
    /// - <b>Default</b>: False<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Example 1: Use current tab</para>
    /// <para>Demonstrates using the currently assigned browser tab.</para>
    /// <code>
    /// Unprotect-WebbrowserTab -UseCurrent
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Example 2: Force browser restart</para>
    /// <para>Demonstrates forcing a browser restart if needed.</para>
    /// <code>
    /// wbctrl -Force
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsSecurity.Unprotect, "WebbrowserTab")]
    [OutputType(typeof(void))]
    public class UnprotectWebbrowserTabCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// When specified, uses the currently assigned browser tab instead of prompting to
        /// select a new one. This is useful for continuing work with the same tab.
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 0,
            ParameterSetName = "Default",
            HelpMessage = "Use current tab instead of selecting a new one")]
        [Alias("current")]
        public SwitchParameter UseCurrent { get; set; }

        /// <summary>
        /// Forces a browser restart by closing all tabs if no debugging server is detected.
        /// Use this when the browser connection is in an inconsistent state.
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 1,
            ParameterSetName = "Default",
            HelpMessage = "Restart browser if no debugging server detected")]
        public SwitchParameter Force { get; set; }

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            // Initialize browser tab control sequence
            WriteVerbose("Initializing browser tab control sequence...");

            // Get reference to powershell window for manipulation
            var getPwshWScript = ScriptBlock.Create(@"
                GenXdev.Windows\Get-PowershellMainWindow
            ");
            var pwshWResult = getPwshWScript.Invoke();
            // Store in session state for use in ProcessRecord
            SessionState.PSVariable.Set("pwshW", pwshWResult[0]);
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            var useCurrent = UseCurrent.ToBool();
            var force = Force.ToBool();

            if (!useCurrent)
            {
                // Clear host
                var clearHostScript = ScriptBlock.Create("Clear-Host");
                clearHostScript.Invoke();

                // Write host message
                WriteVerbose("Prompting user to select a browser tab...");
                var writeHostScript = ScriptBlock.Create(@"
                    Microsoft.PowerShell.Utility\Write-Host 'Select to which browser tab you want to send commands to'
                ");
                writeHostScript.Invoke();

                // Attempt to get list of available browser tabs
                var selectTabScript = ScriptBlock.Create(string.Format(@"
                    param($force)
                    GenXdev.Webbrowser\Select-WebbrowserTab -Force:$force
                ", force ? "$true" : "$false"));
                selectTabScript.Invoke(force);

                // Check if ChromeSessions is empty
                var checkSessionsScript = ScriptBlock.Create(@"
                    if ($Global:ChromeSessions.Length -eq 0) {
                        Microsoft.PowerShell.Utility\Write-Host 'No browser tabs are open'
                        return $true
                    }
                    return $false
                ");
                var noTabsResult = checkSessionsScript.Invoke();
                if (((PSObject)noTabsResult[0]).BaseObject as bool? == true)
                {
                    return;
                }

                // Get valid tab selection from user
                int tabNumber = 0;
                bool validSelection = false;
                while (!validSelection)
                {
                    var readHostScript = ScriptBlock.Create(@"
                        Microsoft.PowerShell.Utility\Read-Host 'Enter the number of the tab you want to control'
                    ");
                    var tabInputResult = readHostScript.Invoke();
                    var tabInput = ((PSObject)tabInputResult[0]).BaseObject.ToString();
                    if (!int.TryParse(tabInput, out tabNumber))
                    {
                        var writeInvalidScript = ScriptBlock.Create(@"
                            Microsoft.PowerShell.Utility\Write-Host 'Invalid tab number. Please enter a valid number'
                        ");
                        writeInvalidScript.Invoke();
                        continue;
                    }

                    // Get tab count
                    var getTabCountScript = ScriptBlock.Create(@"
                        $Global:ChromeSessions.Length
                    ");
                    var tabCountResult = getTabCountScript.Invoke();
                    var tabCount = (int)((PSObject)tabCountResult[0]).BaseObject;

                    if (tabNumber < 0 || tabNumber > tabCount - 1)
                    {
                        var writeRangeScript = ScriptBlock.Create(string.Format(@"
                            Microsoft.PowerShell.Utility\Write-Host ('Invalid tab number. Please enter a number between 0 and {0}')
                        ", tabCount - 1));
                        writeRangeScript.Invoke();
                        continue;
                    }
                    validSelection = true;
                }

                // Activate the selected browser tab
                var activateTabScript = ScriptBlock.Create(string.Format(@"
                    param($tabNumber)
                    GenXdev.Webbrowser\Select-WebbrowserTab $tabNumber
                ", tabNumber));
                activateTabScript.Invoke(tabNumber);
            }

            // Check if chromeController exists
            var checkControllerScript = ScriptBlock.Create(@"
                if (-not $Global:chromeController) {
                    Microsoft.PowerShell.Utility\Write-Host 'No ChromeController object found'
                    return $true
                }
                return $false
            ");
            var noControllerResult = checkControllerScript.Invoke();
            if (((PSObject)noControllerResult[0]).BaseObject as bool? == true)
            {
                return;
            }

            // Try to maximize the powershell window
            try
            {
                var maximizeScript = ScriptBlock.Create(@"
                    $pwshW = GenXdev.Windows\Get-PowerShellMainWindow
                    $pwshW.Maximize()
                ");
                maximizeScript.Invoke();
            }
            catch (Exception e)
            {
                WriteVerbose("Failed to maximize PowerShell window: " + e.Message);
            }

            // Create background job for keyboard input
            var startJobScript = ScriptBlock.Create(@"
                Microsoft.PowerShell.Core\Start-Job {
                    # Send keyboard sequence to expose chrome controller object
                    GenXdev.Windows\Send-Key `
                        '{ESCAPE}', 'Clear-Host', '{ENTER}', '`$ChromeController', '.',
                    '^( )', 'y' `
                        -SendKeyDelayMilliSeconds 500 `
                        -WindowHandle ((GenXdev.Windows\Get-PowershellMainWindow).Handle)

                    # Allow time for commands to complete
                    Microsoft.PowerShell.Utility\Start-Sleep 3
                }
            ");
            startJobScript.Invoke();

            // Try to bring powershell window to front
            try
            {
                var focusScript = ScriptBlock.Create(@"
                    GenXdev.Windows\Get-PowershellMainWindow | Microsoft.PowerShell.Core\ForEach-Object {
                        GenXdev.Windows\Set-ForegroundWindow $_.handle
                    }
                ");
                focusScript.Invoke();
            }
            catch (Exception e)
            {
                WriteVerbose("Failed to set PowerShell window focus: " + e.Message);
            }
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
            // Empty as in original
        }
    }
}