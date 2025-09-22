<hr/>

<img src="powershell.jpg" alt="GenXdev" width="50%"/>

<hr/>

### NAME

    GenXdev.Webbrowser

### SYNOPSIS
    A Windows PowerShell module that allows you to run scripts against your casual desktop webbrowser-tab

[![GenXdev.Webbrowser](https://img.shields.io/powershellgallery/v/GenXdev.Webbrowser.svg?style=flat-square&label=GenXdev.Webbrowser)](https://www.powershellgallery.com/packages/GenXdev.Webbrowser/) [![License](https://img.shields.io/github/license/genXdev/GenXdev.Webbrowser?style=flat-square)](./LICENSE)

## MIT License

````text
MIT License

Copyright (c) 2025 GenXdev

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
````

### FEATURES

    * ✅ full controll of the webbrowser with the 'wbctrl' cmdlet
    * ✅ retreiving and manipulating of webbrowser-tab DOM nodes
          with 'wl' cmdlet
    * ✅ evaluating javascript-strings, javascript-files in opened
          webbrowser-tab
    * ✅ adding html script tags, by url, to opened webbrowser-tabs,
          for normal javascript files or modules
    * ✅ evaluating scripts, with support for async patterns, like promises
    * ✅ evaluating asynchronous scripts, with support for yielded PowerShell
          pipeline returns
    * ✅ exporting of favourites/bookmarks from Microsoft Edge, Google Chrome
          or Firefox
    * ✅ launching of default browser, Microsoft Edge, Google Chrome or Firefox
    * ✅ launching of webbrowser with full control of window positioning
    * ✅ launching of webbrowser with a large set of options

### NOTES

    In your PowerShell profile script,
    you can set a global variable named DefaultSecondaryMonitor.
    This allows you to setup your prefered webbrowser launch monitor.

    e.g.

       # Disable default placement of browser window
       Set-Variable -Name DefaultSecondaryMonitor -Value -1 -Scope Global

       # Place browser windows by default on 3th monitor (0 = Primary monitor, 1 = first, 2 = second,  etc)
       Set-Variable -Name DefaultSecondaryMonitor -Value 3 -Scope Global

### EXAMPLE
```PowerShell
-------------------------- EXAMPLE 1 --------------------------
PS C:\> Invoke-WebbrowserEvaluation "document.title = 'hello world'"

-------------------------- EXAMPLE 2 --------------------------
PS C:\>
    # Synchronizing data
    Select-WebbrowserTab;
    $Global:Data = @{ files= (Get-ChildItem *.* -file | % FullName)};

    [int] $number = Invoke-WebbrowserEvaluation "

        document.body.innerHTML = JSON.stringify(data.files);
        data.title = document.title;
        return 123;
    ";

    Write-Host "
        Document title : $($Global:Data.title)
        return value   : $Number
    ";

-------------------------- EXAMPLE 3 --------------------------
PS C:\>
    # Support for promises
    Select-WebbrowserTab;
    Invoke-WebbrowserEvaluation "
        let myList = [];
        return new Promise((resolve) => {
            let i = 0;
            let a = setInterval(() => {
                myList.push(++i);
                if (i == 10) {
                    clearInterval(a);
                    resolve(myList);
                }
            }, 1000);
        });
    "
-------------------------- EXAMPLE 4 --------------------------
PS C:\>

# Support for promises and more

# this function returns all rows of all tables/datastores of all databases of indexedDb in the selected tab
# beware, not all websites use indexedDb, it could return an empty set

Select-WebbrowserTab;
Set-WebbrowserTabLocation "https://www.youtube.com/"
Start-Sleep 3
$AllIndexedDbData = Invoke-WebbrowserEvaluation "
    // enumerate all indexedDB databases
    for (let db of await indexedDB.databases()) {

        // request to open database
        let openRequest = await indexedDB.open(db.name);

        // wait for eventhandlers to be called
        await new Promise((resolve,reject) => {
            openRequest.onsuccess = resolve;
            openRequest.onerror = reject
        });

        // obtain reference
        let openedDb = openRequest.result;

        // initialize result
        let result = { DatabaseName: db.name, Version: db.version, Stores: [] }

        // itterate object store names
        for (let i = 0; i < openedDb.objectStoreNames.length; i++) {

            // reference
            let storeName = openedDb.objectStoreNames[i];

            // start readonly transaction
            let tr = openedDb.transaction(storeName);

            // get objectstore handle
            let store = tr.objectStore(storeName);

            // request all data
            let getRequest = store.getAll();

            // await result
            await new Promise((resolve,reject) => {
                getRequest.onsuccess = resolve;
                getRequest.onerror = reject;
            });

            // add result
            result.Stores.push({ StoreName: storeName, Data: getRequest.result});
        }

        // stream this database contents to the PowerShell pipeline, and continue
        yield result;
    }
";

$AllIndexedDbData | Out-Host

-------------------------- EXAMPLE 5 --------------------------

PS C:\>
    # Support for yielded pipeline results
    Select-WebbrowserTab;
    Invoke-WebbrowserEvaluation "

        for (let i = 0; i < 10; i++) {

            await (new Promise((resolve) => setTimeout(resolve, 1000)));

            yield i;
        }
    ";

-------------------------- EXAMPLE 6 --------------------------

PS C:\> Get-ChildItem *.js | Invoke-WebbrowserEvaluation -Edge

-------------------------- EXAMPLE 7 --------------------------

PS C:\> ls *.js | et -e
```
### DEPENDENCIES
[![WinOS - Windows-10 or later](https://img.shields.io/badge/WinOS-Windows--10--10.0.19041--SP0-brightgreen)](https://www.microsoft.com/en-us/windows/get-windows-10)  [![GenXdev.Data](https://img.shields.io/powershellgallery/v/GenXdev.Data.svg?style=flat-square&label=GenXdev.Data)](https://www.powershellgallery.com/packages/GenXdev.Data/) [![GenXdev.Helpers](https://img.shields.io/powershellgallery/v/GenXdev.Helpers.svg?style=flat-square&label=GenXdev.Helpers)](https://www.powershellgallery.com/packages/GenXdev.Helpers/) [![GenXdev.FileSystem](https://img.shields.io/powershellgallery/v/GenXdev.FileSystem.svg?style=flat-square&label=GenXdev.FileSystem)](https://www.powershellgallery.com/packages/GenXdev.FileSystem/) [![GenXdev.Windows](https://img.shields.io/powershellgallery/v/GenXdev.Windows.svg?style=flat-square&label=GenXdev.Windows)](https://www.powershellgallery.com/packages/GenXdev.Windows/)
### INSTALLATION
```PowerShell
Install-Module "GenXdev.Webbrowser"
Import-Module "GenXdev.Webbrowser"
```
### UPDATE
```PowerShell
Update-Module
```
<br/><hr/><br/>

# Cmdlet Index
### GenXdev.Webbrowser
| Command | Aliases | Description |
| :--- | :--- | :--- |
| [Approve-FirefoxDebugging](#approve-firefoxdebugging) | &nbsp; | Configures Firefox's debugging and standalone app mode features. |
| [Clear-WebbrowserTabSiteApplicationData](#clear-webbrowsertabsiteapplicationdata) | clearsitedata | Clears all browser storage data for the current tab in Edge or Chrome. |
| [Close-Webbrowser](#close-webbrowser) | wbc | Closes one or more webbrowser instances selectively. |
| [Close-WebbrowserTab](#close-webbrowsertab) | CloseTab, ct | Closes the currently selected webbrowser tab. |
| [Export-BrowserBookmarks](#export-browserbookmarks) | &nbsp; | Exports browser bookmarks to a JSON file. |
| [Find-BrowserBookmark](#find-browserbookmark) | bookmarks | Finds bookmarks from one or more web browsers. |
| [Get-BrowserBookmark](#get-browserbookmark) | gbm | Returns all bookmarks from installed web browsers. |
| [Get-ChromeRemoteDebuggingPort](#get-chromeremotedebuggingport) | &nbsp; | Returns the configured remote debugging port for Google Chrome. |
| [Get-ChromiumRemoteDebuggingPort](#get-chromiumremotedebuggingport) | &nbsp; | Returns the remote debugging port for the system's default Chromium browser. |
| [Get-ChromiumSessionReference](#get-chromiumsessionreference) | &nbsp; | Gets a serializable reference to the current browser tab session. |
| [Get-DefaultWebbrowser](#get-defaultwebbrowser) | &nbsp; | Returns the configured default web browser for the current user. |
| [Get-EdgeRemoteDebuggingPort](#get-edgeremotedebuggingport) | &nbsp; | Returns the configured remote debugging port for Microsoft Edge browser. |
| [Get-Webbrowser](#get-webbrowser) | &nbsp; | Returns a collection of installed modern web browsers. |
| [Get-WebbrowserTabDomNodes](#get-webbrowsertabdomnodes) | wl | Queries and manipulates DOM nodes in the active browser tab using CSS selectors. |
| [Import-BrowserBookmarks](#import-browserbookmarks) | &nbsp; | Imports bookmarks from a file or collection into a web browser. |
| [Invoke-WebbrowserEvaluation](#invoke-webbrowserevaluation) | et, Eval | Executes JavaScript code in a selected web browser tab. |
| [Open-BrowserBookmarks](#open-browserbookmarks) | sites | Opens browser bookmarks that match specified search criteria. |
| [Open-Webbrowser](#open-webbrowser) | wb | Opens URLs in one or more browser windows with optional positioning and styling. |
| [Open-WebbrowserSideBySide](#open-webbrowsersidebyside) | wbn | Launches a new web browser window with specific positioning. |
| [Select-WebbrowserTab](#select-webbrowsertab) | st | Selects a browser tab for automation in Chrome or Edge. |
| [Set-BrowserVideoFullscreen](#set-browservideofullscreen) | fsvideo | Maximizes the first video element found in the current browser tab. |
| [Set-RemoteDebuggerPortInBrowserShortcuts](#set-remotedebuggerportinbrowsershortcuts) | &nbsp; | Updates browser shortcuts to enable remote debugging ports. |
| [Set-WebbrowserTabLocation](#set-webbrowsertablocation) | lt, Nav | Navigates the current webbrowser tab to a specified URL. |
| [Show-WebsiteInAllBrowsers](#show-websiteinallbrowsers) | &nbsp; | Opens a URL in multiple browsers simultaneously in a mosaic layout. |

### GenXdev.Webbrowser.Playwright
| Command | Aliases | Description |
| :--- | :--- | :--- |
| [Connect-PlaywrightViaDebuggingPort](#connect-playwrightviadebuggingport) | &nbsp; | Connects to an existing browser instance via debugging port. |
| [Get-PlaywrightProfileDirectory](#get-playwrightprofiledirectory) | &nbsp; | Gets the Playwright browser profile directory for persistent sessions. |
| [Resume-WebbrowserTabVideo](#resume-webbrowsertabvideo) | wbvideoplay | Resumes video playback in a YouTube browser tab. |
| [Stop-WebbrowserVideos](#stop-webbrowservideos) | ssst, wbsst, wbvideostop | Pauses video playback in all active browser sessions. |
| [Unprotect-WebbrowserTab](#unprotect-webbrowsertab) | wbctrl | Takes control of a selected web browser tab for interactive manipulation. |

<br/><hr/><br/>


# Cmdlets

&nbsp;<hr/>
###	GenXdev.Webbrowser<hr/>

##	Approve-FirefoxDebugging
```PowerShell

   Approve-FirefoxDebugging
````

### SYNTAX
```PowerShell
Approve-FirefoxDebugging [<CommonParameters>]
````

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Clear-WebbrowserTabSiteApplicationData
```PowerShell

   Clear-WebbrowserTabSiteApplicationData --> clearsitedata
````

### SYNTAX
```PowerShell
Clear-WebbrowserTabSiteApplicationData [-Edge] [-Chrome]
    [<CommonParameters>]
````

### PARAMETERS
    -Chrome
        Clear in Google Chrome
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Clear in Microsoft Edge
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Close-Webbrowser
```PowerShell

   Close-Webbrowser                     --> wbc
````

### SYNTAX
```PowerShell
Close-Webbrowser [[-Edge]] [[-Chrome]] [[-Chromium]]
    [[-Firefox]] [[-IncludeBackgroundProcesses]]
    [<CommonParameters>]
Close-Webbrowser [[-All]] [[-IncludeBackgroundProcesses]]
    [<CommonParameters>]
````

### PARAMETERS
    -All
        Closes all registered modern browsers
        Required?                    false
        Position?                    0
        Accept pipeline input?       false
        Parameter set name           All
        Aliases                      a
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chrome
        Closes Google Chrome browser instances
        Required?                    false
        Position?                    1
        Accept pipeline input?       false
        Parameter set name           Specific
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chromium
        Closes default chromium-based browser
        Required?                    false
        Position?                    2
        Accept pipeline input?       false
        Parameter set name           Specific
        Aliases                      c
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Closes Microsoft Edge browser instances
        Required?                    false
        Position?                    0
        Accept pipeline input?       false
        Parameter set name           Specific
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false
    -Firefox
        Closes Firefox browser instances
        Required?                    false
        Position?                    3
        Accept pipeline input?       false
        Parameter set name           Specific
        Aliases                      ff
        Dynamic?                     false
        Accept wildcard characters?  false
    -IncludeBackgroundProcesses
        Closes all instances including background tasks
        Required?                    false
        Position?                    4
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      bg, Force
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Close-WebbrowserTab
```PowerShell

   Close-WebbrowserTab                  --> CloseTab, ct
````

### SYNTAX
```PowerShell
Close-WebbrowserTab [-Edge] [-Chrome] [<CommonParameters>]
````

### PARAMETERS
    -Chrome
        Navigate using Google Chrome browser
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Navigate using Microsoft Edge browser
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Export-BrowserBookmarks
```PowerShell

   Export-BrowserBookmarks
````

### SYNTAX
```PowerShell
Export-BrowserBookmarks [-OutputFile] <string> [-Chrome]
    [-Edge] [-Firefox] [<CommonParameters>]
````

### PARAMETERS
    -Chrome
        Export bookmarks from Google Chrome
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Export bookmarks from Microsoft Edge
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Firefox
        Export bookmarks from Mozilla Firefox
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           Firefox
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -OutputFile <string>
        Path to the JSON file where bookmarks will be saved
        Required?                    true
        Position?                    0
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Find-BrowserBookmark
```PowerShell

   Find-BrowserBookmark                 --> bookmarks
````

### SYNTAX
```PowerShell
Find-BrowserBookmark [[-Queries] <string[]>] [-Edge]
    [-Chrome] [-Firefox] [-Count <int>] [-PassThru]
    [<CommonParameters>]
````

### PARAMETERS
    -Chrome
        Search through Google Chrome bookmarks
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false
    -Count <int>
        Maximum number of results to return
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Search through Microsoft Edge bookmarks
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false
    -Firefox
        Search through Firefox bookmarks
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ff
        Dynamic?                     false
        Accept wildcard characters?  false
    -PassThru
        Return bookmark objects instead of just URLs
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Queries <string[]>
        Search terms to find matching bookmarks
        Required?                    false
        Position?                    0
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Parameter set name           (All)
        Aliases                      q, Name, Text, Query
        Dynamic?                     false
        Accept wildcard characters?  true
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Get-BrowserBookmark
```PowerShell

   Get-BrowserBookmark                  --> gbm
````

### SYNTAX
```PowerShell
Get-BrowserBookmark [[-Chrome]] [[-Edge]]
    [<CommonParameters>]
Get-BrowserBookmark [[-Chrome]] [[-Edge]] [[-Firefox]]
    [<CommonParameters>]
````

### PARAMETERS
    -Chrome
        Returns bookmarks from Google Chrome
        Required?                    false
        Position?                    0
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Returns bookmarks from Microsoft Edge
        Required?                    false
        Position?                    1
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Firefox
        Returns bookmarks from Mozilla Firefox
        Required?                    false
        Position?                    2
        Accept pipeline input?       false
        Parameter set name           Firefox
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Get-ChromeRemoteDebuggingPort
```PowerShell

   Get-ChromeRemoteDebuggingPort
````

### SYNTAX
```PowerShell
Get-ChromeRemoteDebuggingPort [<CommonParameters>]
````

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Get-ChromiumRemoteDebuggingPort
```PowerShell

   Get-ChromiumRemoteDebuggingPort
````

### SYNTAX
```PowerShell
Get-ChromiumRemoteDebuggingPort [-Chrome] [-Edge]
    [<CommonParameters>]
````

### PARAMETERS
    -Chrome
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Get-ChromiumSessionReference
```PowerShell

   Get-ChromiumSessionReference
````

### SYNTAX
```PowerShell
Get-ChromiumSessionReference [<CommonParameters>]
````

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Get-DefaultWebbrowser
```PowerShell

   Get-DefaultWebbrowser
````

### SYNTAX
```PowerShell
Get-DefaultWebbrowser [<CommonParameters>]
````

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Get-EdgeRemoteDebuggingPort
```PowerShell

   Get-EdgeRemoteDebuggingPort
````

### SYNTAX
```PowerShell
Get-EdgeRemoteDebuggingPort [<CommonParameters>]
````

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Get-Webbrowser
```PowerShell

   Get-Webbrowser
````

### SYNTAX
```PowerShell
Get-Webbrowser [<CommonParameters>]
````

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Get-WebbrowserTabDomNodes
```PowerShell

   Get-WebbrowserTabDomNodes            --> wl
````

### SYNTAX
```PowerShell
Get-WebbrowserTabDomNodes [-QuerySelector] <string[]>
    [[-ModifyScript] <string>] [-Edge] [-Chrome] [-Page
    <Object>] [-ByReference <psobject>] [-NoAutoSelectTab]
    [<CommonParameters>]
````

### PARAMETERS
    -ByReference <psobject>
        Browser session reference object
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chrome
        Use Google Chrome browser
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Use Microsoft Edge browser
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false
    -ModifyScript <string>
        The script to modify the output of the query selector, e.g. e.outerHTML or e.outerHTML='hello world'
        Required?                    false
        Position?                    1
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -NoAutoSelectTab
        Prevent automatic tab selection
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Page <Object>
        Browser page object reference
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -QuerySelector <string[]>
        The query selector string or array of strings to use for selecting DOM nodes
        Required?                    true
        Position?                    0
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Import-BrowserBookmarks
```PowerShell

   Import-BrowserBookmarks
````

### SYNOPSIS
    Imports bookmarks from a file or collection into a web browser.

### SYNTAX
```PowerShell
Import-BrowserBookmarks [-Chrome] [-Edge] [-Firefox]
    [-WhatIf] [-Confirm] [<CommonParameters>]
Import-BrowserBookmarks [[-InputFile] <String>] [-Chrome]
    [-Edge] [-Firefox] [-WhatIf] [-Confirm]
    [<CommonParameters>]
Import-BrowserBookmarks [[-Bookmarks] <Array>] [-Chrome]
    [-Edge] [-Firefox] [-WhatIf] [-Confirm]
    [<CommonParameters>]
````

### DESCRIPTION
    Imports bookmarks into Microsoft Edge or Google Chrome from either a CSV file or
    a collection of bookmark objects. The bookmarks are added to the browser's
    bookmark bar or specified folders. Firefox import is not currently supported.

### PARAMETERS
    -InputFile <String>
        The path to a CSV file containing bookmarks to import. The CSV should have
        columns for Name, URL, Folder, DateAdded, and DateModified.
        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    -Bookmarks <Array>
        An array of bookmark objects to import. Each object should have properties for
        Name, URL, Folder, DateAdded, and DateModified.
        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    -Chrome [<SwitchParameter>]
        Switch to import bookmarks into Google Chrome.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    -Edge [<SwitchParameter>]
        Switch to import bookmarks into Microsoft Edge.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    -Firefox [<SwitchParameter>]
        Switch to indicate Firefox as target (currently not supported).
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    -WhatIf [<SwitchParameter>]
        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    -Confirm [<SwitchParameter>]
        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Invoke-WebbrowserEvaluation
```PowerShell

   Invoke-WebbrowserEvaluation          --> et, Eval
````

### SYNOPSIS
    Executes JavaScript code in a selected web browser tab.

### SYNTAX
```PowerShell
Invoke-WebbrowserEvaluation [[-Scripts] <Object[]>]
    [-Inspect] [-NoAutoSelectTab] [-Edge] [-Chrome] [-Page
    <Object>] [-ByReference <PSObject>] [<CommonParameters>]
````

### DESCRIPTION
    Executes JavaScript code in a selected browser tab with support for async/await,
    promises, and data synchronization between PowerShell and the browser context.
    Can execute code from strings, files, or URLs.
    This function provides comprehensive access to browser APIs including IndexedDB,
    localStorage, sessionStorage, and other web platform features. It includes
    built-in error handling, timeout management, and support for yielding multiple
    results from generator functions.
    The function uses Chrome DevTools Protocol (CDP) debugging connections, which
    provides privileged access that bypasses standard JavaScript security restrictions.
    This enables access to storage APIs, cross-origin resources (within the same tab),
    and other browser features that would normally be restricted in standard web contexts.
    Key capabilities:
    - Async/await and Promise support
    - Generator functions with yield support
    - Data synchronization via $Global:Data
    - Privileged access to browser storage APIs
    - Bypasses same-origin policy restrictions for current page storage
    - IndexedDB enumeration and data extraction
    - DOM manipulation and web API access
    - Error handling and timeout management

### PARAMETERS
    -Scripts <Object[]>
        JavaScript code to execute. Can be string content, file paths, or URLs.
        Accepts pipeline input.
        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Aliases
        Accept wildcard characters?  false
    -Inspect [<SwitchParameter>]
        Adds debugger statement before executing to enable debugging.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    -NoAutoSelectTab [<SwitchParameter>]
        Prevents automatic tab selection if no tab is currently selected.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    -Edge [<SwitchParameter>]
        Selects Microsoft Edge browser for execution.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    -Chrome [<SwitchParameter>]
        Selects Google Chrome browser for execution.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    -Page <Object>
        Browser page object for execution when using ByReference mode.
        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    -ByReference <PSObject>
        Session reference object when using ByReference mode.
        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

### NOTES
```PowerShell

       Requires the Windows 10+ Operating System
   -------------------------- EXAMPLE 1 --------------------------
   PS C:\> Execute simple JavaScript
   Invoke-WebbrowserEvaluation "document.title = 'hello world'"
   -------------------------- EXAMPLE 2 --------------------------
   PS>
   Synchronizing data
   Select-WebbrowserTab -Force;
   $Global:Data = @{ files= (Get-ChildItem *.* -file | % FullName)};
   [int] $number = Invoke-WebbrowserEvaluation "
       document.body.innerHTML = JSON.stringify(data.files);
       data.title = document.title;
       return 123;
   ";
   Write-Host "
       Document title : $($Global:Data.title)
       return value   : $Number
   ";
   -------------------------- EXAMPLE 3 --------------------------
   PS>
   Support for promises
   Select-WebbrowserTab -Force;
   Invoke-WebbrowserEvaluation "
       let myList = [];
       return new Promise((resolve) => {
           let i = 0;
           let a = setInterval(() => {
               myList.push(++i);
               if (i == 10) {
                   clearInterval(a);
                   resolve(myList);
               }
           }, 1000);
       });
   "
   -------------------------- EXAMPLE 4 --------------------------
   PS>
   Support for promises and more
   this function returns all rows of all tables/datastores of all databases of indexedDb in the selected tab
   beware, not all websites use indexedDb, it could return an empty set
   Select-WebbrowserTab -Force;
   Set-WebbrowserTabLocation "https://www.youtube.com/"
   Start-Sleep 3
   $AllIndexedDbData = Invoke-WebbrowserEvaluation "
       // enumerate all indexedDB databases
       for (let db of await indexedDB.databases()) {
           // request to open database
           let openRequest = await indexedDB.open(db.name);
           // wait for eventhandlers to be called
           await new Promise((resolve,reject) => {
               openRequest.onsuccess = resolve;
               openRequest.onerror = reject
           });
           // obtain reference
           let openedDb = openRequest.result;
           // initialize result
           let result = { DatabaseName: db.name, Version: db.version, Stores: [] }
           // itterate object store names
           for (let i = 0; i < openedDb.objectStoreNames.length; i++) {
               // reference
               let storeName = openedDb.objectStoreNames[i];
               // start readonly transaction
               let tr = openedDb.transaction(storeName);
               // get objectstore handle
               let store = tr.objectStore(storeName);
               // request all data
               let getRequest = store.getAll();
               // await result
               await new Promise((resolve,reject) => {
                   getRequest.onsuccess = resolve;
                   getRequest.onerror = reject;
               });
               // add result
               result.Stores.push({ StoreName: storeName, Data: getRequest.result});
           }
           // stream this database contents to the PowerShell pipeline, and continue
           yield result;
       }
   ";
   $AllIndexedDbData | Out-Host
   # SECURITY NOTE: This basic example works because the module uses Chrome DevTools
   # Protocol (CDP) debugging access, which bypasses normal JavaScript security
   # restrictions. Standard web pages cannot access IndexedDB from other origins,
   # but this debugging connection has the same privileges as the website itself.
   # See the enhanced example below for more details on security considerations.
   -------------------------- EXAMPLE 5 --------------------------
   PS>
   Enhanced IndexedDB enumeration with metadata and error handling
   This enhanced approach provides more comprehensive IndexedDB data extraction including
   database counts, error handling, and metadata. Unlike the basic example above, this
   version handles security restrictions, provides detailed store information, and
   includes record counts without necessarily retrieving all data.
   Select-WebbrowserTab -Force;
   Set-WebbrowserTabLocation "https://www.youtube.com/"
   Start-Sleep 3
   $EnhancedIndexedDbData = Invoke-WebbrowserEvaluation "
       // Enhanced IndexedDB enumeration with comprehensive error handling
       let results = [];
       for (let dbInfo of await indexedDB.databases()) {
           try {
               // Open database with timeout
               let db = await new Promise((resolve, reject) => {
                   let req = indexedDB.open(dbInfo.name);
                   req.onsuccess = () => resolve(req.result);
                   req.onerror = () => reject(req.error);
                   setTimeout(() => reject(new Error('Database open timeout')), 5000);
               });
               let dbResult = {
                   DatabaseName: dbInfo.name,
                   Version: dbInfo.version,
                   ObjectStoreCount: db.objectStoreNames.length,
                   Stores: []
               };
               // Process each object store
               for (let i = 0; i < db.objectStoreNames.length; i++) {
                   let storeName = db.objectStoreNames[i];
                   try {
                       let transaction = db.transaction(storeName, 'readonly');
                       let store = transaction.objectStore(storeName);
                       // Get record count (faster than retrieving all data)
                       let count = await new Promise((resolve, reject) => {
                           let req = store.count();
                           req.onsuccess = () => resolve(req.result);
                           req.onerror = () => reject(req.error);
                           setTimeout(() => reject(new Error('Count timeout')), 3000);
                       });
                       dbResult.Stores.push({
                           StoreName: storeName,
                           RecordCount: count,
                           KeyPath: store.keyPath,
                           AutoIncrement: store.autoIncrement,
                           IndexNames: Array.from(store.indexNames)
                       });
                   } catch (storeError) {
                       dbResult.Stores.push({
                           StoreName: storeName,
                           Error: storeError.message
                       });
                   }
               }
               results.push(dbResult);
               db.close();
           } catch (dbError) {
               results.push({
                   DatabaseName: dbInfo.name,
                   Error: dbError.message
               });
           }
       }
       yield results;
   ";
   $EnhancedIndexedDbData | ConvertTo-Json -Depth 10
   # Key differences from the basic example:
   # 1. Includes error handling for database access issues
   # 2. Provides metadata (KeyPath, AutoIncrement, IndexNames)
   # 3. Gets record counts without retrieving all data (more efficient)
   # 4. Handles timeout scenarios
   # 5. Returns structured information about database schema
   # 6. More suitable for large databases where retrieving all data would be slow
   # SECURITY CONSIDERATIONS FOR INDEXEDDB ACCESS:
   # Both examples work because this module uses Chrome DevTools Protocol (CDP) through
   # the debugging port, which bypasses standard JavaScript security restrictions:
   #
   # Standard JavaScript Limitations:
   # - Same-origin policy restricts access to IndexedDB from other origins
   # - Some databases may be hidden or protected by browser security features
   # - Cross-origin database access is typically blocked
   # - Service worker databases may have additional protection
   #
   # How this example bypasses restrictions:
   # - Uses CDP debugging connection (--remote-debugging-port) for privileged access
   # - Executes in the context of the actual page, not a sandboxed environment
   # - Has the same permissions as the website itself for its own storage
   # - Can access all databases created by the current origin/domain
   #
   # Limitations Even With CDP:
   # - Cannot access databases from other origins/domains in the same browser
   # - Cannot access databases from other browser profiles or private browsing
   # - Some browser extensions may create isolated storage not accessible via JavaScript
   #
   # Alternative Approaches for Maximum Access:
   # - Use GenXdev.Webbrowser with multiple tabs from different origins
   # - Combine with file system access to browser profile directories (when possible)
   # - Use browser automation to navigate between different domains
   # - Consider using CDP Storage domain directly (advanced, not implemented in basic examples)
   -------------------------- EXAMPLE 6 --------------------------
   PS>
   Support for yielded pipeline results
   Select-WebbrowserTab -Force;
   Invoke-WebbrowserEvaluation "
       for (let i = 0; i < 10; i++) {
           await (new Promise((resolve) => setTimeout(resolve, 1000)));
           yield i;
       }
   ";
   -------------------------- EXAMPLE 7 --------------------------
   PS>Get-ChildItem *.js | Invoke-WebbrowserEvaluation -Edge
   -------------------------- EXAMPLE 8 --------------------------
   PS>ls *.js | et -e
````

<br/><hr/><br/>


##	Open-BrowserBookmarks
```PowerShell

   Open-BrowserBookmarks                --> sites
````

### SYNTAX
```PowerShell
Open-BrowserBookmarks [[-Queries] <string[]>] [[-Count]
    <int>] [-Edge] [-Chrome] [-Firefox] [-Monitor <int>]
    [-SideBySide] [-Private] [-Force] [-FullScreen]
    [-ShowWindow] [-Width <int>] [-Height <int>] [-X <int>]
    [-Y <int>] [-Left] [-Right] [-Top] [-Bottom] [-Centered]
    [-ApplicationMode] [-NoBrowserExtensions] [-AcceptLang
    <string>] [-KeysToSend <string[]>] [-FocusWindow]
    [-SetForeground] [-Minimize] [-Maximize] [-RestoreFocus]
    [-NewWindow] [-Chromium] [-All] [-DisablePopupBlocker]
    [-SendKeyEscape] [-SendKeyHoldKeyboardFocus]
    [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds
    <int>] [-NoBorders] [-SessionOnly] [-ClearSession]
    [-SkipSession] [<CommonParameters>]
````

### PARAMETERS
    -AcceptLang <string>
        Set the browser accept-lang http header
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      lang, locale
        Dynamic?                     false
        Accept wildcard characters?  false
    -All
        Opens in all registered modern browsers
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -ApplicationMode
        Hide the browser controls
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      a, app, appmode
        Dynamic?                     false
        Accept wildcard characters?  false
    -Bottom
        Place browser window on the bottom side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Centered
        Place browser window in the center of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chrome
        Select in Google Chrome
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chromium
        Opens in Microsoft Edge or Google Chrome, depending on what the default browser is
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      c
        Dynamic?                     false
        Accept wildcard characters?  false
    -ClearSession
        Clear alternative settings stored in session for AI preferences
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Count <int>
        Maximum number of urls to open
        Required?                    false
        Position?                    1
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -DisablePopupBlocker
        Disable the popup blocker
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      allowpopups
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Select in Microsoft Edge
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false
    -Firefox
        Select in Firefox
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ff
        Dynamic?                     false
        Accept wildcard characters?  false
    -FocusWindow
        Focus the browser window after opening
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fw, focus
        Dynamic?                     false
        Accept wildcard characters?  false
    -Force
        Force enable debugging port, stopping existing browsers if needed
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -FullScreen
        Opens in fullscreen mode
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fs, f
        Dynamic?                     false
        Accept wildcard characters?  false
    -Height <int>
        The initial height of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -KeysToSend <string[]>
        Keystrokes to send to the Browser window, see documentation for cmdlet GenXdev.Windows\Send-Key
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Left
        Place browser window on the left side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Maximize
        Maximize the window after positioning
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Minimize
        Minimize the window after positioning
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Monitor <int>
        The monitor to use, 0 = default, -1 is discard, -2 = Configured secondary monitor
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      m, mon
        Dynamic?                     false
        Accept wildcard characters?  false
    -NewWindow
        Do not re-use existing browser window, instead, create a new one
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      nw, new
        Dynamic?                     false
        Accept wildcard characters?  false
    -NoBorders
        Removes the borders of the browser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      nb
        Dynamic?                     false
        Accept wildcard characters?  false
    -NoBrowserExtensions
        Prevent loading of browser extensions
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      de, ne, NoExtensions
        Dynamic?                     false
        Accept wildcard characters?  false
    -Private
        Opens in incognito/private browsing mode
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      incognito, inprivate
        Dynamic?                     false
        Accept wildcard characters?  false
    -Queries <string[]>
        Search terms to filter bookmarks
        Required?                    false
        Position?                    0
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Parameter set name           (All)
        Aliases                      q, Name, Text, Query
        Dynamic?                     false
        Accept wildcard characters?  false
    -RestoreFocus
        Restore PowerShell window focus
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      rf, bg
        Dynamic?                     false
        Accept wildcard characters?  false
    -Right
        Place browser window on the right side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyDelayMilliSeconds <int>
        Delay between sending different key sequences in milliseconds
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      DelayMilliSeconds
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyEscape
        Escape control characters when sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      Escape
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyHoldKeyboardFocus
        Prevent returning keyboard focus to PowerShell after sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      HoldKeyboardFocus
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyUseShiftEnter
        Send Shift+Enter instead of regular Enter for line breaks
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      UseShiftEnter
        Dynamic?                     false
        Accept wildcard characters?  false
    -SessionOnly
        Use alternative settings stored in session for AI preferences
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -SetForeground
        Set the browser window to foreground after opening
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fg
        Dynamic?                     false
        Accept wildcard characters?  false
    -ShowWindow
        Show the browser window (not 1d or hidden)
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      sw
        Dynamic?                     false
        Accept wildcard characters?  false
    -SideBySide
        Will either set the window fullscreen on a different monitor than Powershell, or side by side with Powershell on the same monitor
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      sbs
        Dynamic?                     false
        Accept wildcard characters?  false
    -SkipSession
        Store settings only in persistent preferences without affecting session
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      FromPreferences
        Dynamic?                     false
        Accept wildcard characters?  false
    -Top
        Place browser window on the top side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Width <int>
        The initial width of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -X <int>
        The initial X position of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Y <int>
        The initial Y position of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Open-Webbrowser
```PowerShell

   Open-Webbrowser                      --> wb
````

### SYNTAX
```PowerShell
Open-Webbrowser [[-Url] <string[]>] [[-Monitor] <int>]
    [-Width <int>] [-Height <int>] [-X <int>] [-Y <int>]
    [-AcceptLang <string>] [-Force] [-Edge] [-Chrome]
    [-Chromium] [-Firefox] [-All] [-Left] [-Right] [-Top]
    [-Bottom] [-Centered] [-FullScreen] [-Private]
    [-ApplicationMode] [-NoBrowserExtensions]
    [-DisablePopupBlocker] [-NewWindow] [-FocusWindow]
    [-SetForeground] [-Maximize] [-PassThru] [-NoBorders]
    [-RestoreFocus] [-SideBySide] [-KeysToSend <string[]>]
    [-SendKeyEscape] [-SendKeyHoldKeyboardFocus]
    [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds
    <int>] [-SessionOnly] [-ClearSession] [-SkipSession]
    [<CommonParameters>]
````

### PARAMETERS
    -AcceptLang <string>
        Set the browser accept-lang http header
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      lang, locale
        Dynamic?                     false
        Accept wildcard characters?  false
    -All
        Opens in all registered modern browsers
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -ApplicationMode
        Hide the browser controls
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      a, app, appmode
        Dynamic?                     false
        Accept wildcard characters?  false
    -Bottom
        Place browser window on the bottom side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Centered
        Place browser window in the center of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chrome
        Opens in Google Chrome
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chromium
        Opens in Microsoft Edge or Google Chrome, depending on what the default browser is
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      c
        Dynamic?                     false
        Accept wildcard characters?  false
    -ClearSession
        Clear alternative settings stored in session for AI preferences
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -DisablePopupBlocker
        Disable the popup blocker
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      allowpopups
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Opens in Microsoft Edge
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false
    -Firefox
        Opens in Firefox
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ff
        Dynamic?                     false
        Accept wildcard characters?  false
    -FocusWindow
        Focus the browser window after opening
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fw, focus
        Dynamic?                     false
        Accept wildcard characters?  false
    -Force
        Force enable debugging port, stopping existing browsers if needed
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -FullScreen
        Opens in fullscreen mode
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fs, f
        Dynamic?                     false
        Accept wildcard characters?  false
    -Height <int>
        The initial height of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -KeysToSend <string[]>
        Keystrokes to send to the Window, see documentation for cmdlet GenXdev.Windows\Send-Key
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Left
        Place browser window on the left side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Maximize
        Maximize the window after positioning
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Monitor <int>
        The monitor to use, 0 = default, -1 is discard, -2 = Configured secondary monitor, defaults to $Global:DefaultSecondaryMonitor or 2 if not found
        Required?                    false
        Position?                    1
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      m, mon
        Dynamic?                     false
        Accept wildcard characters?  false
    -NewWindow
        Do not re-use existing browser window, instead, create a new one
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      nw, new
        Dynamic?                     false
        Accept wildcard characters?  false
    -NoBorders
        Removes the borders of the window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      nb
        Dynamic?                     false
        Accept wildcard characters?  false
    -NoBrowserExtensions
        Prevent loading of browser extensions
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      de, ne, NoExtensions
        Dynamic?                     false
        Accept wildcard characters?  false
    -PassThru
        Returns a PowerShell object of the browserprocess
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      pt
        Dynamic?                     false
        Accept wildcard characters?  false
    -Private
        Opens in incognito/private browsing mode
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      incognito, inprivate
        Dynamic?                     false
        Accept wildcard characters?  false
    -RestoreFocus
        Restore PowerShell window focus
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      rf, bg
        Dynamic?                     false
        Accept wildcard characters?  false
    -Right
        Place browser window on the right side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyDelayMilliSeconds <int>
        Delay between different input strings in milliseconds when sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      DelayMilliSeconds
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyEscape
        Escape control characters and modifiers when sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      Escape
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyHoldKeyboardFocus
        Hold keyboard focus on target window when sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      HoldKeyboardFocus
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyUseShiftEnter
        Use Shift+Enter instead of Enter when sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      UseShiftEnter
        Dynamic?                     false
        Accept wildcard characters?  false
    -SessionOnly
        Use alternative settings stored in session for AI preferences
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -SetForeground
        Set the browser window to foreground after opening
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fg
        Dynamic?                     false
        Accept wildcard characters?  false
    -SideBySide
        Position browser window either fullscreen on different monitor than PowerShell, or side by side with PowerShell on the same monitor
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      sbs
        Dynamic?                     false
        Accept wildcard characters?  false
    -SkipSession
        Store settings only in persistent preferences without affecting session
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      FromPreferences
        Dynamic?                     false
        Accept wildcard characters?  false
    -Top
        Place browser window on the top side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Url <string[]>
        The URLs to open in the browser
        Required?                    false
        Position?                    0
        Accept pipeline input?       true (ByValue)
        Parameter set name           (All)
        Aliases                      Value, Uri, FullName, Website, WebsiteUrl
        Dynamic?                     false
        Accept wildcard characters?  false
    -Width <int>
        The initial width of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -X <int>
        The initial X position of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Y <int>
        The initial Y position of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Open-WebbrowserSideBySide
```PowerShell

   Open-WebbrowserSideBySide            --> wbn
````

### SYNTAX
```PowerShell
Open-WebbrowserSideBySide [[-Url] <string[]>] [[-Monitor]
    <int>] [-Width <int>] [-Height <int>] [-X <int>] [-Y
    <int>] [-AcceptLang <string>] [-Force] [-Edge] [-Chrome]
    [-Chromium] [-Firefox] [-All] [-Left] [-Right] [-Top]
    [-Bottom] [-Centered] [-FullScreen] [-Private]
    [-ApplicationMode] [-NoBrowserExtensions]
    [-DisablePopupBlocker] [-NewWindow] [-FocusWindow]
    [-SetForeground] [-Maximize] [-PassThru] [-NoBorders]
    [-RestoreFocus] [-SideBySide] [-KeysToSend <string[]>]
    [-SendKeyEscape] [-SendKeyHoldKeyboardFocus]
    [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds
    <int>] [-SessionOnly] [-ClearSession] [-SkipSession]
    [<CommonParameters>]
````

### PARAMETERS
    -AcceptLang <string>
        Set the browser accept-lang http header
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      lang, locale
        Dynamic?                     false
        Accept wildcard characters?  false
    -All
        Opens in all registered modern browsers
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -ApplicationMode
        Hide the browser controls
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      a, app, appmode
        Dynamic?                     false
        Accept wildcard characters?  false
    -Bottom
        Place browser window on the bottom side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Centered
        Place browser window in the center of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chrome
        Opens in Google Chrome
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chromium
        Opens in Microsoft Edge or Google Chrome, depending on what the default browser is
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      c
        Dynamic?                     false
        Accept wildcard characters?  false
    -ClearSession
        Clear alternative settings stored in session for AI preferences
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -DisablePopupBlocker
        Disable the popup blocker
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      allowpopups
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Opens in Microsoft Edge
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false
    -Firefox
        Opens in Firefox
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ff
        Dynamic?                     false
        Accept wildcard characters?  false
    -FocusWindow
        Focus the browser window after opening
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fw, focus
        Dynamic?                     false
        Accept wildcard characters?  false
    -Force
        Force enable debugging port, stopping existing browsers if needed
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -FullScreen
        Opens in fullscreen mode
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fs, f
        Dynamic?                     false
        Accept wildcard characters?  false
    -Height <int>
        The initial height of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -KeysToSend <string[]>
        Keystrokes to send to the Window, see documentation for cmdlet GenXdev.Windows\Send-Key
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Left
        Place browser window on the left side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Maximize
        Maximize the window after positioning
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Monitor <int>
        The monitor to use, 0 = default, -1 is discard, -2 = Configured secondary monitor, defaults to $Global:DefaultSecondaryMonitor or 2 if not found
        Required?                    false
        Position?                    1
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      m, mon
        Dynamic?                     false
        Accept wildcard characters?  false
    -NewWindow
        Do not re-use existing browser window, instead, create a new one
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      nw, new
        Dynamic?                     false
        Accept wildcard characters?  false
    -NoBorders
        Removes the borders of the window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      nb
        Dynamic?                     false
        Accept wildcard characters?  false
    -NoBrowserExtensions
        Prevent loading of browser extensions
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      de, ne, NoExtensions
        Dynamic?                     false
        Accept wildcard characters?  false
    -PassThru
        Returns a PowerShell object of the browserprocess
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      pt
        Dynamic?                     false
        Accept wildcard characters?  false
    -Private
        Opens in incognito/private browsing mode
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      incognito, inprivate
        Dynamic?                     false
        Accept wildcard characters?  false
    -RestoreFocus
        Restore PowerShell window focus
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      rf, bg
        Dynamic?                     false
        Accept wildcard characters?  false
    -Right
        Place browser window on the right side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyDelayMilliSeconds <int>
        Delay between different input strings in milliseconds when sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      DelayMilliSeconds
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyEscape
        Escape control characters and modifiers when sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      Escape
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyHoldKeyboardFocus
        Hold keyboard focus on target window when sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      HoldKeyboardFocus
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyUseShiftEnter
        Use Shift+Enter instead of Enter when sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      UseShiftEnter
        Dynamic?                     false
        Accept wildcard characters?  false
    -SessionOnly
        Use alternative settings stored in session for AI preferences
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -SetForeground
        Set the browser window to foreground after opening
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fg
        Dynamic?                     false
        Accept wildcard characters?  false
    -SideBySide
        Position browser window either fullscreen on different monitor than PowerShell, or side by side with PowerShell on the same monitor
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      sbs
        Dynamic?                     false
        Accept wildcard characters?  false
    -SkipSession
        Store settings only in persistent preferences without affecting session
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      FromPreferences
        Dynamic?                     false
        Accept wildcard characters?  false
    -Top
        Place browser window on the top side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Url <string[]>
        The URLs to open in the browser
        Required?                    false
        Position?                    0
        Accept pipeline input?       true (ByValue)
        Parameter set name           (All)
        Aliases                      Value, Uri, FullName, Website, WebsiteUrl
        Dynamic?                     false
        Accept wildcard characters?  false
    -Width <int>
        The initial width of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -X <int>
        The initial X position of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Y <int>
        The initial Y position of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Select-WebbrowserTab
```PowerShell

   Select-WebbrowserTab                 --> st
````

### SYNTAX
```PowerShell
Select-WebbrowserTab [[-Id] <int>] [-Monitor <int>] [-Width
    <int>] [-Height <int>] [-X <int>] [-Y <int>]
    [-AcceptLang <string>] [-FullScreen] [-Private]
    [-Chromium] [-Firefox] [-All] [-Left] [-Right] [-Top]
    [-Bottom] [-Centered] [-ApplicationMode]
    [-NoBrowserExtensions] [-DisablePopupBlocker]
    [-RestoreFocus] [-NewWindow] [-FocusWindow]
    [-SetForeground] [-Maximize] [-KeysToSend <string[]>]
    [-SendKeyEscape] [-SendKeyHoldKeyboardFocus]
    [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds
    <int>] [-Edge] [-Chrome] [-Force] [<CommonParameters>]
Select-WebbrowserTab [-Name] <string> [-Monitor <int>]
    [-Width <int>] [-Height <int>] [-X <int>] [-Y <int>]
    [-AcceptLang <string>] [-FullScreen] [-Private]
    [-Chromium] [-Firefox] [-All] [-Left] [-Right] [-Top]
    [-Bottom] [-Centered] [-ApplicationMode]
    [-NoBrowserExtensions] [-DisablePopupBlocker]
    [-RestoreFocus] [-NewWindow] [-FocusWindow]
    [-SetForeground] [-Maximize] [-KeysToSend <string[]>]
    [-SendKeyEscape] [-SendKeyHoldKeyboardFocus]
    [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds
    <int>] [-Edge] [-Chrome] [-Force] [<CommonParameters>]
Select-WebbrowserTab -ByReference <psobject> [-Monitor
    <int>] [-Width <int>] [-Height <int>] [-X <int>] [-Y
    <int>] [-AcceptLang <string>] [-FullScreen] [-Private]
    [-Chromium] [-Firefox] [-All] [-Left] [-Right] [-Top]
    [-Bottom] [-Centered] [-ApplicationMode]
    [-NoBrowserExtensions] [-DisablePopupBlocker]
    [-RestoreFocus] [-NewWindow] [-FocusWindow]
    [-SetForeground] [-Maximize] [-KeysToSend <string[]>]
    [-SendKeyEscape] [-SendKeyHoldKeyboardFocus]
    [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds
    <int>] [-Edge] [-Chrome] [-Force] [<CommonParameters>]
````

### PARAMETERS
    -AcceptLang <string>
        Set the browser accept-lang http header
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      lang, locale
        Dynamic?                     false
        Accept wildcard characters?  false
    -All
        Opens in all registered modern browsers
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -ApplicationMode
        Hide the browser controls
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      a, app, appmode
        Dynamic?                     false
        Accept wildcard characters?  false
    -Bottom
        Place browser window on the bottom side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -ByReference <psobject>
        Select tab using reference from Get-ChromiumSessionReference
        Required?                    true
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           ByReference
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Centered
        Place browser window in the center of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chrome
        Opens in Google Chrome
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chromium
        Opens in Microsoft Edge or Google Chrome, depending on what the default browser is
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      c
        Dynamic?                     false
        Accept wildcard characters?  false
    -DisablePopupBlocker
        Disable the popup blocker
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      allowpopups
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Opens in Microsoft Edge
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false
    -Firefox
        Opens in Firefox
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ff
        Dynamic?                     false
        Accept wildcard characters?  false
    -FocusWindow
        Focus the browser window after opening
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fw, focus
        Dynamic?                     false
        Accept wildcard characters?  false
    -Force
        Forces browser restart if needed
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -FullScreen
        Opens in fullscreen mode
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fs, f
        Dynamic?                     false
        Accept wildcard characters?  false
    -Height <int>
        The initial height of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Id <int>
        Tab identifier from the shown list
        Required?                    false
        Position?                    0
        Accept pipeline input?       false
        Parameter set name           ById
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -KeysToSend <string[]>
        Keystrokes to send to the Browser window, see documentation for cmdlet GenXdev.Windows\Send-Key
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Left
        Place browser window on the left side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Maximize
        Maximize the window after positioning
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Monitor <int>
        The monitor to use, 0 = default, -1 is discard, -2 = Configured secondary monitor, defaults to $Global:DefaultSecondaryMonitor or 2 if not found
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      m, mon
        Dynamic?                     false
        Accept wildcard characters?  false
    -Name <string>
        Selects first tab containing this name in URL
        Required?                    true
        Position?                    0
        Accept pipeline input?       false
        Parameter set name           ByName
        Aliases                      Pattern
        Dynamic?                     false
        Accept wildcard characters?  true
    -NewWindow
        Do not re-use existing browser window, instead, create a new one
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      nw, new
        Dynamic?                     false
        Accept wildcard characters?  false
    -NoBrowserExtensions
        Prevent loading of browser extensions
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      de, ne, NoExtensions
        Dynamic?                     false
        Accept wildcard characters?  false
    -Private
        Opens in incognito/private browsing mode
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      incognito, inprivate
        Dynamic?                     false
        Accept wildcard characters?  false
    -RestoreFocus
        Restore PowerShell window focus
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      rf, bg
        Dynamic?                     false
        Accept wildcard characters?  false
    -Right
        Place browser window on the right side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyDelayMilliSeconds <int>
        Delay between sending different key sequences in milliseconds
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      DelayMilliSeconds
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyEscape
        Escape control characters when sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      Escape
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyHoldKeyboardFocus
        Prevent returning keyboard focus to PowerShell after sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      HoldKeyboardFocus
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyUseShiftEnter
        Send Shift+Enter instead of regular Enter for line breaks
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      UseShiftEnter
        Dynamic?                     false
        Accept wildcard characters?  false
    -SetForeground
        Set the browser window to foreground after opening
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fg
        Dynamic?                     false
        Accept wildcard characters?  false
    -Top
        Place browser window on the top side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Width <int>
        The initial width of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -X <int>
        The initial X position of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Y <int>
        The initial Y position of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Set-BrowserVideoFullscreen
```PowerShell

   Set-BrowserVideoFullscreen           --> fsvideo
````

### SYNTAX
```PowerShell
Set-BrowserVideoFullscreen [-WhatIf] [-Confirm]
    [<CommonParameters>]
````

### PARAMETERS
    -Confirm
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      cf
        Dynamic?                     false
        Accept wildcard characters?  false
    -WhatIf
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      wi
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Set-RemoteDebuggerPortInBrowserShortcuts
```PowerShell

   Set-RemoteDebuggerPortInBrowserShortcuts
````

### SYNTAX
```PowerShell
Set-RemoteDebuggerPortInBrowserShortcuts [-WhatIf]
    [-Confirm] [<CommonParameters>]
````

### PARAMETERS
    -Confirm
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      cf
        Dynamic?                     false
        Accept wildcard characters?  false
    -WhatIf
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      wi
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Set-WebbrowserTabLocation
```PowerShell

   Set-WebbrowserTabLocation            --> lt, Nav
````

### SYNTAX
```PowerShell
Set-WebbrowserTabLocation [-Url] <string> [-NoAutoSelectTab]
    [-Page <Object>] [-ByReference <psobject>] [-WhatIf]
    [-Confirm] [<CommonParameters>]
Set-WebbrowserTabLocation [-Url] <string> [-NoAutoSelectTab]
    [-Edge] [-Page <Object>] [-ByReference <psobject>]
    [-WhatIf] [-Confirm] [<CommonParameters>]
Set-WebbrowserTabLocation [-Url] <string> [-NoAutoSelectTab]
    [-Chrome] [-Page <Object>] [-ByReference <psobject>]
    [-WhatIf] [-Confirm] [<CommonParameters>]
````

### PARAMETERS
    -ByReference <psobject>
        Browser session reference object
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chrome
        Navigate using Google Chrome browser
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           Chrome
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false
    -Confirm
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      cf
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Navigate using Microsoft Edge browser
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           Edge
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false
    -NoAutoSelectTab
        Prevent automatic tab selection
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Page <Object>
        Browser page object reference
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Url <string>
        The URL to navigate to
        Required?                    true
        Position?                    0
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -WhatIf
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      wi
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Show-WebsiteInAllBrowsers
```PowerShell

   Show-WebsiteInAllBrowsers
````

### SYNTAX
```PowerShell
Show-WebsiteInAllBrowsers [-Url] <string> [-Monitor <int>]
    [-Width <int>] [-Height <int>] [-X <int>] [-Y <int>]
    [-AcceptLang <string>] [-FullScreen] [-Private] [-Force]
    [-Edge] [-Chrome] [-Chromium] [-Firefox] [-All] [-Left]
    [-Right] [-Top] [-Bottom] [-Centered] [-ApplicationMode]
    [-NoBrowserExtensions] [-DisablePopupBlocker]
    [-RestoreFocus] [-NewWindow] [-FocusWindow]
    [-SetForeground] [-Maximize] [-KeysToSend <string[]>]
    [-SendKeyEscape] [-SendKeyHoldKeyboardFocus]
    [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds
    <int>] [-NoBorders] [-SideBySide] [-SessionOnly]
    [-ClearSession] [-SkipSession] [<CommonParameters>]
````

### PARAMETERS
    -AcceptLang <string>
        Set the browser accept-lang http header
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      lang, locale
        Dynamic?                     false
        Accept wildcard characters?  false
    -All
        Opens in all registered modern browsers
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -ApplicationMode
        Hide the browser controls
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      a, app, appmode
        Dynamic?                     false
        Accept wildcard characters?  false
    -Bottom
        Place browser window on the bottom side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Centered
        Place browser window in the center of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chrome
        Opens in Google Chrome
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chromium
        Opens in Microsoft Edge or Google Chrome, depending on what the default browser is
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      c
        Dynamic?                     false
        Accept wildcard characters?  false
    -ClearSession
        Clear alternative settings stored in session for AI preferences.
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -DisablePopupBlocker
        Disable the popup blocker
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      allowpopups
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Opens in Microsoft Edge
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false
    -Firefox
        Opens in Firefox
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ff
        Dynamic?                     false
        Accept wildcard characters?  false
    -FocusWindow
        Focus the browser window after opening
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fw, focus
        Dynamic?                     false
        Accept wildcard characters?  false
    -Force
        Force enable debugging port, stopping existing browsers if needed
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -FullScreen
        Opens in fullscreen mode
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fs, f
        Dynamic?                     false
        Accept wildcard characters?  false
    -Height <int>
        The initial height of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -KeysToSend <string[]>
        Keystrokes to send to the Browser window, see documentation for cmdlet GenXdev.Windows\Send-Key
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Left
        Place browser window on the left side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Maximize
        Maximize the window after positioning
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Monitor <int>
        The monitor to use, 0 = default, -1 is discard, -2 = Configured secondary monitor, defaults to $Global:DefaultSecondaryMonitor or 2 if not found
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      m, mon
        Dynamic?                     false
        Accept wildcard characters?  false
    -NewWindow
        Do not re-use existing browser window, instead, create a new one
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      nw, new
        Dynamic?                     false
        Accept wildcard characters?  false
    -NoBorders
        Removes the borders of the browser window.
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      nb
        Dynamic?                     false
        Accept wildcard characters?  false
    -NoBrowserExtensions
        Prevent loading of browser extensions
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      de, ne, NoExtensions
        Dynamic?                     false
        Accept wildcard characters?  false
    -Private
        Opens in incognito/private browsing mode
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      incognito, inprivate
        Dynamic?                     false
        Accept wildcard characters?  false
    -RestoreFocus
        Restore PowerShell window focus
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      rf, bg
        Dynamic?                     false
        Accept wildcard characters?  false
    -Right
        Place browser window on the right side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyDelayMilliSeconds <int>
        Delay between sending different key sequences in milliseconds
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      DelayMilliSeconds
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyEscape
        Escape control characters when sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      Escape
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyHoldKeyboardFocus
        Prevent returning keyboard focus to PowerShell after sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      HoldKeyboardFocus
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyUseShiftEnter
        Send Shift+Enter instead of regular Enter for line breaks
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      UseShiftEnter
        Dynamic?                     false
        Accept wildcard characters?  false
    -SessionOnly
        Use alternative settings stored in session for AI preferences.
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -SetForeground
        Set the browser window to foreground after opening
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fg
        Dynamic?                     false
        Accept wildcard characters?  false
    -SideBySide
        Position browser window either fullscreen on different monitor than PowerShell, or side by side with PowerShell on the same monitor.
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      sbs
        Dynamic?                     false
        Accept wildcard characters?  false
    -SkipSession
        Store settings only in persistent preferences without affecting session.
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      FromPreferences
        Dynamic?                     false
        Accept wildcard characters?  false
    -Top
        Place browser window on the top side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Url <string>
        The URLs to open in all browsers simultaneously
        Required?                    true
        Position?                    0
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Parameter set name           (All)
        Aliases                      Value, Uri, FullName, Website, WebsiteUrl
        Dynamic?                     false
        Accept wildcard characters?  false
    -Width <int>
        The initial width of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -X <int>
        The initial X position of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Y <int>
        The initial Y position of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


&nbsp;<hr/>
###	GenXdev.Webbrowser.Playwright<hr/>

##	Connect-PlaywrightViaDebuggingPort
```PowerShell

   Connect-PlaywrightViaDebuggingPort
````

### SYNOPSIS
    Connects to an existing browser instance via debugging port.

### SYNTAX
```PowerShell
Connect-PlaywrightViaDebuggingPort [-WsEndpoint] <String>
    [<CommonParameters>]
````

### DESCRIPTION
    Establishes a connection to a running Chromium-based browser instance using the
    WebSocket debugger URL. Creates a Playwright instance and connects over CDP
    (Chrome DevTools Protocol). The connected browser instance is stored in a global
    dictionary for later reference.

### PARAMETERS
    -WsEndpoint <String>
        The WebSocket URL for connecting to the browser's debugging port. This URL
        typically follows the format 'ws://hostname:port/devtools/browser/<id>'.
        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Get-PlaywrightProfileDirectory
```PowerShell

   Get-PlaywrightProfileDirectory
````

### SYNTAX
```PowerShell
Get-PlaywrightProfileDirectory [[-BrowserType] {Chromium |
    Firefox | Webkit}] [<CommonParameters>]
````

### PARAMETERS
    -BrowserType <string>
        The browser type (Chromium, Firefox, or Webkit)
        Required?                    false
        Position?                    0
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Resume-WebbrowserTabVideo
```PowerShell

   Resume-WebbrowserTabVideo            --> wbvideoplay
````

### SYNTAX
```PowerShell
Resume-WebbrowserTabVideo [<CommonParameters>]
````

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Stop-WebbrowserVideos
```PowerShell

   Stop-WebbrowserVideos                --> ssst, wbsst, wbvideostop
````

### SYNTAX
```PowerShell
Stop-WebbrowserVideos [-Edge] [-Chrome] [-WhatIf] [-Confirm]
    [<CommonParameters>]
````

### PARAMETERS
    -Chrome
        Opens in Google Chrome
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false
    -Confirm
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      cf
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Opens in Microsoft Edge
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false
    -WhatIf
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      wi
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Unprotect-WebbrowserTab
```PowerShell

   Unprotect-WebbrowserTab              --> wbctrl
````

### SYNTAX
```PowerShell
Unprotect-WebbrowserTab [[-UseCurrent]] [[-Force]]
    [<CommonParameters>]
````

### PARAMETERS
    -Force
        Restart browser if no debugging server detected
        Required?                    false
        Position?                    1
        Accept pipeline input?       false
        Parameter set name           Default
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -UseCurrent
        Use current tab instead of selecting a new one
        Required?                    false
        Position?                    0
        Accept pipeline input?       false
        Parameter set name           Default
        Aliases                      current
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


&nbsp;<hr/>
###	GenXdev.Webbrowser<hr/>

##	Approve-FirefoxDebugging
```PowerShell

   Approve-FirefoxDebugging
````

### SYNTAX
```PowerShell
Approve-FirefoxDebugging [<CommonParameters>]
````

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Clear-WebbrowserTabSiteApplicationData
```PowerShell

   Clear-WebbrowserTabSiteApplicationData --> clearsitedata
````

### SYNTAX
```PowerShell
Clear-WebbrowserTabSiteApplicationData [-Edge] [-Chrome]
    [<CommonParameters>]
````

### PARAMETERS
    -Chrome
        Clear in Google Chrome
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Clear in Microsoft Edge
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Close-Webbrowser
```PowerShell

   Close-Webbrowser                     --> wbc
````

### SYNTAX
```PowerShell
Close-Webbrowser [[-Edge]] [[-Chrome]] [[-Chromium]]
    [[-Firefox]] [[-IncludeBackgroundProcesses]]
    [<CommonParameters>]
Close-Webbrowser [[-All]] [[-IncludeBackgroundProcesses]]
    [<CommonParameters>]
````

### PARAMETERS
    -All
        Closes all registered modern browsers
        Required?                    false
        Position?                    0
        Accept pipeline input?       false
        Parameter set name           All
        Aliases                      a
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chrome
        Closes Google Chrome browser instances
        Required?                    false
        Position?                    1
        Accept pipeline input?       false
        Parameter set name           Specific
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chromium
        Closes default chromium-based browser
        Required?                    false
        Position?                    2
        Accept pipeline input?       false
        Parameter set name           Specific
        Aliases                      c
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Closes Microsoft Edge browser instances
        Required?                    false
        Position?                    0
        Accept pipeline input?       false
        Parameter set name           Specific
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false
    -Firefox
        Closes Firefox browser instances
        Required?                    false
        Position?                    3
        Accept pipeline input?       false
        Parameter set name           Specific
        Aliases                      ff
        Dynamic?                     false
        Accept wildcard characters?  false
    -IncludeBackgroundProcesses
        Closes all instances including background tasks
        Required?                    false
        Position?                    4
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      bg, Force
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Close-WebbrowserTab
```PowerShell

   Close-WebbrowserTab                  --> CloseTab, ct
````

### SYNTAX
```PowerShell
Close-WebbrowserTab [-Edge] [-Chrome] [<CommonParameters>]
````

### PARAMETERS
    -Chrome
        Navigate using Google Chrome browser
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Navigate using Microsoft Edge browser
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Export-BrowserBookmarks
```PowerShell

   Export-BrowserBookmarks
````

### SYNTAX
```PowerShell
Export-BrowserBookmarks [-OutputFile] <string> [-Chrome]
    [-Edge] [-Firefox] [<CommonParameters>]
````

### PARAMETERS
    -Chrome
        Export bookmarks from Google Chrome
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Export bookmarks from Microsoft Edge
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Firefox
        Export bookmarks from Mozilla Firefox
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           Firefox
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -OutputFile <string>
        Path to the JSON file where bookmarks will be saved
        Required?                    true
        Position?                    0
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Find-BrowserBookmark
```PowerShell

   Find-BrowserBookmark                 --> bookmarks
````

### SYNTAX
```PowerShell
Find-BrowserBookmark [[-Queries] <string[]>] [-Edge]
    [-Chrome] [-Firefox] [-Count <int>] [-PassThru]
    [<CommonParameters>]
````

### PARAMETERS
    -Chrome
        Search through Google Chrome bookmarks
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false
    -Count <int>
        Maximum number of results to return
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Search through Microsoft Edge bookmarks
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false
    -Firefox
        Search through Firefox bookmarks
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ff
        Dynamic?                     false
        Accept wildcard characters?  false
    -PassThru
        Return bookmark objects instead of just URLs
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Queries <string[]>
        Search terms to find matching bookmarks
        Required?                    false
        Position?                    0
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Parameter set name           (All)
        Aliases                      q, Name, Text, Query
        Dynamic?                     false
        Accept wildcard characters?  true
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Get-BrowserBookmark
```PowerShell

   Get-BrowserBookmark                  --> gbm
````

### SYNTAX
```PowerShell
Get-BrowserBookmark [[-Chrome]] [[-Edge]]
    [<CommonParameters>]
Get-BrowserBookmark [[-Chrome]] [[-Edge]] [[-Firefox]]
    [<CommonParameters>]
````

### PARAMETERS
    -Chrome
        Returns bookmarks from Google Chrome
        Required?                    false
        Position?                    0
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Returns bookmarks from Microsoft Edge
        Required?                    false
        Position?                    1
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Firefox
        Returns bookmarks from Mozilla Firefox
        Required?                    false
        Position?                    2
        Accept pipeline input?       false
        Parameter set name           Firefox
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Get-ChromeRemoteDebuggingPort
```PowerShell

   Get-ChromeRemoteDebuggingPort
````

### SYNTAX
```PowerShell
Get-ChromeRemoteDebuggingPort [<CommonParameters>]
````

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Get-ChromiumRemoteDebuggingPort
```PowerShell

   Get-ChromiumRemoteDebuggingPort
````

### SYNTAX
```PowerShell
Get-ChromiumRemoteDebuggingPort [-Chrome] [-Edge]
    [<CommonParameters>]
````

### PARAMETERS
    -Chrome
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Get-ChromiumSessionReference
```PowerShell

   Get-ChromiumSessionReference
````

### SYNTAX
```PowerShell
Get-ChromiumSessionReference [<CommonParameters>]
````

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Get-DefaultWebbrowser
```PowerShell

   Get-DefaultWebbrowser
````

### SYNTAX
```PowerShell
Get-DefaultWebbrowser [<CommonParameters>]
````

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Get-EdgeRemoteDebuggingPort
```PowerShell

   Get-EdgeRemoteDebuggingPort
````

### SYNTAX
```PowerShell
Get-EdgeRemoteDebuggingPort [<CommonParameters>]
````

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Get-Webbrowser
```PowerShell

   Get-Webbrowser
````

### SYNTAX
```PowerShell
Get-Webbrowser [<CommonParameters>]
````

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Get-WebbrowserTabDomNodes
```PowerShell

   Get-WebbrowserTabDomNodes            --> wl
````

### SYNTAX
```PowerShell
Get-WebbrowserTabDomNodes [-QuerySelector] <string[]>
    [[-ModifyScript] <string>] [-Edge] [-Chrome] [-Page
    <Object>] [-ByReference <psobject>] [-NoAutoSelectTab]
    [<CommonParameters>]
````

### PARAMETERS
    -ByReference <psobject>
        Browser session reference object
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chrome
        Use Google Chrome browser
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Use Microsoft Edge browser
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false
    -ModifyScript <string>
        The script to modify the output of the query selector, e.g. e.outerHTML or e.outerHTML='hello world'
        Required?                    false
        Position?                    1
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -NoAutoSelectTab
        Prevent automatic tab selection
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Page <Object>
        Browser page object reference
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -QuerySelector <string[]>
        The query selector string or array of strings to use for selecting DOM nodes
        Required?                    true
        Position?                    0
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Import-BrowserBookmarks
```PowerShell

   Import-BrowserBookmarks
````

### SYNOPSIS
    Imports bookmarks from a file or collection into a web browser.

### SYNTAX
```PowerShell
Import-BrowserBookmarks [-Chrome] [-Edge] [-Firefox]
    [-WhatIf] [-Confirm] [<CommonParameters>]
Import-BrowserBookmarks [[-InputFile] <String>] [-Chrome]
    [-Edge] [-Firefox] [-WhatIf] [-Confirm]
    [<CommonParameters>]
Import-BrowserBookmarks [[-Bookmarks] <Array>] [-Chrome]
    [-Edge] [-Firefox] [-WhatIf] [-Confirm]
    [<CommonParameters>]
````

### DESCRIPTION
    Imports bookmarks into Microsoft Edge or Google Chrome from either a CSV file or
    a collection of bookmark objects. The bookmarks are added to the browser's
    bookmark bar or specified folders. Firefox import is not currently supported.

### PARAMETERS
    -InputFile <String>
        The path to a CSV file containing bookmarks to import. The CSV should have
        columns for Name, URL, Folder, DateAdded, and DateModified.
        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    -Bookmarks <Array>
        An array of bookmark objects to import. Each object should have properties for
        Name, URL, Folder, DateAdded, and DateModified.
        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    -Chrome [<SwitchParameter>]
        Switch to import bookmarks into Google Chrome.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    -Edge [<SwitchParameter>]
        Switch to import bookmarks into Microsoft Edge.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    -Firefox [<SwitchParameter>]
        Switch to indicate Firefox as target (currently not supported).
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    -WhatIf [<SwitchParameter>]
        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    -Confirm [<SwitchParameter>]
        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Invoke-WebbrowserEvaluation
```PowerShell

   Invoke-WebbrowserEvaluation          --> et, Eval
````

### SYNOPSIS
    Executes JavaScript code in a selected web browser tab.

### SYNTAX
```PowerShell
Invoke-WebbrowserEvaluation [[-Scripts] <Object[]>]
    [-Inspect] [-NoAutoSelectTab] [-Edge] [-Chrome] [-Page
    <Object>] [-ByReference <PSObject>] [<CommonParameters>]
````

### DESCRIPTION
    Executes JavaScript code in a selected browser tab with support for async/await,
    promises, and data synchronization between PowerShell and the browser context.
    Can execute code from strings, files, or URLs.
    This function provides comprehensive access to browser APIs including IndexedDB,
    localStorage, sessionStorage, and other web platform features. It includes
    built-in error handling, timeout management, and support for yielding multiple
    results from generator functions.
    The function uses Chrome DevTools Protocol (CDP) debugging connections, which
    provides privileged access that bypasses standard JavaScript security restrictions.
    This enables access to storage APIs, cross-origin resources (within the same tab),
    and other browser features that would normally be restricted in standard web contexts.
    Key capabilities:
    - Async/await and Promise support
    - Generator functions with yield support
    - Data synchronization via $Global:Data
    - Privileged access to browser storage APIs
    - Bypasses same-origin policy restrictions for current page storage
    - IndexedDB enumeration and data extraction
    - DOM manipulation and web API access
    - Error handling and timeout management

### PARAMETERS
    -Scripts <Object[]>
        JavaScript code to execute. Can be string content, file paths, or URLs.
        Accepts pipeline input.
        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Aliases
        Accept wildcard characters?  false
    -Inspect [<SwitchParameter>]
        Adds debugger statement before executing to enable debugging.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    -NoAutoSelectTab [<SwitchParameter>]
        Prevents automatic tab selection if no tab is currently selected.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    -Edge [<SwitchParameter>]
        Selects Microsoft Edge browser for execution.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    -Chrome [<SwitchParameter>]
        Selects Google Chrome browser for execution.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    -Page <Object>
        Browser page object for execution when using ByReference mode.
        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    -ByReference <PSObject>
        Session reference object when using ByReference mode.
        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

### NOTES
```PowerShell

       Requires the Windows 10+ Operating System
   -------------------------- EXAMPLE 1 --------------------------
   PS C:\> Execute simple JavaScript
   Invoke-WebbrowserEvaluation "document.title = 'hello world'"
   -------------------------- EXAMPLE 2 --------------------------
   PS>
   Synchronizing data
   Select-WebbrowserTab -Force;
   $Global:Data = @{ files= (Get-ChildItem *.* -file | % FullName)};
   [int] $number = Invoke-WebbrowserEvaluation "
       document.body.innerHTML = JSON.stringify(data.files);
       data.title = document.title;
       return 123;
   ";
   Write-Host "
       Document title : $($Global:Data.title)
       return value   : $Number
   ";
   -------------------------- EXAMPLE 3 --------------------------
   PS>
   Support for promises
   Select-WebbrowserTab -Force;
   Invoke-WebbrowserEvaluation "
       let myList = [];
       return new Promise((resolve) => {
           let i = 0;
           let a = setInterval(() => {
               myList.push(++i);
               if (i == 10) {
                   clearInterval(a);
                   resolve(myList);
               }
           }, 1000);
       });
   "
   -------------------------- EXAMPLE 4 --------------------------
   PS>
   Support for promises and more
   this function returns all rows of all tables/datastores of all databases of indexedDb in the selected tab
   beware, not all websites use indexedDb, it could return an empty set
   Select-WebbrowserTab -Force;
   Set-WebbrowserTabLocation "https://www.youtube.com/"
   Start-Sleep 3
   $AllIndexedDbData = Invoke-WebbrowserEvaluation "
       // enumerate all indexedDB databases
       for (let db of await indexedDB.databases()) {
           // request to open database
           let openRequest = await indexedDB.open(db.name);
           // wait for eventhandlers to be called
           await new Promise((resolve,reject) => {
               openRequest.onsuccess = resolve;
               openRequest.onerror = reject
           });
           // obtain reference
           let openedDb = openRequest.result;
           // initialize result
           let result = { DatabaseName: db.name, Version: db.version, Stores: [] }
           // itterate object store names
           for (let i = 0; i < openedDb.objectStoreNames.length; i++) {
               // reference
               let storeName = openedDb.objectStoreNames[i];
               // start readonly transaction
               let tr = openedDb.transaction(storeName);
               // get objectstore handle
               let store = tr.objectStore(storeName);
               // request all data
               let getRequest = store.getAll();
               // await result
               await new Promise((resolve,reject) => {
                   getRequest.onsuccess = resolve;
                   getRequest.onerror = reject;
               });
               // add result
               result.Stores.push({ StoreName: storeName, Data: getRequest.result});
           }
           // stream this database contents to the PowerShell pipeline, and continue
           yield result;
       }
   ";
   $AllIndexedDbData | Out-Host
   # SECURITY NOTE: This basic example works because the module uses Chrome DevTools
   # Protocol (CDP) debugging access, which bypasses normal JavaScript security
   # restrictions. Standard web pages cannot access IndexedDB from other origins,
   # but this debugging connection has the same privileges as the website itself.
   # See the enhanced example below for more details on security considerations.
   -------------------------- EXAMPLE 5 --------------------------
   PS>
   Enhanced IndexedDB enumeration with metadata and error handling
   This enhanced approach provides more comprehensive IndexedDB data extraction including
   database counts, error handling, and metadata. Unlike the basic example above, this
   version handles security restrictions, provides detailed store information, and
   includes record counts without necessarily retrieving all data.
   Select-WebbrowserTab -Force;
   Set-WebbrowserTabLocation "https://www.youtube.com/"
   Start-Sleep 3
   $EnhancedIndexedDbData = Invoke-WebbrowserEvaluation "
       // Enhanced IndexedDB enumeration with comprehensive error handling
       let results = [];
       for (let dbInfo of await indexedDB.databases()) {
           try {
               // Open database with timeout
               let db = await new Promise((resolve, reject) => {
                   let req = indexedDB.open(dbInfo.name);
                   req.onsuccess = () => resolve(req.result);
                   req.onerror = () => reject(req.error);
                   setTimeout(() => reject(new Error('Database open timeout')), 5000);
               });
               let dbResult = {
                   DatabaseName: dbInfo.name,
                   Version: dbInfo.version,
                   ObjectStoreCount: db.objectStoreNames.length,
                   Stores: []
               };
               // Process each object store
               for (let i = 0; i < db.objectStoreNames.length; i++) {
                   let storeName = db.objectStoreNames[i];
                   try {
                       let transaction = db.transaction(storeName, 'readonly');
                       let store = transaction.objectStore(storeName);
                       // Get record count (faster than retrieving all data)
                       let count = await new Promise((resolve, reject) => {
                           let req = store.count();
                           req.onsuccess = () => resolve(req.result);
                           req.onerror = () => reject(req.error);
                           setTimeout(() => reject(new Error('Count timeout')), 3000);
                       });
                       dbResult.Stores.push({
                           StoreName: storeName,
                           RecordCount: count,
                           KeyPath: store.keyPath,
                           AutoIncrement: store.autoIncrement,
                           IndexNames: Array.from(store.indexNames)
                       });
                   } catch (storeError) {
                       dbResult.Stores.push({
                           StoreName: storeName,
                           Error: storeError.message
                       });
                   }
               }
               results.push(dbResult);
               db.close();
           } catch (dbError) {
               results.push({
                   DatabaseName: dbInfo.name,
                   Error: dbError.message
               });
           }
       }
       yield results;
   ";
   $EnhancedIndexedDbData | ConvertTo-Json -Depth 10
   # Key differences from the basic example:
   # 1. Includes error handling for database access issues
   # 2. Provides metadata (KeyPath, AutoIncrement, IndexNames)
   # 3. Gets record counts without retrieving all data (more efficient)
   # 4. Handles timeout scenarios
   # 5. Returns structured information about database schema
   # 6. More suitable for large databases where retrieving all data would be slow
   # SECURITY CONSIDERATIONS FOR INDEXEDDB ACCESS:
   # Both examples work because this module uses Chrome DevTools Protocol (CDP) through
   # the debugging port, which bypasses standard JavaScript security restrictions:
   #
   # Standard JavaScript Limitations:
   # - Same-origin policy restricts access to IndexedDB from other origins
   # - Some databases may be hidden or protected by browser security features
   # - Cross-origin database access is typically blocked
   # - Service worker databases may have additional protection
   #
   # How this example bypasses restrictions:
   # - Uses CDP debugging connection (--remote-debugging-port) for privileged access
   # - Executes in the context of the actual page, not a sandboxed environment
   # - Has the same permissions as the website itself for its own storage
   # - Can access all databases created by the current origin/domain
   #
   # Limitations Even With CDP:
   # - Cannot access databases from other origins/domains in the same browser
   # - Cannot access databases from other browser profiles or private browsing
   # - Some browser extensions may create isolated storage not accessible via JavaScript
   #
   # Alternative Approaches for Maximum Access:
   # - Use GenXdev.Webbrowser with multiple tabs from different origins
   # - Combine with file system access to browser profile directories (when possible)
   # - Use browser automation to navigate between different domains
   # - Consider using CDP Storage domain directly (advanced, not implemented in basic examples)
   -------------------------- EXAMPLE 6 --------------------------
   PS>
   Support for yielded pipeline results
   Select-WebbrowserTab -Force;
   Invoke-WebbrowserEvaluation "
       for (let i = 0; i < 10; i++) {
           await (new Promise((resolve) => setTimeout(resolve, 1000)));
           yield i;
       }
   ";
   -------------------------- EXAMPLE 7 --------------------------
   PS>Get-ChildItem *.js | Invoke-WebbrowserEvaluation -Edge
   -------------------------- EXAMPLE 8 --------------------------
   PS>ls *.js | et -e
````

<br/><hr/><br/>


##	Open-BrowserBookmarks
```PowerShell

   Open-BrowserBookmarks                --> sites
````

### SYNTAX
```PowerShell
Open-BrowserBookmarks [[-Queries] <string[]>] [[-Count]
    <int>] [-Edge] [-Chrome] [-Firefox] [-Monitor <int>]
    [-SideBySide] [-Private] [-Force] [-FullScreen]
    [-ShowWindow] [-Width <int>] [-Height <int>] [-X <int>]
    [-Y <int>] [-Left] [-Right] [-Top] [-Bottom] [-Centered]
    [-ApplicationMode] [-NoBrowserExtensions] [-AcceptLang
    <string>] [-KeysToSend <string[]>] [-FocusWindow]
    [-SetForeground] [-Minimize] [-Maximize] [-RestoreFocus]
    [-NewWindow] [-Chromium] [-All] [-DisablePopupBlocker]
    [-SendKeyEscape] [-SendKeyHoldKeyboardFocus]
    [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds
    <int>] [-NoBorders] [-SessionOnly] [-ClearSession]
    [-SkipSession] [<CommonParameters>]
````

### PARAMETERS
    -AcceptLang <string>
        Set the browser accept-lang http header
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      lang, locale
        Dynamic?                     false
        Accept wildcard characters?  false
    -All
        Opens in all registered modern browsers
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -ApplicationMode
        Hide the browser controls
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      a, app, appmode
        Dynamic?                     false
        Accept wildcard characters?  false
    -Bottom
        Place browser window on the bottom side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Centered
        Place browser window in the center of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chrome
        Select in Google Chrome
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chromium
        Opens in Microsoft Edge or Google Chrome, depending on what the default browser is
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      c
        Dynamic?                     false
        Accept wildcard characters?  false
    -ClearSession
        Clear alternative settings stored in session for AI preferences
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Count <int>
        Maximum number of urls to open
        Required?                    false
        Position?                    1
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -DisablePopupBlocker
        Disable the popup blocker
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      allowpopups
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Select in Microsoft Edge
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false
    -Firefox
        Select in Firefox
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ff
        Dynamic?                     false
        Accept wildcard characters?  false
    -FocusWindow
        Focus the browser window after opening
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fw, focus
        Dynamic?                     false
        Accept wildcard characters?  false
    -Force
        Force enable debugging port, stopping existing browsers if needed
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -FullScreen
        Opens in fullscreen mode
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fs, f
        Dynamic?                     false
        Accept wildcard characters?  false
    -Height <int>
        The initial height of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -KeysToSend <string[]>
        Keystrokes to send to the Browser window, see documentation for cmdlet GenXdev.Windows\Send-Key
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Left
        Place browser window on the left side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Maximize
        Maximize the window after positioning
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Minimize
        Minimize the window after positioning
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Monitor <int>
        The monitor to use, 0 = default, -1 is discard, -2 = Configured secondary monitor
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      m, mon
        Dynamic?                     false
        Accept wildcard characters?  false
    -NewWindow
        Do not re-use existing browser window, instead, create a new one
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      nw, new
        Dynamic?                     false
        Accept wildcard characters?  false
    -NoBorders
        Removes the borders of the browser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      nb
        Dynamic?                     false
        Accept wildcard characters?  false
    -NoBrowserExtensions
        Prevent loading of browser extensions
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      de, ne, NoExtensions
        Dynamic?                     false
        Accept wildcard characters?  false
    -Private
        Opens in incognito/private browsing mode
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      incognito, inprivate
        Dynamic?                     false
        Accept wildcard characters?  false
    -Queries <string[]>
        Search terms to filter bookmarks
        Required?                    false
        Position?                    0
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Parameter set name           (All)
        Aliases                      q, Name, Text, Query
        Dynamic?                     false
        Accept wildcard characters?  false
    -RestoreFocus
        Restore PowerShell window focus
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      rf, bg
        Dynamic?                     false
        Accept wildcard characters?  false
    -Right
        Place browser window on the right side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyDelayMilliSeconds <int>
        Delay between sending different key sequences in milliseconds
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      DelayMilliSeconds
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyEscape
        Escape control characters when sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      Escape
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyHoldKeyboardFocus
        Prevent returning keyboard focus to PowerShell after sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      HoldKeyboardFocus
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyUseShiftEnter
        Send Shift+Enter instead of regular Enter for line breaks
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      UseShiftEnter
        Dynamic?                     false
        Accept wildcard characters?  false
    -SessionOnly
        Use alternative settings stored in session for AI preferences
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -SetForeground
        Set the browser window to foreground after opening
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fg
        Dynamic?                     false
        Accept wildcard characters?  false
    -ShowWindow
        Show the browser window (not 1d or hidden)
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      sw
        Dynamic?                     false
        Accept wildcard characters?  false
    -SideBySide
        Will either set the window fullscreen on a different monitor than Powershell, or side by side with Powershell on the same monitor
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      sbs
        Dynamic?                     false
        Accept wildcard characters?  false
    -SkipSession
        Store settings only in persistent preferences without affecting session
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      FromPreferences
        Dynamic?                     false
        Accept wildcard characters?  false
    -Top
        Place browser window on the top side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Width <int>
        The initial width of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -X <int>
        The initial X position of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Y <int>
        The initial Y position of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Open-Webbrowser
```PowerShell

   Open-Webbrowser                      --> wb
````

### SYNTAX
```PowerShell
Open-Webbrowser [[-Url] <string[]>] [[-Monitor] <int>]
    [-Width <int>] [-Height <int>] [-X <int>] [-Y <int>]
    [-AcceptLang <string>] [-Force] [-Edge] [-Chrome]
    [-Chromium] [-Firefox] [-All] [-Left] [-Right] [-Top]
    [-Bottom] [-Centered] [-FullScreen] [-Private]
    [-ApplicationMode] [-NoBrowserExtensions]
    [-DisablePopupBlocker] [-NewWindow] [-FocusWindow]
    [-SetForeground] [-Maximize] [-PassThru] [-NoBorders]
    [-RestoreFocus] [-SideBySide] [-KeysToSend <string[]>]
    [-SendKeyEscape] [-SendKeyHoldKeyboardFocus]
    [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds
    <int>] [-SessionOnly] [-ClearSession] [-SkipSession]
    [<CommonParameters>]
````

### PARAMETERS
    -AcceptLang <string>
        Set the browser accept-lang http header
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      lang, locale
        Dynamic?                     false
        Accept wildcard characters?  false
    -All
        Opens in all registered modern browsers
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -ApplicationMode
        Hide the browser controls
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      a, app, appmode
        Dynamic?                     false
        Accept wildcard characters?  false
    -Bottom
        Place browser window on the bottom side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Centered
        Place browser window in the center of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chrome
        Opens in Google Chrome
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chromium
        Opens in Microsoft Edge or Google Chrome, depending on what the default browser is
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      c
        Dynamic?                     false
        Accept wildcard characters?  false
    -ClearSession
        Clear alternative settings stored in session for AI preferences
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -DisablePopupBlocker
        Disable the popup blocker
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      allowpopups
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Opens in Microsoft Edge
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false
    -Firefox
        Opens in Firefox
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ff
        Dynamic?                     false
        Accept wildcard characters?  false
    -FocusWindow
        Focus the browser window after opening
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fw, focus
        Dynamic?                     false
        Accept wildcard characters?  false
    -Force
        Force enable debugging port, stopping existing browsers if needed
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -FullScreen
        Opens in fullscreen mode
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fs, f
        Dynamic?                     false
        Accept wildcard characters?  false
    -Height <int>
        The initial height of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -KeysToSend <string[]>
        Keystrokes to send to the Window, see documentation for cmdlet GenXdev.Windows\Send-Key
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Left
        Place browser window on the left side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Maximize
        Maximize the window after positioning
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Monitor <int>
        The monitor to use, 0 = default, -1 is discard, -2 = Configured secondary monitor, defaults to $Global:DefaultSecondaryMonitor or 2 if not found
        Required?                    false
        Position?                    1
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      m, mon
        Dynamic?                     false
        Accept wildcard characters?  false
    -NewWindow
        Do not re-use existing browser window, instead, create a new one
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      nw, new
        Dynamic?                     false
        Accept wildcard characters?  false
    -NoBorders
        Removes the borders of the window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      nb
        Dynamic?                     false
        Accept wildcard characters?  false
    -NoBrowserExtensions
        Prevent loading of browser extensions
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      de, ne, NoExtensions
        Dynamic?                     false
        Accept wildcard characters?  false
    -PassThru
        Returns a PowerShell object of the browserprocess
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      pt
        Dynamic?                     false
        Accept wildcard characters?  false
    -Private
        Opens in incognito/private browsing mode
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      incognito, inprivate
        Dynamic?                     false
        Accept wildcard characters?  false
    -RestoreFocus
        Restore PowerShell window focus
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      rf, bg
        Dynamic?                     false
        Accept wildcard characters?  false
    -Right
        Place browser window on the right side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyDelayMilliSeconds <int>
        Delay between different input strings in milliseconds when sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      DelayMilliSeconds
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyEscape
        Escape control characters and modifiers when sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      Escape
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyHoldKeyboardFocus
        Hold keyboard focus on target window when sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      HoldKeyboardFocus
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyUseShiftEnter
        Use Shift+Enter instead of Enter when sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      UseShiftEnter
        Dynamic?                     false
        Accept wildcard characters?  false
    -SessionOnly
        Use alternative settings stored in session for AI preferences
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -SetForeground
        Set the browser window to foreground after opening
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fg
        Dynamic?                     false
        Accept wildcard characters?  false
    -SideBySide
        Position browser window either fullscreen on different monitor than PowerShell, or side by side with PowerShell on the same monitor
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      sbs
        Dynamic?                     false
        Accept wildcard characters?  false
    -SkipSession
        Store settings only in persistent preferences without affecting session
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      FromPreferences
        Dynamic?                     false
        Accept wildcard characters?  false
    -Top
        Place browser window on the top side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Url <string[]>
        The URLs to open in the browser
        Required?                    false
        Position?                    0
        Accept pipeline input?       true (ByValue)
        Parameter set name           (All)
        Aliases                      Value, Uri, FullName, Website, WebsiteUrl
        Dynamic?                     false
        Accept wildcard characters?  false
    -Width <int>
        The initial width of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -X <int>
        The initial X position of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Y <int>
        The initial Y position of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Open-WebbrowserSideBySide
```PowerShell

   Open-WebbrowserSideBySide            --> wbn
````

### SYNTAX
```PowerShell
Open-WebbrowserSideBySide [[-Url] <string[]>] [[-Monitor]
    <int>] [-Width <int>] [-Height <int>] [-X <int>] [-Y
    <int>] [-AcceptLang <string>] [-Force] [-Edge] [-Chrome]
    [-Chromium] [-Firefox] [-All] [-Left] [-Right] [-Top]
    [-Bottom] [-Centered] [-FullScreen] [-Private]
    [-ApplicationMode] [-NoBrowserExtensions]
    [-DisablePopupBlocker] [-NewWindow] [-FocusWindow]
    [-SetForeground] [-Maximize] [-PassThru] [-NoBorders]
    [-RestoreFocus] [-SideBySide] [-KeysToSend <string[]>]
    [-SendKeyEscape] [-SendKeyHoldKeyboardFocus]
    [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds
    <int>] [-SessionOnly] [-ClearSession] [-SkipSession]
    [<CommonParameters>]
````

### PARAMETERS
    -AcceptLang <string>
        Set the browser accept-lang http header
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      lang, locale
        Dynamic?                     false
        Accept wildcard characters?  false
    -All
        Opens in all registered modern browsers
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -ApplicationMode
        Hide the browser controls
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      a, app, appmode
        Dynamic?                     false
        Accept wildcard characters?  false
    -Bottom
        Place browser window on the bottom side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Centered
        Place browser window in the center of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chrome
        Opens in Google Chrome
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chromium
        Opens in Microsoft Edge or Google Chrome, depending on what the default browser is
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      c
        Dynamic?                     false
        Accept wildcard characters?  false
    -ClearSession
        Clear alternative settings stored in session for AI preferences
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -DisablePopupBlocker
        Disable the popup blocker
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      allowpopups
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Opens in Microsoft Edge
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false
    -Firefox
        Opens in Firefox
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ff
        Dynamic?                     false
        Accept wildcard characters?  false
    -FocusWindow
        Focus the browser window after opening
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fw, focus
        Dynamic?                     false
        Accept wildcard characters?  false
    -Force
        Force enable debugging port, stopping existing browsers if needed
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -FullScreen
        Opens in fullscreen mode
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fs, f
        Dynamic?                     false
        Accept wildcard characters?  false
    -Height <int>
        The initial height of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -KeysToSend <string[]>
        Keystrokes to send to the Window, see documentation for cmdlet GenXdev.Windows\Send-Key
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Left
        Place browser window on the left side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Maximize
        Maximize the window after positioning
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Monitor <int>
        The monitor to use, 0 = default, -1 is discard, -2 = Configured secondary monitor, defaults to $Global:DefaultSecondaryMonitor or 2 if not found
        Required?                    false
        Position?                    1
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      m, mon
        Dynamic?                     false
        Accept wildcard characters?  false
    -NewWindow
        Do not re-use existing browser window, instead, create a new one
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      nw, new
        Dynamic?                     false
        Accept wildcard characters?  false
    -NoBorders
        Removes the borders of the window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      nb
        Dynamic?                     false
        Accept wildcard characters?  false
    -NoBrowserExtensions
        Prevent loading of browser extensions
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      de, ne, NoExtensions
        Dynamic?                     false
        Accept wildcard characters?  false
    -PassThru
        Returns a PowerShell object of the browserprocess
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      pt
        Dynamic?                     false
        Accept wildcard characters?  false
    -Private
        Opens in incognito/private browsing mode
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      incognito, inprivate
        Dynamic?                     false
        Accept wildcard characters?  false
    -RestoreFocus
        Restore PowerShell window focus
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      rf, bg
        Dynamic?                     false
        Accept wildcard characters?  false
    -Right
        Place browser window on the right side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyDelayMilliSeconds <int>
        Delay between different input strings in milliseconds when sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      DelayMilliSeconds
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyEscape
        Escape control characters and modifiers when sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      Escape
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyHoldKeyboardFocus
        Hold keyboard focus on target window when sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      HoldKeyboardFocus
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyUseShiftEnter
        Use Shift+Enter instead of Enter when sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      UseShiftEnter
        Dynamic?                     false
        Accept wildcard characters?  false
    -SessionOnly
        Use alternative settings stored in session for AI preferences
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -SetForeground
        Set the browser window to foreground after opening
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fg
        Dynamic?                     false
        Accept wildcard characters?  false
    -SideBySide
        Position browser window either fullscreen on different monitor than PowerShell, or side by side with PowerShell on the same monitor
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      sbs
        Dynamic?                     false
        Accept wildcard characters?  false
    -SkipSession
        Store settings only in persistent preferences without affecting session
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      FromPreferences
        Dynamic?                     false
        Accept wildcard characters?  false
    -Top
        Place browser window on the top side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Url <string[]>
        The URLs to open in the browser
        Required?                    false
        Position?                    0
        Accept pipeline input?       true (ByValue)
        Parameter set name           (All)
        Aliases                      Value, Uri, FullName, Website, WebsiteUrl
        Dynamic?                     false
        Accept wildcard characters?  false
    -Width <int>
        The initial width of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -X <int>
        The initial X position of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Y <int>
        The initial Y position of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Select-WebbrowserTab
```PowerShell

   Select-WebbrowserTab                 --> st
````

### SYNTAX
```PowerShell
Select-WebbrowserTab [[-Id] <int>] [-Monitor <int>] [-Width
    <int>] [-Height <int>] [-X <int>] [-Y <int>]
    [-AcceptLang <string>] [-FullScreen] [-Private]
    [-Chromium] [-Firefox] [-All] [-Left] [-Right] [-Top]
    [-Bottom] [-Centered] [-ApplicationMode]
    [-NoBrowserExtensions] [-DisablePopupBlocker]
    [-RestoreFocus] [-NewWindow] [-FocusWindow]
    [-SetForeground] [-Maximize] [-KeysToSend <string[]>]
    [-SendKeyEscape] [-SendKeyHoldKeyboardFocus]
    [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds
    <int>] [-Edge] [-Chrome] [-Force] [<CommonParameters>]
Select-WebbrowserTab [-Name] <string> [-Monitor <int>]
    [-Width <int>] [-Height <int>] [-X <int>] [-Y <int>]
    [-AcceptLang <string>] [-FullScreen] [-Private]
    [-Chromium] [-Firefox] [-All] [-Left] [-Right] [-Top]
    [-Bottom] [-Centered] [-ApplicationMode]
    [-NoBrowserExtensions] [-DisablePopupBlocker]
    [-RestoreFocus] [-NewWindow] [-FocusWindow]
    [-SetForeground] [-Maximize] [-KeysToSend <string[]>]
    [-SendKeyEscape] [-SendKeyHoldKeyboardFocus]
    [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds
    <int>] [-Edge] [-Chrome] [-Force] [<CommonParameters>]
Select-WebbrowserTab -ByReference <psobject> [-Monitor
    <int>] [-Width <int>] [-Height <int>] [-X <int>] [-Y
    <int>] [-AcceptLang <string>] [-FullScreen] [-Private]
    [-Chromium] [-Firefox] [-All] [-Left] [-Right] [-Top]
    [-Bottom] [-Centered] [-ApplicationMode]
    [-NoBrowserExtensions] [-DisablePopupBlocker]
    [-RestoreFocus] [-NewWindow] [-FocusWindow]
    [-SetForeground] [-Maximize] [-KeysToSend <string[]>]
    [-SendKeyEscape] [-SendKeyHoldKeyboardFocus]
    [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds
    <int>] [-Edge] [-Chrome] [-Force] [<CommonParameters>]
````

### PARAMETERS
    -AcceptLang <string>
        Set the browser accept-lang http header
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      lang, locale
        Dynamic?                     false
        Accept wildcard characters?  false
    -All
        Opens in all registered modern browsers
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -ApplicationMode
        Hide the browser controls
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      a, app, appmode
        Dynamic?                     false
        Accept wildcard characters?  false
    -Bottom
        Place browser window on the bottom side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -ByReference <psobject>
        Select tab using reference from Get-ChromiumSessionReference
        Required?                    true
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           ByReference
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Centered
        Place browser window in the center of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chrome
        Opens in Google Chrome
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chromium
        Opens in Microsoft Edge or Google Chrome, depending on what the default browser is
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      c
        Dynamic?                     false
        Accept wildcard characters?  false
    -DisablePopupBlocker
        Disable the popup blocker
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      allowpopups
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Opens in Microsoft Edge
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false
    -Firefox
        Opens in Firefox
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ff
        Dynamic?                     false
        Accept wildcard characters?  false
    -FocusWindow
        Focus the browser window after opening
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fw, focus
        Dynamic?                     false
        Accept wildcard characters?  false
    -Force
        Forces browser restart if needed
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -FullScreen
        Opens in fullscreen mode
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fs, f
        Dynamic?                     false
        Accept wildcard characters?  false
    -Height <int>
        The initial height of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Id <int>
        Tab identifier from the shown list
        Required?                    false
        Position?                    0
        Accept pipeline input?       false
        Parameter set name           ById
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -KeysToSend <string[]>
        Keystrokes to send to the Browser window, see documentation for cmdlet GenXdev.Windows\Send-Key
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Left
        Place browser window on the left side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Maximize
        Maximize the window after positioning
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Monitor <int>
        The monitor to use, 0 = default, -1 is discard, -2 = Configured secondary monitor, defaults to $Global:DefaultSecondaryMonitor or 2 if not found
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      m, mon
        Dynamic?                     false
        Accept wildcard characters?  false
    -Name <string>
        Selects first tab containing this name in URL
        Required?                    true
        Position?                    0
        Accept pipeline input?       false
        Parameter set name           ByName
        Aliases                      Pattern
        Dynamic?                     false
        Accept wildcard characters?  true
    -NewWindow
        Do not re-use existing browser window, instead, create a new one
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      nw, new
        Dynamic?                     false
        Accept wildcard characters?  false
    -NoBrowserExtensions
        Prevent loading of browser extensions
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      de, ne, NoExtensions
        Dynamic?                     false
        Accept wildcard characters?  false
    -Private
        Opens in incognito/private browsing mode
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      incognito, inprivate
        Dynamic?                     false
        Accept wildcard characters?  false
    -RestoreFocus
        Restore PowerShell window focus
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      rf, bg
        Dynamic?                     false
        Accept wildcard characters?  false
    -Right
        Place browser window on the right side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyDelayMilliSeconds <int>
        Delay between sending different key sequences in milliseconds
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      DelayMilliSeconds
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyEscape
        Escape control characters when sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      Escape
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyHoldKeyboardFocus
        Prevent returning keyboard focus to PowerShell after sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      HoldKeyboardFocus
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyUseShiftEnter
        Send Shift+Enter instead of regular Enter for line breaks
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      UseShiftEnter
        Dynamic?                     false
        Accept wildcard characters?  false
    -SetForeground
        Set the browser window to foreground after opening
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fg
        Dynamic?                     false
        Accept wildcard characters?  false
    -Top
        Place browser window on the top side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Width <int>
        The initial width of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -X <int>
        The initial X position of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Y <int>
        The initial Y position of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Set-BrowserVideoFullscreen
```PowerShell

   Set-BrowserVideoFullscreen           --> fsvideo
````

### SYNTAX
```PowerShell
Set-BrowserVideoFullscreen [-WhatIf] [-Confirm]
    [<CommonParameters>]
````

### PARAMETERS
    -Confirm
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      cf
        Dynamic?                     false
        Accept wildcard characters?  false
    -WhatIf
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      wi
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Set-RemoteDebuggerPortInBrowserShortcuts
```PowerShell

   Set-RemoteDebuggerPortInBrowserShortcuts
````

### SYNTAX
```PowerShell
Set-RemoteDebuggerPortInBrowserShortcuts [-WhatIf]
    [-Confirm] [<CommonParameters>]
````

### PARAMETERS
    -Confirm
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      cf
        Dynamic?                     false
        Accept wildcard characters?  false
    -WhatIf
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      wi
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Set-WebbrowserTabLocation
```PowerShell

   Set-WebbrowserTabLocation            --> lt, Nav
````

### SYNTAX
```PowerShell
Set-WebbrowserTabLocation [-Url] <string> [-NoAutoSelectTab]
    [-Page <Object>] [-ByReference <psobject>] [-WhatIf]
    [-Confirm] [<CommonParameters>]
Set-WebbrowserTabLocation [-Url] <string> [-NoAutoSelectTab]
    [-Edge] [-Page <Object>] [-ByReference <psobject>]
    [-WhatIf] [-Confirm] [<CommonParameters>]
Set-WebbrowserTabLocation [-Url] <string> [-NoAutoSelectTab]
    [-Chrome] [-Page <Object>] [-ByReference <psobject>]
    [-WhatIf] [-Confirm] [<CommonParameters>]
````

### PARAMETERS
    -ByReference <psobject>
        Browser session reference object
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chrome
        Navigate using Google Chrome browser
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           Chrome
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false
    -Confirm
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      cf
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Navigate using Microsoft Edge browser
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           Edge
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false
    -NoAutoSelectTab
        Prevent automatic tab selection
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Page <Object>
        Browser page object reference
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Url <string>
        The URL to navigate to
        Required?                    true
        Position?                    0
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -WhatIf
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      wi
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Show-WebsiteInAllBrowsers
```PowerShell

   Show-WebsiteInAllBrowsers
````

### SYNTAX
```PowerShell
Show-WebsiteInAllBrowsers [-Url] <string> [-Monitor <int>]
    [-Width <int>] [-Height <int>] [-X <int>] [-Y <int>]
    [-AcceptLang <string>] [-FullScreen] [-Private] [-Force]
    [-Edge] [-Chrome] [-Chromium] [-Firefox] [-All] [-Left]
    [-Right] [-Top] [-Bottom] [-Centered] [-ApplicationMode]
    [-NoBrowserExtensions] [-DisablePopupBlocker]
    [-RestoreFocus] [-NewWindow] [-FocusWindow]
    [-SetForeground] [-Maximize] [-KeysToSend <string[]>]
    [-SendKeyEscape] [-SendKeyHoldKeyboardFocus]
    [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds
    <int>] [-NoBorders] [-SideBySide] [-SessionOnly]
    [-ClearSession] [-SkipSession] [<CommonParameters>]
````

### PARAMETERS
    -AcceptLang <string>
        Set the browser accept-lang http header
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      lang, locale
        Dynamic?                     false
        Accept wildcard characters?  false
    -All
        Opens in all registered modern browsers
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -ApplicationMode
        Hide the browser controls
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      a, app, appmode
        Dynamic?                     false
        Accept wildcard characters?  false
    -Bottom
        Place browser window on the bottom side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Centered
        Place browser window in the center of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chrome
        Opens in Google Chrome
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false
    -Chromium
        Opens in Microsoft Edge or Google Chrome, depending on what the default browser is
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      c
        Dynamic?                     false
        Accept wildcard characters?  false
    -ClearSession
        Clear alternative settings stored in session for AI preferences.
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -DisablePopupBlocker
        Disable the popup blocker
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      allowpopups
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Opens in Microsoft Edge
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false
    -Firefox
        Opens in Firefox
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ff
        Dynamic?                     false
        Accept wildcard characters?  false
    -FocusWindow
        Focus the browser window after opening
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fw, focus
        Dynamic?                     false
        Accept wildcard characters?  false
    -Force
        Force enable debugging port, stopping existing browsers if needed
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -FullScreen
        Opens in fullscreen mode
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fs, f
        Dynamic?                     false
        Accept wildcard characters?  false
    -Height <int>
        The initial height of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -KeysToSend <string[]>
        Keystrokes to send to the Browser window, see documentation for cmdlet GenXdev.Windows\Send-Key
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Left
        Place browser window on the left side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Maximize
        Maximize the window after positioning
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Monitor <int>
        The monitor to use, 0 = default, -1 is discard, -2 = Configured secondary monitor, defaults to $Global:DefaultSecondaryMonitor or 2 if not found
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      m, mon
        Dynamic?                     false
        Accept wildcard characters?  false
    -NewWindow
        Do not re-use existing browser window, instead, create a new one
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      nw, new
        Dynamic?                     false
        Accept wildcard characters?  false
    -NoBorders
        Removes the borders of the browser window.
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      nb
        Dynamic?                     false
        Accept wildcard characters?  false
    -NoBrowserExtensions
        Prevent loading of browser extensions
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      de, ne, NoExtensions
        Dynamic?                     false
        Accept wildcard characters?  false
    -Private
        Opens in incognito/private browsing mode
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      incognito, inprivate
        Dynamic?                     false
        Accept wildcard characters?  false
    -RestoreFocus
        Restore PowerShell window focus
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      rf, bg
        Dynamic?                     false
        Accept wildcard characters?  false
    -Right
        Place browser window on the right side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyDelayMilliSeconds <int>
        Delay between sending different key sequences in milliseconds
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      DelayMilliSeconds
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyEscape
        Escape control characters when sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      Escape
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyHoldKeyboardFocus
        Prevent returning keyboard focus to PowerShell after sending keys
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      HoldKeyboardFocus
        Dynamic?                     false
        Accept wildcard characters?  false
    -SendKeyUseShiftEnter
        Send Shift+Enter instead of regular Enter for line breaks
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      UseShiftEnter
        Dynamic?                     false
        Accept wildcard characters?  false
    -SessionOnly
        Use alternative settings stored in session for AI preferences.
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -SetForeground
        Set the browser window to foreground after opening
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fg
        Dynamic?                     false
        Accept wildcard characters?  false
    -SideBySide
        Position browser window either fullscreen on different monitor than PowerShell, or side by side with PowerShell on the same monitor.
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      sbs
        Dynamic?                     false
        Accept wildcard characters?  false
    -SkipSession
        Store settings only in persistent preferences without affecting session.
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      FromPreferences
        Dynamic?                     false
        Accept wildcard characters?  false
    -Top
        Place browser window on the top side of the screen
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Url <string>
        The URLs to open in all browsers simultaneously
        Required?                    true
        Position?                    0
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Parameter set name           (All)
        Aliases                      Value, Uri, FullName, Website, WebsiteUrl
        Dynamic?                     false
        Accept wildcard characters?  false
    -Width <int>
        The initial width of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -X <int>
        The initial X position of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -Y <int>
        The initial Y position of the webbrowser window
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


&nbsp;<hr/>
###	GenXdev.Webbrowser.Playwright<hr/>

##	Connect-PlaywrightViaDebuggingPort
```PowerShell

   Connect-PlaywrightViaDebuggingPort
````

### SYNOPSIS
    Connects to an existing browser instance via debugging port.

### SYNTAX
```PowerShell
Connect-PlaywrightViaDebuggingPort [-WsEndpoint] <String>
    [<CommonParameters>]
````

### DESCRIPTION
    Establishes a connection to a running Chromium-based browser instance using the
    WebSocket debugger URL. Creates a Playwright instance and connects over CDP
    (Chrome DevTools Protocol). The connected browser instance is stored in a global
    dictionary for later reference.

### PARAMETERS
    -WsEndpoint <String>
        The WebSocket URL for connecting to the browser's debugging port. This URL
        typically follows the format 'ws://hostname:port/devtools/browser/<id>'.
        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Get-PlaywrightProfileDirectory
```PowerShell

   Get-PlaywrightProfileDirectory
````

### SYNTAX
```PowerShell
Get-PlaywrightProfileDirectory [[-BrowserType] {Chromium |
    Firefox | Webkit}] [<CommonParameters>]
````

### PARAMETERS
    -BrowserType <string>
        The browser type (Chromium, Firefox, or Webkit)
        Required?                    false
        Position?                    0
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Resume-WebbrowserTabVideo
```PowerShell

   Resume-WebbrowserTabVideo            --> wbvideoplay
````

### SYNTAX
```PowerShell
Resume-WebbrowserTabVideo [<CommonParameters>]
````

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Stop-WebbrowserVideos
```PowerShell

   Stop-WebbrowserVideos                --> ssst, wbsst, wbvideostop
````

### SYNTAX
```PowerShell
Stop-WebbrowserVideos [-Edge] [-Chrome] [-WhatIf] [-Confirm]
    [<CommonParameters>]
````

### PARAMETERS
    -Chrome
        Opens in Google Chrome
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false
    -Confirm
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      cf
        Dynamic?                     false
        Accept wildcard characters?  false
    -Edge
        Opens in Microsoft Edge
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false
    -WhatIf
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      wi
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>


##	Unprotect-WebbrowserTab
```PowerShell

   Unprotect-WebbrowserTab              --> wbctrl
````

### SYNTAX
```PowerShell
Unprotect-WebbrowserTab [[-UseCurrent]] [[-Force]]
    [<CommonParameters>]
````

### PARAMETERS
    -Force
        Restart browser if no debugging server detected
        Required?                    false
        Position?                    1
        Accept pipeline input?       false
        Parameter set name           Default
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
    -UseCurrent
        Use current tab instead of selecting a new one
        Required?                    false
        Position?                    0
        Accept pipeline input?       false
        Parameter set name           Default
        Aliases                      current
        Dynamic?                     false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><br/>
