<hr/>

<img src="powershell.jpg" alt="GenXdev" width="50%"/>

<hr/>

### NAME

    GenXdev.Webbrowser

### SYNOPSIS
    A Windows PowerShell module that allows you to run scripts against your casual desktop webbrowser-tab

[![GenXdev.Webbrowser](https://img.shields.io/powershellgallery/v/GenXdev.Webbrowser.svg?style=flat-square&label=GenXdev.Webbrowser)](https://www.powershellgallery.com/packages/GenXdev.Webbrowser/) [![License](https://img.shields.io/github/license/genXdev/GenXdev.Webbrowser?style=flat-square)](./LICENSE)

### FEATURES

    * ✅ full controll of the webbrowser with the 'wbctrl' cmdlet
    * ✅ retreiving and manipulating of webbrowser-tab DOM nodes with 'wl' cmdlet
    * ✅ evaluating javascript-strings, javascript-files in opened webbrowser-tab
    * ✅ adding html script tags, by url, to opened webbrowser-tabs, for normal javascript files or modules
    * ✅ evaluating scripts, with support for async patterns, like promises
    * ✅ evaluating asynchronous scripts, with support for yielded PowerShell pipeline returns
    * ✅ exporting of favourites/bookmarks from Microsoft Edge, Google Chrome or Firefox
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
````PowerShell
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
````
### DEPENDENCIES
[![WinOS - Windows-10 or later](https://img.shields.io/badge/WinOS-Windows--10--10.0.19041--SP0-brightgreen)](https://www.microsoft.com/en-us/windows/get-windows-10)  [![GenXdev.Data](https://img.shields.io/powershellgallery/v/GenXdev.Data.svg?style=flat-square&label=GenXdev.Data)](https://www.powershellgallery.com/packages/GenXdev.Data/) [![GenXdev.Helpers](https://img.shields.io/powershellgallery/v/GenXdev.Helpers.svg?style=flat-square&label=GenXdev.Helpers)](https://www.powershellgallery.com/packages/GenXdev.Helpers/) [![GenXdev.FileSystem](https://img.shields.io/powershellgallery/v/GenXdev.FileSystem.svg?style=flat-square&label=GenXdev.FileSystem)](https://www.powershellgallery.com/packages/GenXdev.FileSystem/) [![GenXdev.Windows](https://img.shields.io/powershellgallery/v/GenXdev.Windows.svg?style=flat-square&label=GenXdev.Windows)](https://www.powershellgallery.com/packages/GenXdev.Windows/)
### INSTALLATION
````PowerShell
Install-Module "GenXdev.Webbrowser"
Import-Module "GenXdev.Webbrowser"
````
### UPDATE
````PowerShell
Update-Module
````
<br/><hr/><hr/><br/>

# Cmdlet Index
### GenXdev.Webbrowser<hr/>
| Command&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | aliases&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Description |
| --- | --- | --- |
| [Approve-FirefoxDebugging](#Approve-FirefoxDebugging) |  | Configures Firefox's debugging and standalone app mode features. |
| [Clear-WebbrowserTabSiteApplicationData](#Clear-WebbrowserTabSiteApplicationData) | clearsitedata | Clears all browser storage data for the current tab in Edge or Chrome. |
| [Close-Webbrowser](#Close-Webbrowser) | wbc | Closes one or more webbrowser instances selectively. |
| [Close-WebbrowserTab](#Close-WebbrowserTab) | ct, closetab | Closes the currently selected webbrowser tab. |
| [Export-BrowserBookmarks](#Export-BrowserBookmarks) |  | Exports browser bookmarks to a JSON file. |
| [Find-BrowserBookmark](#Find-BrowserBookmark) | bookmarks | Finds bookmarks from one or more web browsers. |
| [Get-BrowserBookmark](#Get-BrowserBookmark) | gbm | Returns all bookmarks from installed web browsers. |
| [Get-ChromeRemoteDebuggingPort](#Get-ChromeRemoteDebuggingPort) | get-chromeport | Returns the configured remote debugging port for Google Chrome. |
| [Get-ChromiumRemoteDebuggingPort](#Get-ChromiumRemoteDebuggingPort) | get-browserdebugport | Returns the remote debugging port for the system's default Chromium browser. |
| [Get-ChromiumSessionReference](#Get-ChromiumSessionReference) |  | Gets a serializable reference to the current browser tab session. |
| [Get-DefaultWebbrowser](#Get-DefaultWebbrowser) |  | Returns the configured default web browser for the current user. |
| [Get-EdgeRemoteDebuggingPort](#Get-EdgeRemoteDebuggingPort) |  | Returns the configured remote debugging port for Microsoft Edge browser. |
| [Get-Webbrowser](#Get-Webbrowser) |  | Returns a collection of installed modern web browsers. |
| [Get-WebbrowserTabDomNodes](#Get-WebbrowserTabDomNodes) | wl | Queries and manipulates DOM nodes in the active browser tab using CSS selectors. |
| [Import-BrowserBookmarks](#Import-BrowserBookmarks) |  | Imports bookmarks from a file or collection into a web browser. |
| [Invoke-WebbrowserEvaluation](#Invoke-WebbrowserEvaluation) | eval, et | Executes JavaScript code in a selected web browser tab. |
| [Open-BrowserBookmarks](#Open-BrowserBookmarks) | sites | Opens browser bookmarks that match specified search criteria. |
| [Open-Webbrowser](#Open-Webbrowser) | wb | Opens URLs in one or more browser windows with optional positioning and styling. |
| [Select-WebbrowserTab](#Select-WebbrowserTab) | st, select-browsertab | Selects a browser tab for automation in Chrome or Edge. |
| [Set-BrowserVideoFullscreen](#Set-BrowserVideoFullscreen) | fsvideo | Maximizes the first video element found in the current browser tab. |
| [Set-RemoteDebuggerPortInBrowserShortcuts](#Set-RemoteDebuggerPortInBrowserShortcuts) |  | Updates browser shortcuts to enable remote debugging ports. |
| [Set-WebbrowserTabLocation](#Set-WebbrowserTabLocation) | lt, nav | Navigates the current webbrowser tab to a specified URL. |
| [Show-WebsiteInAllBrowsers](#Show-WebsiteInAllBrowsers) | show-urlinallbrowsers | Opens a URL in multiple browsers simultaneously in a mosaic layout. |

<hr/>
&nbsp;

### GenXdev.Webbrowser.Playwright</hr>
| Command&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | aliases&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Description |
| --- | --- | --- |
| [Close-PlaywrightDriver](#Close-PlaywrightDriver) |  | Closes a Playwright browser instance and removes it from the global cache. |
| [Connect-PlaywrightViaDebuggingPort](#Connect-PlaywrightViaDebuggingPort) |  | Connects to an existing browser instance via debugging port. |
| [Get-PlaywrightDriver](#Get-PlaywrightDriver) |  | Creates or retrieves a configured Playwright browser instance. |
| [Get-PlaywrightProfileDirectory](#Get-PlaywrightProfileDirectory) |  | Gets the Playwright browser profile directory for persistent sessions. |
| [Resume-WebbrowserTabVideo](#Resume-WebbrowserTabVideo) |  | Resumes video playback in a YouTube browser tab. |
| [Stop-WebbrowserVideos](#Stop-WebbrowserVideos) | wbsst | Pauses video playback in all active browser sessions. |
| [Unprotect-WebbrowserTab](#Unprotect-WebbrowserTab) | wbctrl | Takes control of a selected web browser tab for interactive manipulation. |
| [Update-PlaywrightDriverCache](#Update-PlaywrightDriverCache) |  | Maintains the Playwright browser instance cache by removing stale entries. |

<br/><hr/><hr/><br/>


# Cmdlets

&nbsp;<hr/>
###	GenXdev.Webbrowser<hr/> 
NAME
    Approve-FirefoxDebugging
    
SYNOPSIS
    Configures Firefox's debugging and standalone app mode features.
    
    
SYNTAX
    Approve-FirefoxDebugging [<CommonParameters>]
    
    
DESCRIPTION
    Enables remote debugging and standalone app mode (SSB) capabilities in Firefox by
    modifying user preferences in the prefs.js file of all Firefox profile
    directories. This function updates or adds required debugging preferences to
    enable development tools and remote debugging while disabling connection prompts.
    

PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    System.Void
    
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Approve-FirefoxDebugging
    
    Enables remote debugging and SSB features across all Firefox profiles found in
    the current user's AppData directory.
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Clear-WebbrowserTabSiteApplicationData
    
SYNOPSIS
    Clears all browser storage data for the current tab in Edge or Chrome.
    
    
SYNTAX
    Clear-WebbrowserTabSiteApplicationData [-Edge] [-Chrome] [<CommonParameters>]
    
    
DESCRIPTION
    The Clear-WebbrowserTabSiteApplicationData cmdlet executes a JavaScript snippet
    that clears various types of browser storage for the current tab, including:
    - Local storage
    - Session storage
    - Cookies
    - IndexedDB databases
    - Cache storage
    - Service worker registrations
    

PARAMETERS
    -Edge [<SwitchParameter>]
        Specifies to clear data in Microsoft Edge browser.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Chrome [<SwitchParameter>]
        Specifies to clear data in Google Chrome browser.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Clear-WebbrowserTabSiteApplicationData -Edge
    Clears all browser storage data in the current Edge tab.
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > clearsitedata -Chrome
    Clears all browser storage data in the current Chrome tab using the alias.
    ##############################################################################
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Close-Webbrowser
    
SYNOPSIS
    Closes one or more webbrowser instances selectively.
    
    
SYNTAX
    Close-Webbrowser [[-Edge]] [[-Chrome]] [[-Chromium]] [[-Firefox]] [[-IncludeBackgroundProcesses]] [<CommonParameters>]
    
    Close-Webbrowser [[-All]] [[-IncludeBackgroundProcesses]] [<CommonParameters>]
    
    
DESCRIPTION
    Provides granular control over closing web browser instances. Can target specific
    browsers (Edge, Chrome, Firefox) or close all browsers. Supports closing both main
    windows and background processes.
    

PARAMETERS
    -Edge [<SwitchParameter>]
        Closes all Microsoft Edge browser instances.
        
        Required?                    false
        Position?                    1
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Chrome [<SwitchParameter>]
        Closes all Google Chrome browser instances.
        
        Required?                    false
        Position?                    2
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Chromium [<SwitchParameter>]
        Closes the default Chromium-based browser (Edge or Chrome).
        
        Required?                    false
        Position?                    3
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Firefox [<SwitchParameter>]
        Closes all Firefox browser instances.
        
        Required?                    false
        Position?                    4
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -All [<SwitchParameter>]
        Closes all detected modern browser instances.
        
        Required?                    false
        Position?                    1
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -IncludeBackgroundProcesses [<SwitchParameter>]
        Also closes background processes and tasks for the selected browsers.
        
        Required?                    false
        Position?                    5
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Close-Webbrowser -Chrome -Firefox -IncludeBackgroundProcesses
    Closes all Chrome and Firefox instances including background processes
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > wbc -a -bg
    Closes all browser instances including background processes using aliases
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Close-WebbrowserTab
    
SYNOPSIS
    Closes the currently selected webbrowser tab.
    
    
SYNTAX
    Close-WebbrowserTab [-Edge] [-Chrome] [<CommonParameters>]
    
    
DESCRIPTION
    Closes the currently selected webbrowser tab using ChromeDriver's CloseAsync()
    method. If no tab is currently selected, the function will automatically attempt
    to select the last used tab before closing it.
    

PARAMETERS
    -Edge [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Chrome [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Close-WebbrowserTab
    Closes the currently active browser tab
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > ct
    Uses the alias to close the currently active browser tab
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Export-BrowserBookmarks
    
SYNOPSIS
    Exports browser bookmarks to a JSON file.
    
    
SYNTAX
    Export-BrowserBookmarks [-OutputFile] <String> [-Chrome] [-Edge] [-Firefox] [<CommonParameters>]
    
    
DESCRIPTION
    The Export-BrowserBookmarks cmdlet exports bookmarks from a specified web browser
    (Microsoft Edge, Google Chrome, or Mozilla Firefox) to a JSON file. Only one
    browser type can be specified at a time. The bookmarks are exported with full
    preservation of their structure and metadata.
    

PARAMETERS
    -OutputFile <String>
        The path to the JSON file where the bookmarks will be saved. The path will be
        expanded to a full path before use.
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Chrome [<SwitchParameter>]
        Switch parameter to export bookmarks from Google Chrome browser.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Edge [<SwitchParameter>]
        Switch parameter to export bookmarks from Microsoft Edge browser.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Firefox [<SwitchParameter>]
        Switch parameter to export bookmarks from Mozilla Firefox browser.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Export-BrowserBookmarks -OutputFile "C:\MyBookmarks.json" -Edge
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > Export-BrowserBookmarks "C:\MyBookmarks.json" -Chrome
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Find-BrowserBookmark
    
SYNOPSIS
    Finds bookmarks from one or more web browsers.
    
    
SYNTAX
    Find-BrowserBookmark [[-Queries] <String[]>] [-Edge] [-Chrome] [-Firefox] [-Count <Int32>] [-PassThru] [<CommonParameters>]
    
    
DESCRIPTION
    Searches through bookmarks from Microsoft Edge, Google Chrome, or Mozilla Firefox.
    Returns bookmarks that match one or more search queries in their name, URL, or
    folder path. If no queries are provided, returns all bookmarks from the selected
    browsers.
    

PARAMETERS
    -Queries <String[]>
        One or more search terms to find matching bookmarks. Matches are found in the
        bookmark name, URL, or folder path using wildcard pattern matching.
        
        Required?                    false
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Aliases                      
        Accept wildcard characters?  true
        
    -Edge [<SwitchParameter>]
        Switch to include Microsoft Edge bookmarks in the search.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Chrome [<SwitchParameter>]
        Switch to include Google Chrome bookmarks in the search.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Firefox [<SwitchParameter>]
        Switch to include Mozilla Firefox bookmarks in the search.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Count <Int32>
        Maximum number of results to return. Must be a positive integer.
        Default is 99999999.
        
        Required?                    false
        Position?                    named
        Default value                99999999
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -PassThru [<SwitchParameter>]
        Switch to return complete bookmark objects instead of just URLs. Each bookmark
        object contains Name, URL, and Folder properties.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Find-BrowserBookmark -Query "github" -Edge -Chrome -Count 10
    Searches Edge and Chrome bookmarks for "github", returns first 10 URLs
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > bookmarks powershell -e -ff -PassThru
    Searches Edge and Firefox bookmarks for "powershell", returns full objects
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Get-BrowserBookmark
    
SYNOPSIS
    Returns all bookmarks from installed web browsers.
    
    
SYNTAX
    Get-BrowserBookmark [[-Chrome]] [[-Edge]] [<CommonParameters>]
    
    Get-BrowserBookmark [[-Chrome]] [[-Edge]] [[-Firefox]] [<CommonParameters>]
    
    
DESCRIPTION
    Retrieves bookmarks from Microsoft Edge, Google Chrome, or Mozilla Firefox
    browsers installed on the system. The function can filter by browser type and
    returns detailed bookmark information including name, URL, folder location, and
    timestamps.
    

PARAMETERS
    -Chrome [<SwitchParameter>]
        Retrieves bookmarks specifically from Google Chrome browser.
        
        Required?                    false
        Position?                    1
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Edge [<SwitchParameter>]
        Retrieves bookmarks specifically from Microsoft Edge browser.
        
        Required?                    false
        Position?                    2
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Firefox [<SwitchParameter>]
        Retrieves bookmarks specifically from Mozilla Firefox browser.
        
        Required?                    false
        Position?                    3
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    System.Object[]
    
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Get-BrowserBookmark -Edge | Format-Table Name, URL, Folder
    Returns Edge bookmarks formatted as a table showing name, URL and folder.
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > gbm -Chrome | Where-Object URL -like "*github*"
    Returns Chrome bookmarks filtered to only show GitHub-related URLs.
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Get-ChromeRemoteDebuggingPort
    
SYNOPSIS
    Returns the configured remote debugging port for Google Chrome.
    
    
SYNTAX
    Get-ChromeRemoteDebuggingPort [<CommonParameters>]
    
    
DESCRIPTION
    Retrieves and manages the remote debugging port configuration for Google Chrome.
    The function first checks for a custom port number stored in $Global:ChromeDebugPort.
    If not found or invalid, it defaults to port 9222. The port number is then stored
    globally for use by other Chrome automation functions.
    

PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    System.Int32
    Returns the configured Chrome debugging port number.
    
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > $port = Get-ChromeRemoteDebuggingPort
    Write-Host "Chrome debug port: $port"
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > $port = Get-ChromePort
    Write-Host "Chrome debug port: $port"
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Get-ChromiumRemoteDebuggingPort
    
SYNOPSIS
    Returns the remote debugging port for the system's default Chromium browser.
    
    
SYNTAX
    Get-ChromiumRemoteDebuggingPort [-Chrome] [-Edge] [<CommonParameters>]
    
    
DESCRIPTION
    Detects whether Microsoft Edge or Google Chrome is the default browser and
    returns the appropriate debugging port number. If Chrome is the default browser,
    returns the Chrome debugging port. Otherwise returns the Edge debugging port
    (also used when no default browser is detected).
    

PARAMETERS
    -Chrome [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Edge [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    [int] The remote debugging port number for the detected browser.
    
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Get debugging port using full command name
    Get-ChromiumRemoteDebuggingPort
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > Get debugging port using alias
    Get-BrowserDebugPort
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Get-ChromiumSessionReference
    
SYNOPSIS
    Gets a serializable reference to the current browser tab session.
    
    
SYNTAX
    Get-ChromiumSessionReference [<CommonParameters>]
    
    
DESCRIPTION
    Returns a hashtable containing debugger URI, port, and session data for the
    current browser tab. This reference can be used with Select-WebbrowserTab
    -ByReference to reconnect to the same tab, especially useful in background jobs
    or across different PowerShell sessions.
    
    The function validates the existence of an active chrome session and ensures
    the browser controller is still running before returning the session reference.
    

PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    System.Collections.Hashtable
    
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Get a reference to the current chrome tab session
    $sessionRef = Get-ChromiumSessionReference
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > Store the reference and use it later to reconnect
    $ref = Get-ChromiumSessionReference
    Select-WebbrowserTab -ByReference $ref
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Get-DefaultWebbrowser
    
SYNOPSIS
    Returns the configured default web browser for the current user.
    
    
SYNTAX
    Get-DefaultWebbrowser [<CommonParameters>]
    
    
DESCRIPTION
    Retrieves information about the system's default web browser by querying the
    Windows Registry. Returns a hashtable containing the browser's name, description,
    icon path, and executable path. The function checks both user preferences and
    system-wide browser registrations to determine the default browser.
    

PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    System.Collections.Hashtable with keys: Name, Description, Icon, Path
    
    
NOTES
    
    
        Requires Windows 10 or later operating system
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Get detailed information about the default browser
    Get-DefaultWebbrowser | Format-List
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > Launch the default browser with a specific URL
    $browser = Get-DefaultWebbrowser
    & $browser.Path https://www.github.com/
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Get-EdgeRemoteDebuggingPort
    
SYNOPSIS
    Returns the configured remote debugging port for Microsoft Edge browser.
    
    
SYNTAX
    Get-EdgeRemoteDebuggingPort [<CommonParameters>]
    
    
DESCRIPTION
    Retrieves the remote debugging port number used for connecting to Microsoft Edge
    browser's debugging interface. If no custom port is configured via the global
    variable $Global:EdgeDebugPort, returns the default port 9223. The function
    validates any custom port configuration and falls back to the default if invalid.
    

PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    System.Int32
    Returns the port number to use for Edge remote debugging
    
    
NOTES
    
    
        The function ensures $Global:EdgeDebugPort is always set to the returned value
        for consistency across the session.
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Get-EdgeRemoteDebuggingPort
    Returns the configured debug port (default 9223 if not configured)
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Get-Webbrowser
    
SYNOPSIS
    Returns a collection of installed modern web browsers.
    
    
SYNTAX
    Get-Webbrowser [<CommonParameters>]
    
    
DESCRIPTION
    Discovers and returns details about modern web browsers installed on the system.
    Retrieves information including name, description, icon path, executable path and
    default browser status by querying the Windows registry. Only returns browsers
    that have the required capabilities registered in Windows.
    

PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    System.Collections.Hashtable[]
    Returns an array of hashtables containing browser details:
    - Name: Browser application name
    - Description: Browser description
    - Icon: Path to browser icon
    - Path: Path to browser executable
    - IsDefaultBrowser: Boolean indicating if this is the default browser
    
    
NOTES
    
    
        Requires Windows 10 or later Operating System
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Get-Webbrowser | Select-Object Name, Description | Format-Table
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > Get just the default browser
    Get-Webbrowser | Where-Object { $_.IsDefaultBrowser }
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Get-WebbrowserTabDomNodes
    
SYNOPSIS
    Queries and manipulates DOM nodes in the active browser tab using CSS selectors.
    
    
SYNTAX
    Get-WebbrowserTabDomNodes [-QuerySelector] <String[]> [[-ModifyScript] <String>] [-Edge] [-Chrome] [-Page <Object>] [-ByReference <PSObject>] [-NoAutoSelectTab] [<CommonParameters>]
    
    
DESCRIPTION
    Uses browser automation to find elements matching a CSS selector and returns their
    HTML content or executes custom JavaScript on each matched element. This function
    is useful for web scraping and browser automation tasks.
    

PARAMETERS
    -QuerySelector <String[]>
        CSS selector string to find matching DOM elements. Uses standard CSS selector
        syntax like '#id', '.class', 'tag', etc.
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ModifyScript <String>
        JavaScript code to execute on each matched element. The code runs as an async
        function with parameters:
        - e: The matched DOM element
        - i: Index of the element (0-based)
        - n: Complete NodeList of matching elements
        - modifyScript: The script being executed
        
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Edge [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Chrome [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Page <Object>
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ByReference <PSObject>
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -NoAutoSelectTab [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Get HTML of all header divs
    Get-WebbrowserTabDomNodes -QuerySelector "div.header"
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > Pause all videos on the page
    wl "video" "e.pause()"
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Import-BrowserBookmarks
    
SYNOPSIS
    Imports bookmarks from a file or collection into a web browser.
    
    
SYNTAX
    Import-BrowserBookmarks [-Chrome] [-Edge] [-Firefox] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    Import-BrowserBookmarks [[-InputFile] <String>] [-Chrome] [-Edge] [-Firefox] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    Import-BrowserBookmarks [[-Bookmarks] <Array>] [-Chrome] [-Edge] [-Firefox] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    Imports bookmarks into Microsoft Edge or Google Chrome from either a CSV file or
    a collection of bookmark objects. The bookmarks are added to the browser's
    bookmark bar or specified folders. Firefox import is not currently supported.
    

PARAMETERS
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
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Import-BrowserBookmarks -InputFile "C:\MyBookmarks.csv" -Edge
    Imports bookmarks from the CSV file into Microsoft Edge.
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > $bookmarks = @(
        @{
            Name = "Microsoft";
            URL = "https://microsoft.com";
            Folder = "Tech"
        }
    )
    Import-BrowserBookmarks -Bookmarks $bookmarks -Chrome
    Imports a collection of bookmarks into Google Chrome.
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Invoke-WebbrowserEvaluation
    
SYNOPSIS
    Executes JavaScript code in a selected web browser tab.
    
    
SYNTAX
    Invoke-WebbrowserEvaluation [[-Scripts] <Object[]>] [-Inspect] [-NoAutoSelectTab] [-Edge] [-Chrome] [-Page <Object>] [-ByReference <PSObject>] [<CommonParameters>]
    
    
DESCRIPTION
    Executes JavaScript code in a selected browser tab with support for async/await,
    promises, and data synchronization between PowerShell and the browser context.
    Can execute code from strings, files, or URLs.
    

PARAMETERS
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
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
NOTES
    
    
        Requires the Windows 10+ Operating System
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Execute simple JavaScript
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
    
    
    
    
    -------------------------- EXAMPLE 5 --------------------------
    
    PS>
    
    Support for yielded pipeline results
    Select-WebbrowserTab -Force;
    Invoke-WebbrowserEvaluation "
    
        for (let i = 0; i < 10; i++) {
    
            await (new Promise((resolve) => setTimeout(resolve, 1000)));
    
            yield i;
        }
    ";
    
    
    
    
    -------------------------- EXAMPLE 6 --------------------------
    
    PS>Get-ChildItem *.js | Invoke-WebbrowserEvaluation -Edge
    
    
    
    
    
    
    -------------------------- EXAMPLE 7 --------------------------
    
    PS>ls *.js | et -e
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Open-BrowserBookmarks
    
SYNOPSIS
    Opens browser bookmarks that match specified search criteria.
    
    
SYNTAX
    Open-BrowserBookmarks [[-Queries] <String[]>] [[-Count] <Int32>] [-Edge] [-Chrome] [-Firefox] [-Monitor <Int32>] [-Private] [-Force] [-FullScreen] [-ShowWindow] [-Width <Int32>] [-Height <Int32>] [-X <Int32>] [-Y <Int32>] [-Left] [-Right] [-Top] [-Bottom] [-Centered] [-ApplicationMode] [-NoBrowserExtensions] [-AcceptLang <String>] [-KeysToSend <String[]>] [-FocusWindow] [-SetForeground] [-Maximize] [-RestoreFocus] [-NewWindow] [-Chromium] [-All] [-DisablePopupBlocker] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds <Int32>] [-NoBorders] [-SideBySide] [-SessionOnly] [-ClearSession] [-SkipSession] [<CommonParameters>]
    
    
DESCRIPTION
    Searches bookmarks across Microsoft Edge, Google Chrome, and Mozilla Firefox
    browsers based on provided search queries. Opens matching bookmarks in the
    selected browser with configurable window settings and browser modes.
    
    This function provides a comprehensive interface for finding and opening
    browser bookmarks with advanced filtering and display options. It supports
    multiple search criteria and can open results in any installed browser with
    extensive window positioning and behavior customization.
    

PARAMETERS
    -Queries <String[]>
        Search terms used to filter bookmarks by title or URL.
        
        Required?                    false
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Aliases                      
        Accept wildcard characters?  false
        
    -Count <Int32>
        Maximum number of bookmarks to open (default 50).
        
        Required?                    false
        Position?                    2
        Default value                50
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Edge [<SwitchParameter>]
        Use Microsoft Edge browser bookmarks as search source.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Chrome [<SwitchParameter>]
        Use Google Chrome browser bookmarks as search source.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Firefox [<SwitchParameter>]
        Use Mozilla Firefox browser bookmarks as search source.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Monitor <Int32>
        The monitor to use for window placement:
        - 0 = Primary monitor
        - -1 = Discard positioning
        - -2 = Configured secondary monitor
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Private [<SwitchParameter>]
        Opens bookmarks in private/incognito browsing mode.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Force [<SwitchParameter>]
        Forces enabling of debugging port, stops existing browser instances if needed.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -FullScreen [<SwitchParameter>]
        Opens browser windows in fullscreen mode.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ShowWindow [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Width <Int32>
        Sets initial browser window width in pixels.
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Height <Int32>
        Sets initial browser window height in pixels.
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -X <Int32>
        Sets initial browser window X position.
        
        Required?                    false
        Position?                    named
        Default value                -999999
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Y <Int32>
        Sets initial browser window Y position.
        
        Required?                    false
        Position?                    named
        Default value                -999999
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Left [<SwitchParameter>]
        Places browser window on left side of screen.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Right [<SwitchParameter>]
        Places browser window on right side of screen.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Top [<SwitchParameter>]
        Places browser window on top of screen.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Bottom [<SwitchParameter>]
        Places browser window on bottom of screen.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Centered [<SwitchParameter>]
        Centers browser window on screen.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ApplicationMode [<SwitchParameter>]
        Hides browser controls for clean app-like experience.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -NoBrowserExtensions [<SwitchParameter>]
        Prevents loading of browser extensions.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -AcceptLang <String>
        Sets browser accept-language HTTP header.
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -KeysToSend <String[]>
        Keystrokes to send to the Browser window.
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -FocusWindow [<SwitchParameter>]
        Focus the browser window after opening.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SetForeground [<SwitchParameter>]
        Set the browser window to foreground after opening.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Maximize [<SwitchParameter>]
        Maximize the browser window after positioning.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -RestoreFocus [<SwitchParameter>]
        Restores PowerShell window focus after opening bookmarks.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -NewWindow [<SwitchParameter>]
        Creates new browser window instead of reusing existing one.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Chromium [<SwitchParameter>]
        Opens in Microsoft Edge or Google Chrome, depending on what the default
        browser is.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -All [<SwitchParameter>]
        Opens in all registered modern browsers.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -DisablePopupBlocker [<SwitchParameter>]
        Disables the browser's popup blocking functionality.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SendKeyEscape [<SwitchParameter>]
        Escapes control characters when sending keystrokes to the browser.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SendKeyHoldKeyboardFocus [<SwitchParameter>]
        Prevents returning keyboard focus to PowerShell after sending keystrokes.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SendKeyUseShiftEnter [<SwitchParameter>]
        Uses Shift+Enter instead of regular Enter for line breaks when sending keys.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SendKeyDelayMilliSeconds <Int32>
        Delay between sending different key sequences in milliseconds.
        
        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -NoBorders [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SideBySide [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SessionOnly [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ClearSession [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SkipSession [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Open-BrowserBookmarks -Queries "github" -Edge -Count 5
    
    Searches for bookmarks containing "github" in Microsoft Edge and opens the
    first 5 results in the default browser.
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > sites gh -e -c 5
    
    Same as above using aliases - searches Edge bookmarks for "gh" and opens 5
    results in the default browser.
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS > Open-BrowserBookmarks -Queries "development", "tools" -Chrome -Firefox -Left -Count 10
    
    Searches Chrome bookmarks for "development" and "tools", opens first 10
    results in Firefox positioned on the left side of screen.
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Open-Webbrowser
    
SYNOPSIS
    Opens URLs in one or more browser windows with optional positioning and styling.
    
    
SYNTAX
    Open-Webbrowser [[-Url] <String[]>] [[-Monitor] <Int32>] [-Width <Int32>] [-Height <Int32>] [-X <Int32>] [-Y <Int32>] [-AcceptLang <String>] [-Force] [-Edge] [-Chrome] [-Chromium] [-Firefox] [-All] [-Left] [-Right] [-Top] [-Bottom] [-Centered] [-FullScreen] [-Private] [-ApplicationMode] [-NoBrowserExtensions] [-DisablePopupBlocker] [-NewWindow] [-FocusWindow] [-SetForeground] [-Maximize] [-PassThru] [-NoBorders] [-RestoreFocus] [-SideBySide] [-KeysToSend <String[]>] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds <Int32>] [-SessionOnly] [-ClearSession] [-SkipSession] [<CommonParameters>]
    
    
DESCRIPTION
    This function provides an advanced wrapper around browser launching with
    extensive options for window positioning, browser selection, and behavior
    customization. It supports multiple browsers including Edge, Chrome, and
    Firefox with features like private browsing, application mode, and precise
    window management.
    
    Key features:
    - Smart browser detection and selection
    - Window positioning (left, right, top, bottom, centered, fullscreen)
    - Multi-monitor support with automatic or manual monitor selection
    - Private/incognito browsing mode support
    - Application mode for distraction-free browsing
    - Extension and popup blocking options
    - Focus management and window manipulation
    - Batch URL opening across multiple browsers
    - Keystroke automation to browser windows
    
    The function can automatically detect system capabilities and adjust behavior
    accordingly. For browsers not installed on the system, operations are silently
    skipped without errors.
    

PARAMETERS
    -Url <String[]>
        The URLs to open in the browser. Accepts pipeline input and automatically
        handles file paths (converts to file:// URLs). When no URL is provided,
        opens the default GenXdev PowerShell help page.
        
        Required?                    false
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByValue)
        Aliases                      
        Accept wildcard characters?  false
        
    -Monitor <Int32>
        The monitor to use for window placement:
        - 0 = Primary monitor
        - -1 = Discard positioning
        - -2 = Configured secondary monitor (uses $Global:DefaultSecondaryMonitor or
          defaults to monitor 2)
        - 1+ = Specific monitor number
        
        Required?                    false
        Position?                    2
        Default value                -2
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Width <Int32>
        The initial width of the browser window in pixels. When not specified,
        uses the monitor's working area width or half-width for side positioning.
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Height <Int32>
        The initial height of the browser window in pixels. When not specified,
        uses the monitor's working area height or half-height for top/bottom
        positioning.
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -X <Int32>
        The initial X coordinate for window placement. When not specified, uses
        the monitor's left edge. Can be specified relative to the selected monitor.
        
        Required?                    false
        Position?                    named
        Default value                -999999
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Y <Int32>
        The initial Y coordinate for window placement. When not specified, uses
        the monitor's top edge. Can be specified relative to the selected monitor.
        
        Required?                    false
        Position?                    named
        Default value                -999999
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -AcceptLang <String>
        Sets the browser's Accept-Language HTTP header for internationalization.
        Useful for testing websites in different languages.
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Force [<SwitchParameter>]
        Forces enabling of the debugging port by stopping existing browser instances
        if needed. Useful when browser debugging features are required.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Edge [<SwitchParameter>]
        Specifically opens URLs in Microsoft Edge browser.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Chrome [<SwitchParameter>]
        Specifically opens URLs in Google Chrome browser.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Chromium [<SwitchParameter>]
        Opens URLs in either Microsoft Edge or Google Chrome, depending on which
        is set as the default browser. Prefers Chromium-based browsers.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Firefox [<SwitchParameter>]
        Specifically opens URLs in Mozilla Firefox browser.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -All [<SwitchParameter>]
        Opens the specified URLs in all installed modern browsers simultaneously.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Left [<SwitchParameter>]
        Positions the browser window on the left half of the screen.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Right [<SwitchParameter>]
        Positions the browser window on the right half of the screen.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Top [<SwitchParameter>]
        Positions the browser window on the top half of the screen.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Bottom [<SwitchParameter>]
        Positions the browser window on the bottom half of the screen.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Centered [<SwitchParameter>]
        Centers the browser window on the screen using 80% of the screen dimensions.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -FullScreen [<SwitchParameter>]
        Opens the browser in fullscreen mode using F11 key simulation.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Private [<SwitchParameter>]
        Opens the browser in private/incognito browsing mode. Uses InPrivate for
        Edge and incognito for Chrome. Not supported for the default browser mode.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ApplicationMode [<SwitchParameter>]
        Hides browser controls for a distraction-free experience. Creates an app-like
        interface for web applications.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -NoBrowserExtensions [<SwitchParameter>]
        Prevents loading of browser extensions. Uses safe mode for Firefox and
        --disable-extensions for Chromium browsers.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -DisablePopupBlocker [<SwitchParameter>]
        Disables the browser's popup blocking functionality.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -NewWindow [<SwitchParameter>]
        Forces creation of a new browser window instead of reusing existing windows.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -FocusWindow [<SwitchParameter>]
        Gives focus to the browser window after opening.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SetForeground [<SwitchParameter>]
        Brings the browser window to the foreground after opening.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Maximize [<SwitchParameter>]
        Maximizes the browser window after positioning.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -PassThru [<SwitchParameter>]
        Returns PowerShell objects representing the browser processes created.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -NoBorders [<SwitchParameter>]
        Removes the borders of the browser window.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -RestoreFocus [<SwitchParameter>]
        Returns focus to the PowerShell window after opening the browser. Useful
        for automated workflows where you want to continue working in PowerShell.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SideBySide [<SwitchParameter>]
        Position browser window either fullscreen on different monitor than PowerShell,
        or side by side with PowerShell on the same monitor.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -KeysToSend <String[]>
        Keystrokes to send to the browser window after opening. Uses the same
        format as the GenXdev.Windows\Send-Key cmdlet.
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SendKeyEscape [<SwitchParameter>]
        Escapes control characters when sending keystrokes to the browser.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SendKeyHoldKeyboardFocus [<SwitchParameter>]
        Prevents returning keyboard focus to PowerShell after sending keystrokes.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SendKeyUseShiftEnter [<SwitchParameter>]
        Uses Shift+Enter instead of regular Enter for line breaks when sending keys.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SendKeyDelayMilliSeconds <Int32>
        Delay between sending different key sequences in milliseconds.
        
        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SkipSession [<SwitchParameter>]
        Store settings only in persistent preferences without affecting session.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
NOTES
    
    
        Requires Windows 10+ Operating System.
        
        This cmdlet is designed for interactive use and performs window manipulation
        tricks including Alt-Tab keystrokes. Avoid touching keyboard/mouse during
        positioning operations.
        
        For fast launches of multiple URLs:
        - Set Monitor to -1
        - Avoid using positioning switches (-X, -Y, -Left, -Right, -Top, -Bottom,
          -RestoreFocus)
        
        For browsers not installed on the system, operations are silently skipped.
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Open-Webbrowser -Url "https://github.com"
    
    Opens GitHub in the default browser.
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > Open-Webbrowser -Url "https://stackoverflow.com" -Monitor 1 -Left
    
    Opens Stack Overflow in the left half of monitor 1.
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS > wb "https://google.com" -m 0 -fs
    
    Opens Google in fullscreen mode on the primary monitor using aliases.
    
    
    
    
    -------------------------- EXAMPLE 4 --------------------------
    
    PS > Open-Webbrowser -Chrome -Private -NewWindow
    
    Opens a new Chrome window in incognito mode.
    
    
    
    
    -------------------------- EXAMPLE 5 --------------------------
    
    PS > "https://github.com", "https://stackoverflow.com" | Open-Webbrowser -All
    
    Opens multiple URLs in all installed browsers via pipeline.
    
    
    
    
    -------------------------- EXAMPLE 6 --------------------------
    
    PS > Open-Webbrowser -Monitor 0 -Right
    
    Re-positions an already open browser window to the right side of the primary
    monitor.
    
    
    
    
    -------------------------- EXAMPLE 7 --------------------------
    
    PS > Open-Webbrowser -ApplicationMode -Url "https://app.example.com"
    
    Opens a web application in app mode without browser controls.
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Select-WebbrowserTab
    
SYNOPSIS
    Selects a browser tab for automation in Chrome or Edge.
    
    
SYNTAX
    Select-WebbrowserTab [[-Id] <Int32>] [-Monitor <Int32>] [-Width <Int32>] [-Height <Int32>] [-X <Int32>] [-Y <Int32>] [-AcceptLang <String>] [-FullScreen] [-Private] [-Chromium] [-Firefox] [-All] [-Left] [-Right] [-Top] [-Bottom] [-Centered] [-ApplicationMode] [-NoBrowserExtensions] [-DisablePopupBlocker] [-RestoreFocus] [-NewWindow] [-FocusWindow] [-SetForeground] [-Maximize] [-KeysToSend <String[]>] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds <Int32>] [-Edge] [-Chrome] [-Force] [<CommonParameters>]
    
    Select-WebbrowserTab [-Name] <String> [-Monitor <Int32>] [-Width <Int32>] [-Height <Int32>] [-X <Int32>] [-Y <Int32>] [-AcceptLang <String>] [-FullScreen] [-Private] [-Chromium] [-Firefox] [-All] [-Left] [-Right] [-Top] [-Bottom] [-Centered] [-ApplicationMode] [-NoBrowserExtensions] [-DisablePopupBlocker] [-RestoreFocus] [-NewWindow] [-FocusWindow] [-SetForeground] [-Maximize] [-KeysToSend <String[]>] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds <Int32>] [-Edge] [-Chrome] [-Force] [<CommonParameters>]
    
    Select-WebbrowserTab -ByReference <PSObject> [-Monitor <Int32>] [-Width <Int32>] [-Height <Int32>] [-X <Int32>] [-Y <Int32>] [-AcceptLang <String>] [-FullScreen] [-Private] [-Chromium] [-Firefox] [-All] [-Left] [-Right] [-Top] [-Bottom] [-Centered] [-ApplicationMode] [-NoBrowserExtensions] [-DisablePopupBlocker] [-RestoreFocus] [-NewWindow] [-FocusWindow] [-SetForeground] [-Maximize] [-KeysToSend <String[]>] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds <Int32>] [-Edge] [-Chrome] [-Force] [<CommonParameters>]
    
    
DESCRIPTION
    Manages browser tab selection for automation tasks. Can select tabs by ID, name,
    or reference. Shows available tabs when no selection criteria are provided.
    Supports both Chrome and Edge browsers. Handles browser connection and session
    management.
    
    This function provides comprehensive tab selection capabilities for web browser
    automation. It can list available tabs, select specific tabs by various
    criteria, and establish automation connections to the selected tab. The function
    supports both Chrome and Edge browsers with debugging capabilities enabled.
    
    Key features:
    - Tab selection by numeric ID, URL pattern, or session reference
    - Automatic browser detection and connection establishment
    - Session management with state preservation
    - Force restart capabilities when debugging ports are unavailable
    - Integration with browser automation frameworks
    

PARAMETERS
    -Id <Int32>
        Numeric identifier for the tab, shown when listing available tabs.
        
        Required?                    false
        Position?                    1
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Name <String>
        URL pattern to match when selecting a tab. Selects first matching tab.
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  true
        
    -ByReference <PSObject>
        Session reference object from Get-ChromiumSessionReference to select specific tab.
        
        Required?                    true
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Monitor <Int32>
        The monitor to use for window placement:
        - 0 = Primary monitor
        - -1 = Discard positioning
        - -2 = Configured secondary monitor (uses $Global:DefaultSecondaryMonitor or
          defaults to monitor 2)
        - 1+ = Specific monitor number
        
        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Width <Int32>
        The initial width of the browser window in pixels.
        
        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Height <Int32>
        The initial height of the browser window in pixels.
        
        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -X <Int32>
        The initial X coordinate for window placement.
        
        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Y <Int32>
        The initial Y coordinate for window placement.
        
        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -AcceptLang <String>
        Sets the browser's Accept-Language HTTP header for internationalization.
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -FullScreen [<SwitchParameter>]
        Opens the browser in fullscreen mode using F11 key simulation.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Private [<SwitchParameter>]
        Opens the browser in private/incognito browsing mode.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Chromium [<SwitchParameter>]
        Opens URLs in either Microsoft Edge or Google Chrome, depending on which
        is set as the default browser.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Firefox [<SwitchParameter>]
        Specifically opens URLs in Mozilla Firefox browser.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -All [<SwitchParameter>]
        Opens the specified URLs in all installed modern browsers simultaneously.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Left [<SwitchParameter>]
        Positions the browser window on the left half of the screen.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Right [<SwitchParameter>]
        Positions the browser window on the right half of the screen.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Top [<SwitchParameter>]
        Positions the browser window on the top half of the screen.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Bottom [<SwitchParameter>]
        Positions the browser window on the bottom half of the screen.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Centered [<SwitchParameter>]
        Centers the browser window on the screen using 80% of the screen dimensions.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ApplicationMode [<SwitchParameter>]
        Hides browser controls for a distraction-free experience.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -NoBrowserExtensions [<SwitchParameter>]
        Prevents loading of browser extensions.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -DisablePopupBlocker [<SwitchParameter>]
        Disables the browser's popup blocking functionality.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -RestoreFocus [<SwitchParameter>]
        Returns focus to the PowerShell window after opening the browser.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -NewWindow [<SwitchParameter>]
        Forces creation of a new browser window instead of reusing existing windows.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -FocusWindow [<SwitchParameter>]
        Gives focus to the browser window after opening.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SetForeground [<SwitchParameter>]
        Brings the browser window to the foreground after opening.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Maximize [<SwitchParameter>]
        Maximizes the browser window after positioning.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -KeysToSend <String[]>
        Keystrokes to send to the browser window after opening.
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SendKeyEscape [<SwitchParameter>]
        Escapes control characters when sending keystrokes to the browser.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SendKeyHoldKeyboardFocus [<SwitchParameter>]
        Prevents returning keyboard focus to PowerShell after sending keystrokes.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SendKeyUseShiftEnter [<SwitchParameter>]
        Uses Shift+Enter instead of regular Enter for line breaks when sending keys.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SendKeyDelayMilliSeconds <Int32>
        Delay between sending different key sequences in milliseconds.
        
        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Edge [<SwitchParameter>]
        Switch to force selection in Microsoft Edge browser.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Chrome [<SwitchParameter>]
        Switch to force selection in Google Chrome browser.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Force [<SwitchParameter>]
        Switch to force browser restart if needed during selection.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    System.String
    
    System.Management.Automation.PSObject
    
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Select-WebbrowserTab -Id 3 -Chrome -Force
    Selects tab ID 3 in Chrome browser, forcing restart if needed.
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > st -Name "github.com" -e
    Selects first tab containing "github.com" in Edge browser using alias.
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Set-BrowserVideoFullscreen
    
SYNOPSIS
    Maximizes the first video element found in the current browser tab.
    
    
SYNTAX
    Set-BrowserVideoFullscreen [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    Executes JavaScript code to locate and maximize the first video element on the
    current webpage. The video is set to cover the entire viewport with maximum
    z-index to ensure visibility. Page scrollbars are hidden for a clean fullscreen
    experience.
    

PARAMETERS
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
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Set-BrowserVideoFullscreen
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Set-RemoteDebuggerPortInBrowserShortcuts
    
SYNOPSIS
    Updates browser shortcuts to enable remote debugging ports.
    
    
SYNTAX
    Set-RemoteDebuggerPortInBrowserShortcuts [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    Modifies Chrome and Edge browser shortcuts to include remote debugging port
    parameters. This enables automation scripts to interact with the browsers through
    their debugging interfaces. Handles both user-specific and system-wide shortcuts.
    
    The function:
    - Removes any existing debugging port parameters
    - Adds current debugging ports for Chrome and Edge
    - Updates shortcuts in common locations (Desktop, Start Menu, Quick Launch)
    - Requires administrative rights for system-wide shortcuts
    

PARAMETERS
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
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
NOTES
    
    
        Requires administrative access to modify system shortcuts.
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Set-RemoteDebuggerPortInBrowserShortcuts
    Updates all Chrome and Edge shortcuts with their respective debugging ports.
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Set-WebbrowserTabLocation
    
SYNOPSIS
    Navigates the current webbrowser tab to a specified URL.
    
    
SYNTAX
    Set-WebbrowserTabLocation [-Url] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
    
    Set-WebbrowserTabLocation [-Url] <String> [-Edge] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    Set-WebbrowserTabLocation [-Url] <String> [-Chrome] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    Sets the location (URL) of the currently selected webbrowser tab. Supports both
    Edge and Chrome browsers through optional switches. The navigation includes
    validation of the URL and ensures proper page loading through async operations.
    

PARAMETERS
    -Url <String>
        The target URL for navigation. Accepts pipeline input and must be a valid URL
        string. This parameter is required.
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Aliases                      
        Accept wildcard characters?  false
        
    -Edge [<SwitchParameter>]
        Switch parameter to specifically target Microsoft Edge browser. Cannot be used
        together with -Chrome parameter.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Chrome [<SwitchParameter>]
        Switch parameter to specifically target Google Chrome browser. Cannot be used
        together with -Edge parameter.
        
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
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Set-WebbrowserTabLocation -Url "https://github.com/microsoft" -Edge
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > "https://github.com/microsoft" | lt -ch
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Show-WebsiteInAllBrowsers
    
SYNOPSIS
    Opens a URL in multiple browsers simultaneously in a mosaic layout.
    
    
SYNTAX
    Show-WebsiteInAllBrowsers [-Url] <String> [-Monitor <Int32>] [-Width <Int32>] [-Height <Int32>] [-X <Int32>] [-Y <Int32>] [-AcceptLang <String>] [-FullScreen] [-Private] [-Force] [-Edge] [-Chrome] [-Chromium] [-Firefox] [-All] [-Left] [-Right] [-Top] [-Bottom] [-Centered] [-ApplicationMode] [-NoBrowserExtensions] [-DisablePopupBlocker] [-RestoreFocus] [-NewWindow] [-FocusWindow] [-SetForeground] [-Maximize] [-KeysToSend <String[]>] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds <Int32>] [-NoBorders] [-SideBySide] [-SessionOnly] [-ClearSession] [-SkipSession] [<CommonParameters>]
    
    
DESCRIPTION
    This function creates a mosaic layout of browser windows by opening the specified
    URL in Chrome, Edge, Firefox, and a private browsing window. The browsers are
    arranged in a 2x2 grid pattern:
    - Chrome: Top-left quadrant
    - Edge: Bottom-left quadrant
    - Firefox: Top-right quadrant
    - Private window: Bottom-right quadrant
    
    All parameters from Open-Webbrowser are supported and passed through to control
    browser positioning, behavior, and appearance. The function acts as a wrapper
    that applies consistent quadrant positioning while allowing full customization
    of browser launch parameters.
    

PARAMETERS
    -Url <String>
        The URLs to open in all browsers. Accepts pipeline input and can be specified by
        position or through properties.
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Aliases                      
        Accept wildcard characters?  false
        
    -Monitor <Int32>
        The monitor to use for window placement:
        - 0 = Primary monitor
        - -1 = Discard positioning
        - -2 = Configured secondary monitor (uses $Global:DefaultSecondaryMonitor or
          defaults to monitor 2)
        - 1+ = Specific monitor number
        
        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Width <Int32>
        The initial width of the browser window in pixels. When not specified,
        uses the monitor's working area width or half-width for side positioning.
        
        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Height <Int32>
        The initial height of the browser window in pixels. When not specified,
        uses the monitor's working area height or half-height for top/bottom
        positioning.
        
        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -X <Int32>
        The initial X coordinate for window placement. When not specified, uses
        the monitor's left edge. Can be specified relative to the selected monitor.
        
        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Y <Int32>
        The initial Y coordinate for window placement. When not specified, uses
        the monitor's top edge. Can be specified relative to the selected monitor.
        
        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -AcceptLang <String>
        Sets the browser's Accept-Language HTTP header for internationalization.
        Useful for testing websites in different languages.
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -FullScreen [<SwitchParameter>]
        Opens the browser in fullscreen mode using F11 key simulation.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Private [<SwitchParameter>]
        Opens the browser in private/incognito browsing mode. Uses InPrivate for
        Edge and incognito for Chrome. Not supported for the default browser mode.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Force [<SwitchParameter>]
        Forces enabling of the debugging port by stopping existing browser instances
        if needed. Useful when browser debugging features are required.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Edge [<SwitchParameter>]
        Specifically opens URLs in Microsoft Edge browser.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Chrome [<SwitchParameter>]
        Specifically opens URLs in Google Chrome browser.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Chromium [<SwitchParameter>]
        Opens URLs in either Microsoft Edge or Google Chrome, depending on which
        is set as the default browser. Prefers Chromium-based browsers.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Firefox [<SwitchParameter>]
        Specifically opens URLs in Mozilla Firefox browser.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -All [<SwitchParameter>]
        Opens the specified URLs in all installed modern browsers simultaneously.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Left [<SwitchParameter>]
        Positions the browser window on the left half of the screen.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Right [<SwitchParameter>]
        Positions the browser window on the right half of the screen.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Top [<SwitchParameter>]
        Positions the browser window on the top half of the screen.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Bottom [<SwitchParameter>]
        Positions the browser window on the bottom half of the screen.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Centered [<SwitchParameter>]
        Centers the browser window on the screen using 80% of the screen dimensions.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ApplicationMode [<SwitchParameter>]
        Hides browser controls for a distraction-free experience. Creates an app-like
        interface for web applications.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -NoBrowserExtensions [<SwitchParameter>]
        Prevents loading of browser extensions. Uses safe mode for Firefox and
        --disable-extensions for Chromium browsers.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -DisablePopupBlocker [<SwitchParameter>]
        Disables the browser's popup blocking functionality.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -RestoreFocus [<SwitchParameter>]
        Returns focus to the PowerShell window after opening the browser. Useful
        for automated workflows where you want to continue working in PowerShell.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -NewWindow [<SwitchParameter>]
        Forces creation of a new browser window instead of reusing existing windows.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -FocusWindow [<SwitchParameter>]
        Gives focus to the browser window after opening.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SetForeground [<SwitchParameter>]
        Brings the browser window to the foreground after opening.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Maximize [<SwitchParameter>]
        Maximizes the browser window after positioning.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -KeysToSend <String[]>
        Keystrokes to send to the browser window after opening. Uses the same
        format as the GenXdev.Windows\Send-Key cmdlet.
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SendKeyEscape [<SwitchParameter>]
        Escapes control characters when sending keystrokes to the browser.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SendKeyHoldKeyboardFocus [<SwitchParameter>]
        Prevents returning keyboard focus to PowerShell after sending keystrokes.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SendKeyUseShiftEnter [<SwitchParameter>]
        Uses Shift+Enter instead of regular Enter for line breaks when sending keys.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SendKeyDelayMilliSeconds <Int32>
        Delay between sending different key sequences in milliseconds.
        
        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -NoBorders [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SideBySide [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SessionOnly [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ClearSession [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SkipSession [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Show-WebsiteInAllBrowsers -Url "https://www.github.com"
    Opens github.com in four different browsers arranged in a mosaic layout.
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > "https://www.github.com" | Show-UrlInAllBrowsers
    Uses the function's alias and pipeline input to achieve the same result.
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 

&nbsp;<hr/>
###	GenXdev.Webbrowser.Playwright<hr/> 
NAME
    Close-PlaywrightDriver
    
SYNOPSIS
    Closes a Playwright browser instance and removes it from the global cache.
    
    
SYNTAX
    Close-PlaywrightDriver [[-BrowserType] <String>] [[-ReferenceKey] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    This function safely closes a previously opened Playwright browser instance and
    removes its reference from the global browser dictionary. The function handles
    cleanup of browser resources and provides error handling for graceful shutdown.
    

PARAMETERS
    -BrowserType <String>
        Specifies the type of browser instance to close (Chromium, Firefox, or Webkit).
        If not specified, defaults to Chromium.
        
        Required?                    false
        Position?                    1
        Default value                Chromium
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ReferenceKey <String>
        The unique identifier used to retrieve the browser instance from the global
        cache. If not specified, defaults to "Default".
        
        Required?                    false
        Position?                    2
        Default value                Default
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Close-PlaywrightDriver -BrowserType Chromium -ReferenceKey "MainBrowser"
    Closes a specific Chromium browser instance identified by "MainBrowser"
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > Close-PlaywrightDriver Chrome
    Closes the default Chromium browser instance using position parameters
    ##############################################################################
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Connect-PlaywrightViaDebuggingPort
    
SYNOPSIS
    Connects to an existing browser instance via debugging port.
    
    
SYNTAX
    Connect-PlaywrightViaDebuggingPort [-WsEndpoint] <String> [<CommonParameters>]
    
    
DESCRIPTION
    Establishes a connection to a running Chromium-based browser instance using the
    WebSocket debugger URL. Creates a Playwright instance and connects over CDP
    (Chrome DevTools Protocol). The connected browser instance is stored in a global
    dictionary for later reference.
    

PARAMETERS
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
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Connect-PlaywrightViaDebuggingPort `
        -WsEndpoint "ws://localhost:9222/devtools/browser/abc123"
    ##############################################################################
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Get-PlaywrightDriver
    
SYNOPSIS
    Creates or retrieves a configured Playwright browser instance.
    
    
SYNTAX
    Get-PlaywrightDriver [[-BrowserType] <String>] [[-ReferenceKey] <String>] [-Visible] [-Url <String>] [-Monitor <Int32>] [-Width <Int32>] [-Height <Int32>] [-X <Int32>] [-Y <Int32>] [-Left] [-Right] [-Top] [-Bottom] [-Centered] [-FullScreen] [-PersistBrowserState] [<CommonParameters>]
    
    Get-PlaywrightDriver -WsEndpoint <String> [<CommonParameters>]
    
    
DESCRIPTION
    iManages Playwright browser instances with support for Chrome, Firefox and Webkit.
    Handles browser window positioning, state persistence, and reconnection to
    existing instances. Provides a unified interface for browser automation tasks.
    

PARAMETERS
    -BrowserType <String>
        The browser engine to use (Chromium, Firefox, or Webkit).
        
        Required?                    false
        Position?                    1
        Default value                Chromium
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ReferenceKey <String>
        Unique identifier to track browser instances across sessions.
        
        Required?                    false
        Position?                    2
        Default value                Default
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Visible [<SwitchParameter>]
        Shows the browser window instead of running headless.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Url <String>
        Initial URL to navigate after launching the browser.
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Monitor <Int32>
        Target monitor for window placement (0=primary, -1=discard, -2=secondary).
        
        Required?                    false
        Position?                    named
        Default value                -2
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Width <Int32>
        Browser window width in pixels.
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Height <Int32>
        Browser window height in pixels.
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -X <Int32>
        Horizontal window position in pixels.
        
        Required?                    false
        Position?                    named
        Default value                -999999
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Y <Int32>
        Vertical window position in pixels.
        
        Required?                    false
        Position?                    named
        Default value                -999999
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Left [<SwitchParameter>]
        Aligns window to screen left.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Right [<SwitchParameter>]
        Aligns window to screen right.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Top [<SwitchParameter>]
        Aligns window to screen top.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Bottom [<SwitchParameter>]
        Aligns window to screen bottom.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Centered [<SwitchParameter>]
        Centers window on screen.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -FullScreen [<SwitchParameter>]
        Launches browser in fullscreen mode.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -PersistBrowserState [<SwitchParameter>]
        Maintains browser profile between sessions.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -WsEndpoint <String>
        WebSocket URL for connecting to existing browser instance.
        
        Required?                    true
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Launch visible Chrome browser at GitHub
    Get-PlaywrightDriver -BrowserType Chromium -Visible -Url "https://github.com"
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > Connect to existing browser via WebSocket
    Get-PlaywrightDriver -WsEndpoint "ws://localhost:9222"
    ##############################################################################
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Get-PlaywrightProfileDirectory
    
SYNOPSIS
    Gets the Playwright browser profile directory for persistent sessions.
    
    
SYNTAX
    Get-PlaywrightProfileDirectory [[-BrowserType] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    Creates and manages browser profile directories for Playwright automated testing.
    Profiles are stored in LocalAppData under GenXdev.Powershell/Playwright.profiles.
    These profiles enable persistent sessions across browser automation runs.
    

PARAMETERS
    -BrowserType <String>
        Specifies the browser type to create/get a profile directory for. Can be
        Chromium, Firefox, or Webkit. Defaults to Chromium if not specified.
        
        Required?                    false
        Position?                    1
        Default value                Chromium
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Get-PlaywrightProfileDirectory -BrowserType Chromium
    Creates or returns path: %LocalAppData%\GenXdev.Powershell\Playwright.profiles\Chromium
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > Get-PlaywrightProfileDirectory Firefox
    Creates or returns Firefox profile directory using positional parameter.
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Resume-WebbrowserTabVideo
    
SYNOPSIS
    Resumes video playback in a YouTube browser tab.
    
    
SYNTAX
    Resume-WebbrowserTabVideo [<CommonParameters>]
    
    
DESCRIPTION
    Finds the active YouTube browser tab and resumes video playback by executing the
    play() method on any video elements found in the page. If no YouTube tab is
    found, the function throws an error. This function is particularly useful for
    automating video playback control in browser sessions.
    

PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
NOTES
    
    
        Requires an active Chrome browser session with at least one YouTube tab open.
        The function will throw an error if no YouTube tab is found.
        ##############################################################################
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Resume-WebbrowserTabVideo
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > wbvideoplay
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Stop-WebbrowserVideos
    
SYNOPSIS
    Pauses video playback in all active browser sessions.
    
    
SYNTAX
    Stop-WebbrowserVideos [-Edge] [-Chrome] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    Iterates through all active browser sessions and pauses any playing videos by
    executing JavaScript commands. The function maintains the original session state
    and handles errors gracefully.
    

PARAMETERS
    -Edge [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Chrome [<SwitchParameter>]
        
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
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Stop-WebbrowserVideos
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > wbsst
    ##############################################################################
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Unprotect-WebbrowserTab
    
SYNOPSIS
    Takes control of a selected web browser tab for interactive manipulation.
    
    
SYNTAX
    Unprotect-WebbrowserTab [[-UseCurrent]] [[-Force]] [<CommonParameters>]
    
    
DESCRIPTION
    This function enables interactive control of a browser tab that was previously
    selected using Select-WebbrowserTab. It provides direct access to the Microsoft
    Playwright Page object's properties and methods, allowing for automated browser
    interaction.
    

PARAMETERS
    -UseCurrent [<SwitchParameter>]
        When specified, uses the currently assigned browser tab instead of prompting to
        select a new one. This is useful for continuing work with the same tab.
        
        Required?                    false
        Position?                    1
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Force [<SwitchParameter>]
        Forces a browser restart by closing all tabs if no debugging server is detected.
        Use this when the browser connection is in an inconsistent state.
        
        Required?                    false
        Position?                    2
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Unprotect-WebbrowserTab -UseCurrent
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > wbctrl -Force
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Update-PlaywrightDriverCache
    
SYNOPSIS
    Maintains the Playwright browser instance cache by removing stale entries.
    
    
SYNTAX
    Update-PlaywrightDriverCache [-BrowserDictionary] <ConcurrentDictionary`2> [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    This function performs maintenance on browser instances by removing any that are
    either null or have become disconnected. This helps prevent memory leaks and
    ensures the cache remains healthy.
    

PARAMETERS
    -BrowserDictionary <ConcurrentDictionary`2>
        The concurrent dictionary containing browser instances to maintain.
        
        Required?                    true
        Position?                    1
        Default value                
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
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Clean up disconnected browser instances from the cache
    Update-PlaywrightDriverCache -BrowserDictionary $browserDictionary
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
