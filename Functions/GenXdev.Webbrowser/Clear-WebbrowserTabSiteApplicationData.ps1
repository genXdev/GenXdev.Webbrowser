################################################################################
<#
.SYNOPSIS
Clears the application data of a web browser tab.

.DESCRIPTION
The `Clear-WebbrowserTabSiteApplicationData` cmdlet clears the application data of a web browser tab.

These include:
    - localStorage
    - sessionStorage
    - cookies
    - indexedDB
    - caches
    - service workers
#>
function Clear-WebbrowserTabSiteApplicationData {

    [CmdletBinding()]
    [Alias("clearsitedata")]

    param (
        [Alias("e")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Clear in Microsoft Edge"
        )]
        [switch] $Edge,
        ###############################################################################

        [Alias("ch")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Clear in Google Chrome"
        )]
        [switch] $Chrome
    )

    [string] $LocationJSScriptLet = "`"javascript:(function()%7BlocalStorage.clear()%3BsessionStorage.clear()%3Bdocument.cookie.split(\`"%3B\`").forEach(function(c)%7Bdocument.cookie%3Dc.replace(%2F%5E %2B%2F%2C\`"\`").replace(%2F%3D.*%2F%2C\`"%3D%3Bexpires%3D\`"%2Bnew Date().toUTCString()%2B\`"%3Bpath%3D%2F\`")%7D)%3Bwindow.indexedDB.databases().then((dbs)%3D>%7Bdbs.forEach((db)%3D>%7BindexedDB.deleteDatabase(db.name)%7D)%7D)%3Bif('caches' in window)%7Bcaches.keys().then((names)%3D>%7Bnames.forEach(name%3D>%7Bcaches.delete(name)%7D)%7D)%7Dif('serviceWorker' in navigator)%7Bnavigator.serviceWorker.getRegistrations().then((registrations)%3D>%7Bregistrations.forEach((registration)%3D>%7Bregistration.unregister()%7D)%7D)%7Dalert('All browser storage cleared!')%7D)()`"" | ConvertFrom-Json

    Set-WebbrowserTabLocation -Url $LocationJSScriptLet -Edge:$Edge -Chrome:$Chrome
}
