<hr/>

<img src="powershell.jpg" alt="GenXdev" width="50%"/>

<hr/>

### NAME

    GenXdev.Webbrowser

### SYNOPSIS
    A Windows PowerShell module that allows you to run scripts against your casual desktop webbrowser-tab

[![GenXdev.Webbrowser](https://img.shields.io/powershellgallery/v/GenXdev.Webbrowser.svg?style=flat-square&label=GenXdev.Webbrowser)](https://www.powershellgallery.com/packages/GenXdev.Webbrowser/) [![License](https://img.shields.io/github/license/genXdev/GenXdev.Webbrowser?style=flat-square)](./LICENSE)

### FEATURES

    * ✅ evaluating javascript-strings, javascript-files in opened webbrowser-tab
    * ✅ adding html script tags, by url, to opened webbrowser-tabs, for normal javascript files or modules
    * ✅ evaluating scripts, with support for async patterns, like promises
    * ✅ evaluating asynchronous scripts, with support for yielded PowerShell pipeline returns

    * ✅ launching of default browser, Microsoft Edge, Google Chrome or Firefox
    * ✅ launching of webbrowser with full control of window positioning
    * ✅ launching of webbrowser in ApplicationMode, Incognito/In-Private
    * ✅ repositioning of already opened webbrowser

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
| [Close-PlaywrightDriver](#Close-PlaywrightDriver) |  | This function safely closes a previously opened Playwright browser instance andremoves its reference from the global browser dictionary. It ensures propercleanup of browser resources and handles errors gracefully. |
| [Stop-WebbrowserVideos](#Stop-WebbrowserVideos) | ssst, wbsst, wbvideostop | This function iterates through all active Chrome sessions and pauses any playingvideos by executing a JavaScript command. |
| [Resume-WebbrowserTabVideo](#Resume-WebbrowserTabVideo) | wbvideoplay | Finds the current YouTube browser tab and resumes video playback by executing theplay() method on any video elements found in the page. |
| [Get-PlaywrightProfileDirectory](#Get-PlaywrightProfileDirectory) |  | Retrieves or creates the profile directory used by Playwright for persistentbrowser sessions. The directory is created under LocalAppData if it doesn't exist. |
| [Get-PlaywrightDriver](#Get-PlaywrightDriver) |  | Creates and manages Playwright browser instances with support for multiple browsertypes, window positioning, and state persistence. |
| [Connect-PlaywrightViaDebuggingPort](#Connect-PlaywrightViaDebuggingPort) |  | Establishes a connection to a running browser instance using the WebSocketdebugger URL. Returns a Playwright browser instance that can be used forautomation. |
| [Close-PlaywrightDriver](#Close-PlaywrightDriver) |  | This function safely closes a previously opened Playwright browser instance andremoves its reference from the global browser dictionary. It ensures propercleanup of browser resources and handles errors gracefully. |
| [Update-PlaywrightDriverCache](#Update-PlaywrightDriverCache) |  | This function cleans up disconnected or null browser instances from the globalPlaywright browser dictionary to prevent memory leaks and maintain cache health. |
| [Unprotect-WebbrowserTab](#Unprotect-WebbrowserTab) | wbctrl | Allows interactive control of a browser tab previously selected using theSelect-WebbrowserTab cmdlet. Provides access to the Microsoft Playwright Pageobject properties and methods. |
| [Stop-WebbrowserVideos](#Stop-WebbrowserVideos) | ssst, wbsst, wbvideostop | This function iterates through all active Chrome sessions and pauses any playingvideos by executing a JavaScript command. |
| [Resume-WebbrowserTabVideo](#Resume-WebbrowserTabVideo) | wbvideoplay | Finds the current YouTube browser tab and resumes video playback by executing theplay() method on any video elements found in the page. |
| [Get-PlaywrightProfileDirectory](#Get-PlaywrightProfileDirectory) |  | Retrieves or creates the profile directory used by Playwright for persistentbrowser sessions. The directory is created under LocalAppData if it doesn't exist. |
| [Get-PlaywrightDriver](#Get-PlaywrightDriver) |  | Creates and manages Playwright browser instances with support for multiple browsertypes, window positioning, and state persistence. |
| [Connect-PlaywrightViaDebuggingPort](#Connect-PlaywrightViaDebuggingPort) |  | Establishes a connection to a running browser instance using the WebSocketdebugger URL. Returns a Playwright browser instance that can be used forautomation. |
| [Close-PlaywrightDriver](#Close-PlaywrightDriver) |  | This function safely closes a previously opened Playwright browser instance andremoves its reference from the global browser dictionary. It ensures propercleanup of browser resources and handles errors gracefully. |
| [Update-PlaywrightDriverCache](#Update-PlaywrightDriverCache) |  | This function cleans up disconnected or null browser instances from the globalPlaywright browser dictionary to prevent memory leaks and maintain cache health. |
| [Unprotect-WebbrowserTab](#Unprotect-WebbrowserTab) | wbctrl | Allows interactive control of a browser tab previously selected using theSelect-WebbrowserTab cmdlet. Provides access to the Microsoft Playwright Pageobject properties and methods. |
| [Stop-WebbrowserVideos](#Stop-WebbrowserVideos) | ssst, wbsst, wbvideostop | This function iterates through all active Chrome sessions and pauses any playingvideos by executing a JavaScript command. |
| [Resume-WebbrowserTabVideo](#Resume-WebbrowserTabVideo) | wbvideoplay | Finds the current YouTube browser tab and resumes video playback by executing theplay() method on any video elements found in the page. |
| [Get-PlaywrightProfileDirectory](#Get-PlaywrightProfileDirectory) |  | Retrieves or creates the profile directory used by Playwright for persistentbrowser sessions. The directory is created under LocalAppData if it doesn't exist. |
| [Get-PlaywrightDriver](#Get-PlaywrightDriver) |  | Creates and manages Playwright browser instances with support for multiple browsertypes, window positioning, and state persistence. |
| [Connect-PlaywrightViaDebuggingPort](#Connect-PlaywrightViaDebuggingPort) |  | Establishes a connection to a running browser instance using the WebSocketdebugger URL. Returns a Playwright browser instance that can be used forautomation. |
| [Unprotect-WebbrowserTab](#Unprotect-WebbrowserTab) | wbctrl | Allows interactive control of a browser tab previously selected using theSelect-WebbrowserTab cmdlet. Provides access to the Microsoft Playwright Pageobject properties and methods. |
| [Update-PlaywrightDriverCache](#Update-PlaywrightDriverCache) |  | This function cleans up disconnected or null browser instances from the globalPlaywright browser dictionary to prevent memory leaks and maintain cache health. |

<br/><hr/><hr/><br/>


# Cmdlets

&nbsp;<hr/>
###	GenXdev.Webbrowser.Playwright<hr/>

##	Close-PlaywrightDriver
````PowerShell
Close-PlaywrightDriver
````

### SYNOPSIS
    Closes a Playwright browser instance and removes it from the global cache.

### SYNTAX
````PowerShell
Close-PlaywrightDriver [[-BrowserType] <String>] [[-ReferenceKey] <String>] 
[<CommonParameters>]
````

### DESCRIPTION
    This function safely closes a previously opened Playwright browser instance and
    removes its reference from the global browser dictionary. It ensures proper
    cleanup of browser resources and handles errors gracefully.

### PARAMETERS
    -BrowserType <String>
        The type of browser to close (Chromium, Firefox, or Webkit).
        Required?                    false
        Position?                    1
        Default value                Chromium
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -ReferenceKey <String>
        The unique identifier for the browser instance in the cache. Defaults to
        "Default" if not specified.
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
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	Stop-WebbrowserVideos
````PowerShell
Stop-WebbrowserVideos                --> ssst, wbsst, wbvideostop
````

### SYNOPSIS
    Pauses video playback in all active Chromium sessions.

### SYNTAX
````PowerShell
Stop-WebbrowserVideos [<CommonParameters>]
````

### DESCRIPTION
    This function iterates through all active Chrome sessions and pauses any playing
    videos by executing a JavaScript command.

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	Resume-WebbrowserTabVideo
````PowerShell
Resume-WebbrowserTabVideo            --> wbvideoplay
````

### SYNOPSIS
    Resumes video playback in a YouTube browser tab.

### SYNTAX
````PowerShell
Resume-WebbrowserTabVideo [<CommonParameters>]
````

### DESCRIPTION
    Finds the current YouTube browser tab and resumes video playback by executing the
    play() method on any video elements found in the page.

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

### NOTES
````PowerShell
    Requires an active Chrome browser session with at least one YouTube tab open.
-------------------------- EXAMPLE 1 --------------------------
PS C:\> Resume-WebbrowserTabVideo
````

<br/><hr/><hr/><br/>

##	Get-PlaywrightProfileDirectory
````PowerShell
Get-PlaywrightProfileDirectory
````

### SYNOPSIS
    Gets the Playwright browser profile directory for persistent sessions.

### SYNTAX
````PowerShell
Get-PlaywrightProfileDirectory [[-BrowserType] <String>] [<CommonParameters>]
````

### DESCRIPTION
    Retrieves or creates the profile directory used by Playwright for persistent
    browser sessions. The directory is created under LocalAppData if it doesn't exist.

### PARAMETERS
    -BrowserType <String>
        The type of browser to get or create a profile directory for. Valid values are
        Chromium, Firefox, or Webkit.
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
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	Get-PlaywrightDriver
````PowerShell
Get-PlaywrightDriver
````

### SYNOPSIS
    Gets or creates a Playwright browser instance with full configuration options.

### SYNTAX
````PowerShell
Get-PlaywrightDriver [[-BrowserType] <String>] [[-ReferenceKey] <String>] [-Visible] [-Url 
<String>] [-Monitor <Int32>] [-Width <Int32>] [-Height <Int32>] [-X <Int32>] [-Y <Int32>] 
[-Left] [-Right] [-Top] [-Bottom] [-Centered] [-FullScreen] [-PersistBrowserState] 
[<CommonParameters>]
Get-PlaywrightDriver -WsEndpoint <String> [<CommonParameters>]
````

### DESCRIPTION
    Creates and manages Playwright browser instances with support for multiple browser
    types, window positioning, and state persistence.

### PARAMETERS
    -BrowserType <String>
        The type of browser to launch (Chromium, Firefox, or Webkit).
        Required?                    false
        Position?                    1
        Default value                Chromium
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -ReferenceKey <String>
        Unique identifier for the browser instance. Defaults to "Default".
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
        The URL or URLs to open in the browser. Can be provided via pipeline.
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Monitor <Int32>
        The monitor to use (0=default, -1=discard, -2=configured secondary monitor, defaults to 
        $Global:DefaultSecondaryMonitor or 2 if not found).
        Required?                    false
        Position?                    named
        Default value                -2
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Width <Int32>
        The initial width of the webbrowser window.
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Height <Int32>
        The initial height of the webbrowser window.
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -X <Int32>
        The initial X position of the webbrowser window.
        Required?                    false
        Position?                    named
        Default value                -999999
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Y <Int32>
        The initial Y position of the webbrowser window.
        Required?                    false
        Position?                    named
        Default value                -999999
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Left [<SwitchParameter>]
        Places browser window on the left side of the screen.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Right [<SwitchParameter>]
        Places browser window on the right side of the screen.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Top [<SwitchParameter>]
        Places browser window on the top side of the screen.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Bottom [<SwitchParameter>]
        Places browser window on the bottom side of the screen.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Centered [<SwitchParameter>]
        Places browser window in the center of the screen.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -FullScreen [<SwitchParameter>]
        Opens browser in fullscreen mode.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -PersistBrowserState [<SwitchParameter>]
        Maintains browser state between sessions.
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
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

### NOTES
````PowerShell
    This is a Playwright-specific implementation that may not support all features of 
    Open-Webbrowser.
    Some positioning and window management features may be limited by Playwright 
    capabilities.
-------------------------- EXAMPLE 1 --------------------------
PS C:\> Get-PlaywrightDriver -BrowserType Chromium -Visible -Url "https://github.com"
````

<br/><hr/><hr/><br/>

##	Connect-PlaywrightViaDebuggingPort
````PowerShell
Connect-PlaywrightViaDebuggingPort
````

### SYNOPSIS
    Connects to an existing browser instance via debugging port.

### SYNTAX
````PowerShell
Connect-PlaywrightViaDebuggingPort [-WsEndpoint] <String> [<CommonParameters>]
````

### DESCRIPTION
    Establishes a connection to a running browser instance using the WebSocket
    debugger URL. Returns a Playwright browser instance that can be used for
    automation.

### PARAMETERS
    -WsEndpoint <String>
        The WebSocket URL for the browser's debugging port
        (e.g., ws://localhost:9222/devtools/browser/...)
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

<br/><hr/><hr/><br/>

##	Close-PlaywrightDriver
````PowerShell
Close-PlaywrightDriver
````

### SYNOPSIS
    Closes a Playwright browser instance and removes it from the global cache.

### SYNTAX
````PowerShell
Close-PlaywrightDriver [[-BrowserType] <String>] [[-ReferenceKey] <String>] 
[<CommonParameters>]
````

### DESCRIPTION
    This function safely closes a previously opened Playwright browser instance and
    removes its reference from the global browser dictionary. It ensures proper
    cleanup of browser resources and handles errors gracefully.

### PARAMETERS
    -BrowserType <String>
        The type of browser to close (Chromium, Firefox, or Webkit).
        Required?                    false
        Position?                    1
        Default value                Chromium
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -ReferenceKey <String>
        The unique identifier for the browser instance in the cache. Defaults to
        "Default" if not specified.
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
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	Update-PlaywrightDriverCache
````PowerShell
Update-PlaywrightDriverCache
````

### SYNOPSIS
    Maintains the Playwright browser instance cache.

### SYNTAX
````PowerShell
Update-PlaywrightDriverCache [<CommonParameters>]
````

### DESCRIPTION
    This function cleans up disconnected or null browser instances from the global
    Playwright browser dictionary to prevent memory leaks and maintain cache health.

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	Unprotect-WebbrowserTab
````PowerShell
Unprotect-WebbrowserTab              --> wbctrl
````

### SYNOPSIS
    Takes control of the selected webbrowser tab.

### SYNTAX
````PowerShell
Unprotect-WebbrowserTab [[-UseCurrent]] [[-Force]] [<CommonParameters>]
````

### DESCRIPTION
    Allows interactive control of a browser tab previously selected using the
    Select-WebbrowserTab cmdlet. Provides access to the Microsoft Playwright Page
    object properties and methods.

### PARAMETERS
    -UseCurrent [<SwitchParameter>]
        Use the currently assigned tab instead of selecting a new one.
        Required?                    false
        Position?                    1
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Force [<SwitchParameter>]
        Restart webbrowser (closes all tabs) if no debugging server is detected.
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
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	Stop-WebbrowserVideos
````PowerShell
Stop-WebbrowserVideos                --> ssst, wbsst, wbvideostop
````

### SYNOPSIS
    Pauses video playback in all active Chromium sessions.

### SYNTAX
````PowerShell
Stop-WebbrowserVideos [<CommonParameters>]
````

### DESCRIPTION
    This function iterates through all active Chrome sessions and pauses any playing
    videos by executing a JavaScript command.

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	Resume-WebbrowserTabVideo
````PowerShell
Resume-WebbrowserTabVideo            --> wbvideoplay
````

### SYNOPSIS
    Resumes video playback in a YouTube browser tab.

### SYNTAX
````PowerShell
Resume-WebbrowserTabVideo [<CommonParameters>]
````

### DESCRIPTION
    Finds the current YouTube browser tab and resumes video playback by executing the
    play() method on any video elements found in the page.

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

### NOTES
````PowerShell
    Requires an active Chrome browser session with at least one YouTube tab open.
-------------------------- EXAMPLE 1 --------------------------
PS C:\> Resume-WebbrowserTabVideo
````

<br/><hr/><hr/><br/>

##	Get-PlaywrightProfileDirectory
````PowerShell
Get-PlaywrightProfileDirectory
````

### SYNOPSIS
    Gets the Playwright browser profile directory for persistent sessions.

### SYNTAX
````PowerShell
Get-PlaywrightProfileDirectory [[-BrowserType] <String>] [<CommonParameters>]
````

### DESCRIPTION
    Retrieves or creates the profile directory used by Playwright for persistent
    browser sessions. The directory is created under LocalAppData if it doesn't exist.

### PARAMETERS
    -BrowserType <String>
        The type of browser to get or create a profile directory for. Valid values are
        Chromium, Firefox, or Webkit.
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
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	Get-PlaywrightDriver
````PowerShell
Get-PlaywrightDriver
````

### SYNOPSIS
    Gets or creates a Playwright browser instance with full configuration options.

### SYNTAX
````PowerShell
Get-PlaywrightDriver [[-BrowserType] <String>] [[-ReferenceKey] <String>] [-Visible] [-Url 
<String>] [-Monitor <Int32>] [-Width <Int32>] [-Height <Int32>] [-X <Int32>] [-Y <Int32>] 
[-Left] [-Right] [-Top] [-Bottom] [-Centered] [-FullScreen] [-PersistBrowserState] 
[<CommonParameters>]
Get-PlaywrightDriver -WsEndpoint <String> [<CommonParameters>]
````

### DESCRIPTION
    Creates and manages Playwright browser instances with support for multiple browser
    types, window positioning, and state persistence.

### PARAMETERS
    -BrowserType <String>
        The type of browser to launch (Chromium, Firefox, or Webkit).
        Required?                    false
        Position?                    1
        Default value                Chromium
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -ReferenceKey <String>
        Unique identifier for the browser instance. Defaults to "Default".
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
        The URL or URLs to open in the browser. Can be provided via pipeline.
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Monitor <Int32>
        The monitor to use (0=default, -1=discard, -2=configured secondary monitor, defaults to 
        $Global:DefaultSecondaryMonitor or 2 if not found).
        Required?                    false
        Position?                    named
        Default value                -2
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Width <Int32>
        The initial width of the webbrowser window.
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Height <Int32>
        The initial height of the webbrowser window.
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -X <Int32>
        The initial X position of the webbrowser window.
        Required?                    false
        Position?                    named
        Default value                -999999
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Y <Int32>
        The initial Y position of the webbrowser window.
        Required?                    false
        Position?                    named
        Default value                -999999
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Left [<SwitchParameter>]
        Places browser window on the left side of the screen.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Right [<SwitchParameter>]
        Places browser window on the right side of the screen.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Top [<SwitchParameter>]
        Places browser window on the top side of the screen.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Bottom [<SwitchParameter>]
        Places browser window on the bottom side of the screen.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Centered [<SwitchParameter>]
        Places browser window in the center of the screen.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -FullScreen [<SwitchParameter>]
        Opens browser in fullscreen mode.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -PersistBrowserState [<SwitchParameter>]
        Maintains browser state between sessions.
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
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

### NOTES
````PowerShell
    This is a Playwright-specific implementation that may not support all features of 
    Open-Webbrowser.
    Some positioning and window management features may be limited by Playwright 
    capabilities.
-------------------------- EXAMPLE 1 --------------------------
PS C:\> Get-PlaywrightDriver -BrowserType Chromium -Visible -Url "https://github.com"
````

<br/><hr/><hr/><br/>

##	Connect-PlaywrightViaDebuggingPort
````PowerShell
Connect-PlaywrightViaDebuggingPort
````

### SYNOPSIS
    Connects to an existing browser instance via debugging port.

### SYNTAX
````PowerShell
Connect-PlaywrightViaDebuggingPort [-WsEndpoint] <String> [<CommonParameters>]
````

### DESCRIPTION
    Establishes a connection to a running browser instance using the WebSocket
    debugger URL. Returns a Playwright browser instance that can be used for
    automation.

### PARAMETERS
    -WsEndpoint <String>
        The WebSocket URL for the browser's debugging port
        (e.g., ws://localhost:9222/devtools/browser/...)
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

<br/><hr/><hr/><br/>

##	Close-PlaywrightDriver
````PowerShell
Close-PlaywrightDriver
````

### SYNOPSIS
    Closes a Playwright browser instance and removes it from the global cache.

### SYNTAX
````PowerShell
Close-PlaywrightDriver [[-BrowserType] <String>] [[-ReferenceKey] <String>] 
[<CommonParameters>]
````

### DESCRIPTION
    This function safely closes a previously opened Playwright browser instance and
    removes its reference from the global browser dictionary. It ensures proper
    cleanup of browser resources and handles errors gracefully.

### PARAMETERS
    -BrowserType <String>
        The type of browser to close (Chromium, Firefox, or Webkit).
        Required?                    false
        Position?                    1
        Default value                Chromium
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -ReferenceKey <String>
        The unique identifier for the browser instance in the cache. Defaults to
        "Default" if not specified.
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
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	Update-PlaywrightDriverCache
````PowerShell
Update-PlaywrightDriverCache
````

### SYNOPSIS
    Maintains the Playwright browser instance cache.

### SYNTAX
````PowerShell
Update-PlaywrightDriverCache [<CommonParameters>]
````

### DESCRIPTION
    This function cleans up disconnected or null browser instances from the global
    Playwright browser dictionary to prevent memory leaks and maintain cache health.

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	Unprotect-WebbrowserTab
````PowerShell
Unprotect-WebbrowserTab              --> wbctrl
````

### SYNOPSIS
    Takes control of the selected webbrowser tab.

### SYNTAX
````PowerShell
Unprotect-WebbrowserTab [[-UseCurrent]] [[-Force]] [<CommonParameters>]
````

### DESCRIPTION
    Allows interactive control of a browser tab previously selected using the
    Select-WebbrowserTab cmdlet. Provides access to the Microsoft Playwright Page
    object properties and methods.

### PARAMETERS
    -UseCurrent [<SwitchParameter>]
        Use the currently assigned tab instead of selecting a new one.
        Required?                    false
        Position?                    1
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Force [<SwitchParameter>]
        Restart webbrowser (closes all tabs) if no debugging server is detected.
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
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	Stop-WebbrowserVideos
````PowerShell
Stop-WebbrowserVideos                --> ssst, wbsst, wbvideostop
````

### SYNOPSIS
    Pauses video playback in all active Chromium sessions.

### SYNTAX
````PowerShell
Stop-WebbrowserVideos [<CommonParameters>]
````

### DESCRIPTION
    This function iterates through all active Chrome sessions and pauses any playing
    videos by executing a JavaScript command.

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	Resume-WebbrowserTabVideo
````PowerShell
Resume-WebbrowserTabVideo            --> wbvideoplay
````

### SYNOPSIS
    Resumes video playback in a YouTube browser tab.

### SYNTAX
````PowerShell
Resume-WebbrowserTabVideo [<CommonParameters>]
````

### DESCRIPTION
    Finds the current YouTube browser tab and resumes video playback by executing the
    play() method on any video elements found in the page.

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

### NOTES
````PowerShell
    Requires an active Chrome browser session with at least one YouTube tab open.
-------------------------- EXAMPLE 1 --------------------------
PS C:\> Resume-WebbrowserTabVideo
````

<br/><hr/><hr/><br/>

##	Get-PlaywrightProfileDirectory
````PowerShell
Get-PlaywrightProfileDirectory
````

### SYNOPSIS
    Gets the Playwright browser profile directory for persistent sessions.

### SYNTAX
````PowerShell
Get-PlaywrightProfileDirectory [[-BrowserType] <String>] [<CommonParameters>]
````

### DESCRIPTION
    Retrieves or creates the profile directory used by Playwright for persistent
    browser sessions. The directory is created under LocalAppData if it doesn't exist.

### PARAMETERS
    -BrowserType <String>
        The type of browser to get or create a profile directory for. Valid values are
        Chromium, Firefox, or Webkit.
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
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	Get-PlaywrightDriver
````PowerShell
Get-PlaywrightDriver
````

### SYNOPSIS
    Gets or creates a Playwright browser instance with full configuration options.

### SYNTAX
````PowerShell
Get-PlaywrightDriver [[-BrowserType] <String>] [[-ReferenceKey] <String>] [-Visible] [-Url 
<String>] [-Monitor <Int32>] [-Width <Int32>] [-Height <Int32>] [-X <Int32>] [-Y <Int32>] 
[-Left] [-Right] [-Top] [-Bottom] [-Centered] [-FullScreen] [-PersistBrowserState] 
[<CommonParameters>]
Get-PlaywrightDriver -WsEndpoint <String> [<CommonParameters>]
````

### DESCRIPTION
    Creates and manages Playwright browser instances with support for multiple browser
    types, window positioning, and state persistence.

### PARAMETERS
    -BrowserType <String>
        The type of browser to launch (Chromium, Firefox, or Webkit).
        Required?                    false
        Position?                    1
        Default value                Chromium
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -ReferenceKey <String>
        Unique identifier for the browser instance. Defaults to "Default".
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
        The URL or URLs to open in the browser. Can be provided via pipeline.
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Monitor <Int32>
        The monitor to use (0=default, -1=discard, -2=configured secondary monitor, defaults to 
        $Global:DefaultSecondaryMonitor or 2 if not found).
        Required?                    false
        Position?                    named
        Default value                -2
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Width <Int32>
        The initial width of the webbrowser window.
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Height <Int32>
        The initial height of the webbrowser window.
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -X <Int32>
        The initial X position of the webbrowser window.
        Required?                    false
        Position?                    named
        Default value                -999999
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Y <Int32>
        The initial Y position of the webbrowser window.
        Required?                    false
        Position?                    named
        Default value                -999999
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Left [<SwitchParameter>]
        Places browser window on the left side of the screen.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Right [<SwitchParameter>]
        Places browser window on the right side of the screen.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Top [<SwitchParameter>]
        Places browser window on the top side of the screen.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Bottom [<SwitchParameter>]
        Places browser window on the bottom side of the screen.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Centered [<SwitchParameter>]
        Places browser window in the center of the screen.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -FullScreen [<SwitchParameter>]
        Opens browser in fullscreen mode.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -PersistBrowserState [<SwitchParameter>]
        Maintains browser state between sessions.
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
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

### NOTES
````PowerShell
    This is a Playwright-specific implementation that may not support all features of 
    Open-Webbrowser.
    Some positioning and window management features may be limited by Playwright 
    capabilities.
-------------------------- EXAMPLE 1 --------------------------
PS C:\> Get-PlaywrightDriver -BrowserType Chromium -Visible -Url "https://github.com"
````

<br/><hr/><hr/><br/>

##	Connect-PlaywrightViaDebuggingPort
````PowerShell
Connect-PlaywrightViaDebuggingPort
````

### SYNOPSIS
    Connects to an existing browser instance via debugging port.

### SYNTAX
````PowerShell
Connect-PlaywrightViaDebuggingPort [-WsEndpoint] <String> [<CommonParameters>]
````

### DESCRIPTION
    Establishes a connection to a running browser instance using the WebSocket
    debugger URL. Returns a Playwright browser instance that can be used for
    automation.

### PARAMETERS
    -WsEndpoint <String>
        The WebSocket URL for the browser's debugging port
        (e.g., ws://localhost:9222/devtools/browser/...)
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

<br/><hr/><hr/><br/>

##	Unprotect-WebbrowserTab
````PowerShell
Unprotect-WebbrowserTab              --> wbctrl
````

### SYNOPSIS
    Takes control of the selected webbrowser tab.

### SYNTAX
````PowerShell
Unprotect-WebbrowserTab [[-UseCurrent]] [[-Force]] [<CommonParameters>]
````

### DESCRIPTION
    Allows interactive control of a browser tab previously selected using the
    Select-WebbrowserTab cmdlet. Provides access to the Microsoft Playwright Page
    object properties and methods.

### PARAMETERS
    -UseCurrent [<SwitchParameter>]
        Use the currently assigned tab instead of selecting a new one.
        Required?                    false
        Position?                    1
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
    -Force [<SwitchParameter>]
        Restart webbrowser (closes all tabs) if no debugging server is detected.
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
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	Update-PlaywrightDriverCache
````PowerShell
Update-PlaywrightDriverCache
````

### SYNOPSIS
    Maintains the Playwright browser instance cache.

### SYNTAX
````PowerShell
Update-PlaywrightDriverCache [<CommonParameters>]
````

### DESCRIPTION
    This function cleans up disconnected or null browser instances from the global
    Playwright browser dictionary to prevent memory leaks and maintain cache health.

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>
