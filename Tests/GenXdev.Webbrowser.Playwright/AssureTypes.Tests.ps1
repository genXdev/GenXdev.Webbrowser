# ################################################################################
# Describe "AssureTypes" {

#     It "should pass PSScriptAnalyzer rules" {

#         # get the script path for analysis
#         $scriptPath = GenXdev.FileSystem\Expand-Path "$PSScriptRoot\..\..\Functions\GenXdev.Webbrowser.Playwright\AssureTypes.ps1"

#         # run analyzer with explicit settings
#         $analyzerResults = GenXdev.Coding\Invoke-GenXdevScriptAnalyzer `
#             -Path $scriptPath

#         [string] $message = ""
#         $analyzerResults | ForEach-Object {

#             $message = $message + @"
# --------------------------------------------------
# Rule: $($_.RuleName)`
# Description: $($_.Description)
# Message: $($_.Message)
# `r`n
# "@
#         }

#         $analyzerResults.Count | Should -Be 0 -Because @"
# The following PSScriptAnalyzer rules are being violated:
# $message
# "@;
#     }
# }
# ################################################################################
