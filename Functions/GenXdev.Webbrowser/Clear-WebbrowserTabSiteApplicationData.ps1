<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser
Original cmdlet filename  : Clear-WebbrowserTabSiteApplicationData.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.278.2025
################################################################################
MIT License

Copyright 2021-2025 GenXdev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
################################################################################>
###############################################################################
<#
.SYNOPSIS
Clears all browser storage data for the current tab in Edge or Chrome.

.DESCRIPTION
The Clear-WebbrowserTabSiteApplicationData cmdlet executes a JavaScript snippet
that clears various types of browser storage for the current tab, including:
- Local storage
- Session storage
- Cookies
- IndexedDB databases
- Cache storage
- Service worker registrations

.PARAMETER Edge
Specifies to clear data in Microsoft Edge browser.

.PARAMETER Chrome
Specifies to clear data in Google Chrome browser.

.EXAMPLE
Clear-WebbrowserTabSiteApplicationData -Edge
Clears all browser storage data in the current Edge tab.

.EXAMPLE
clearsitedata -Chrome
Clears all browser storage data in the current Chrome tab using the alias.
###############################################################################>
function Clear-WebbrowserTabSiteApplicationData {

    [CmdletBinding()]
    [Alias('clearsitedata')]

    param (
        ###############################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Clear in Microsoft Edge'
        )]
        [switch] $Edge,
        ###############################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = 'Clear in Google Chrome'
        )]
        [switch] $Chrome
    )

    begin {
        Microsoft.PowerShell.Utility\Write-Verbose 'Preparing JavaScript code to clear browser storage'

        # javascript snippet that clears all browser storage types
        [string] $LocationJSScriptLet = ("`"javascript:(function()%7BlocalStorage." +
            "clear()%3BsessionStorage.clear()%3Bdocument.cookie.split(\`"%3B\`")." +
            "forEach(function(c)%7Bdocument.cookie%3Dc.replace(%2F%5E %2B%2F%2C\`"\`")" +
            ".replace(%2F%3D.*%2F%2C\`"%3D%3Bexpires%3D\`"%2Bnew Date().toUTCString()" +
            "%2B\`"%3Bpath%3D%2F\`")%7D)%3Bwindow.indexedDB.databases().then((dbs)" +
            '%3D>%7Bdbs.forEach((db)%3D>%7BindexedDB.deleteDatabase(db.name)%7D)%7D)' +
            "%3Bif('caches' in window)%7Bcaches.keys().then((names)%3D>%7Bnames." +
            "forEach(name%3D>%7Bcaches.delete(name)%7D)%7D)%7Dif('serviceWorker' in " +
            'navigator)%7Bnavigator.serviceWorker.getRegistrations().then(' +
            '(registrations)%3D>%7Bregistrations.forEach((registration)%3D>%7B' +
            "registration.unregister()%7D)%7D)%7Dalert('All browser storage " +
            "cleared!')%7D)()`"") | Microsoft.PowerShell.Utility\ConvertFrom-Json
    }


    process {

        Microsoft.PowerShell.Utility\Write-Verbose 'Adding URL parameter to execute JavaScript in browser'

        # add the javascript url to the parameters for Set-WebbrowserTabLocation
        $null = $PSBoundParameters.Add('Url', $LocationJSScriptLet)

        Microsoft.PowerShell.Utility\Write-Verbose 'Executing clear storage script in browser tab'

        # execute the javascript in the browser tab
        GenXdev.Webbrowser\Set-WebbrowserTabLocation @PSBoundParameters
    }

    end {
    }
}