<hr/>

<img src="powershell.jpg" alt="GenXdev" width="50%"/>

<hr/>

### NAME

    GenXdev.Webbrowser

### SYNOPSIS
    A Windows PowerShell module that allows you to run scripts against your casual desktop webbrowser-tab

[![GenXdev.Webbrowser](https://img.shields.io/powershellgallery/v/GenXdev.Webbrowser.svg?style=flat-square&label=GenXdev.Webbrowser)](https://www.powershellgallery.com/packages/GenXdev.Webbrowser/) [![License](https://img.shields.io/github/license/renevaessen/GenXdev.Webbrowser?style=flat-square)](./LICENSE)

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
    # Synchronizing data
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
[![WinOS - Windows-10](https://img.shields.io/badge/WinOS-Windows--10--10.0.19041--SP0-brightgreen)](https://www.microsoft.com/en-us/windows/get-windows-10)
[![GenXdev.Helpers](https://img.shields.io/powershellgallery/v/GenXdev.Helpers.svg?style=flat-square&label=GenXdev.Helpers)](https://www.powershellgallery.com/packages/GenXdev.Helpers/) [![GenXdev.FileSystem](https://img.shields.io/powershellgallery/v/GenXdev.Filesystem.svg?style=flat-square&label=GenXdev.FileSystem)](https://www.powershellgallery.com/packages/GenXdev.FileSystem/) [![GenXdev.Windows](https://img.shields.io/powershellgallery/v/GenXdev.Windows.svg?style=flat-square&label=GenXdev.Windows)](https://www.powershellgallery.com/packages/GenXdev.Windows/)

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
| [Get-DefaultWebbrowser](#Get-DefaultWebbrowser) |  | Returns an object describing the configured current webbrowser for the current-user. |
| [Get-Webbrowser](#Get-Webbrowser) |  | Returns a collection of objects each describing a installed modern webbrowser |
| [Open-Webbrowser](#Open-Webbrowser) | wb | Opens one or more webbrowsers in a configurable manner, using commandline switches |
| [Close-Webbrowser](#Close-Webbrowser) | wbc | Closes one or more webbrowser instances in a selective manner, using commandline switches |
| [Select-WebbrowserTab](#Select-WebbrowserTab) | Select-BrowserTab, st | Selects a webbrowser tab for use by the Cmdlets 'Invoke-WebbrowserEvaluation -> et, eval', 'Close-WebbrowserTab -> ct' and others |
| [Invoke-WebbrowserEvaluation](#Invoke-WebbrowserEvaluation) | et, Eval | Runs one or more scripts inside a selected webbrowser tab.You can access 'data' object from within javascript, to synchronize data between PowerShell and the Webbrowser |
| [Set-WebbrowserTabLocation](#Set-WebbrowserTabLocation) | lt, Nav | Navigates current selected tab to specified url |
| [Set-BrowserVideoFullscreen](#Set-BrowserVideoFullscreen) | fsvideo | Invokes a script in the current selected webbrowser tab to maximize the video player |
| [Close-WebbrowserTab](#Close-WebbrowserTab) | CloseTab, ct | Closes the currently selected webbrowser tab |
| [Show-WebsiteInAllBrowsers](#Show-WebsiteInAllBrowsers) | Show-UrlInAllBrowsers | Will open an url into three different browsers + a incognito window, with a window mosaic layout |
| [Set-RemoteDebuggerPortInBrowserShortcuts](#Set-RemoteDebuggerPortInBrowserShortcuts) |  | Updates all browser shortcuts for current user, to enable the remote debugging port by default |
| [Get-ChromeRemoteDebuggingPort](#Get-ChromeRemoteDebuggingPort) |  | Returns the configured remote debugging port for Google Chrome |
| [Get-EdgeRemoteDebuggingPort](#Get-EdgeRemoteDebuggingPort) |  | Returns the configured remote debugging port for Microsoft Edge |
| [Get-ChromiumRemoteDebuggingPort](#Get-ChromiumRemoteDebuggingPort) |  | Returns the configured remote debugging port for Microsoft Edge or Google Chrome, which ever is the default browser |
| [Copy-OpenWebbrowserParameters](#Copy-OpenWebbrowserParameters) |  | The dynamic parameter block of a proxy function. This block can be used to copy a proxy function target's parameters . |
| [Approve-FirefoxDebugging](#Approve-FirefoxDebugging) |  | Changes firefox settings to enable remotedebugging and app-mode startups of firefox |
| [Get-ChromiumSessionReference](#Get-ChromiumSessionReference) |  | Returns a reference that can be used with Select-WebbrowserTab -ByReferenceThis can be usefull when you want to evaluate the webbrowser inside a Job.With this serializable reference, you can pass the webbrowser tab session reference on to the Job commandblock. |

<br/><hr/><hr/><br/>


# Cmdlets

&nbsp;<hr/>
###	GenXdev.Webbrowser<hr/>

##	Get-DefaultWebbrowser
````PowerShell
Get-DefaultWebbrowser
````

### SYNOPSIS
    Returns the configured current webbrowser

### SYNTAX
````PowerShell
Get-DefaultWebbrowser [<CommonParameters>]
````

### DESCRIPTION
    Returns an object describing the configured current webbrowser for the current-user.

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

### NOTES
````PowerShell
    Requires the Windows 10+ Operating System
-------------------------- EXAMPLE 1 --------------------------
PS C:\> & (Get-DefaultWebbrowser).Path https://www.github.com/
PS C:\> Get-DefaultWebbrowser | Format-List
````

<br/><hr/><hr/><br/>

##	Get-Webbrowser
````PowerShell
Get-Webbrowser
````

### SYNOPSIS
    Returns a collection of installed modern webbrowsers

### SYNTAX
````PowerShell
Get-Webbrowser [<CommonParameters>]
````

### DESCRIPTION
    Returns a collection of objects each describing a installed modern webbrowser

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

### NOTES
````PowerShell
    Requires the Windows 10+ Operating System
-------------------------- EXAMPLE 1 --------------------------
PS C:\> Get-Webbrowser | Foreach-Object { & $PSItem.Path https://www.github.com/ }
PS C:\> Get-Webbrowser | select Name, Description | Format-Table
PS C:\> Get-Webbrowser | select Name, Path | Format-Table
````

<br/><hr/><hr/><br/>

##	Open-Webbrowser
````PowerShell
Open-Webbrowser                      --> wb
````

### SYNOPSIS
    Opens one or more webbrowser instances

### SYNTAX
````PowerShell
Open-Webbrowser [[-Url] <String[]>] [-Private] [-Edge] [-Chrome] [-Chromium] [-Firefox] [-All] [-Monitor
<Int32>] [-FullScreen] [-Width <Int32>] [-Height <Int32>] [-X <Int32>] [-Y <Int32>] [-Left] [-Right] [-Top]
[-Bottom] [-Centered] [-ApplicationMode] [-NoBrowserExtensions] [-RestoreFocus] [-NewWindow] [-PassThrough]
[<CommonParameters>]
````

### DESCRIPTION
    Opens one or more webbrowsers in a configurable manner, using commandline switches

### PARAMETERS
    -Url <String[]>
        The url to open
        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Accept wildcard characters?  false
    -Private [<SwitchParameter>]
        Opens in incognito-/in-private browsing- mode
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -Edge [<SwitchParameter>]
        Open in Microsoft Edge --> -e
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -Chrome [<SwitchParameter>]
        Open in Google Chrome --> -ch
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -Chromium [<SwitchParameter>]
        Open in Microsoft Edge or Google Chrome, depending on what the default browser is --> -c
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -Firefox [<SwitchParameter>]
        Open in Firefox --> -ff
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -All [<SwitchParameter>]
        Open in all registered modern browsers
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -Monitor <Int32>
        The monitor to use, 0 = default, -1 is discard, -2 = Configured secondary monitor, defaults to
        `Global:DefaultSecondaryMonitor or 2 if not found --> -m, -mon
        Required?                    false
        Position?                    named
        Default value                -2
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -FullScreen [<SwitchParameter>]
        Open in fullscreen mode --> -fs
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -Width <Int32>
        The initial width of the webbrowser window
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -Height <Int32>
        The initial height of the webbrowser window
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -X <Int32>
        The initial X position of the webbrowser window
        Required?                    false
        Position?                    named
        Default value                -999999
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -Y <Int32>
        The initial Y position of the webbrowser window
        Required?                    false
        Position?                    named
        Default value                -999999
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -Left [<SwitchParameter>]
        Place browser window on the left side of the screen
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -Right [<SwitchParameter>]
        Place browser window on the right side of the screen
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -Top [<SwitchParameter>]
        Place browser window on the top side of the screen
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -Bottom [<SwitchParameter>]
        Place browser window on the bottom side of the screen
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -Centered [<SwitchParameter>]
        Place browser window in the center of the screen
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -ApplicationMode [<SwitchParameter>]
        Hide the browser controls --> -a, -app, -appmode
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -NoBrowserExtensions [<SwitchParameter>]
        Prevent loading of browser extensions --> -de, -ne
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -RestoreFocus [<SwitchParameter>]
        Restore PowerShell window focus --> -bg
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -NewWindow [<SwitchParameter>]
        Do not re-use existing browser window, instead, create a new one -> nw
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -PassThrough [<SwitchParameter>]
        Returns a [System.Diagnostics.Process] object of the browserprocess
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

### NOTES
````PowerShell
    Requires the Windows 10+ Operating System
    This cmdlet was mend to be used, interactively.
    It performs some strange tricks to position windows, including invoking alt-tab keystrokes.
    It is best not to touch the keyboard or mouse, while it is doing that.
    For fast launches of multple urls:
    SET    : -Monitor -1
    AND    : DO NOT use any of these switches: -X, -Y, -Left, -Right, -Top, -Bottom or -RestoreFocus
    For browsers that are not installed on the system, no actions may be performed or errors occur - at all.
-------------------------- EXAMPLE 1 --------------------------
PS C:\> url from parameter
PS C:\> Open-Webbrowser -Chrome -Left -Top -Url "https://genxdev.net/"
urls from pipeline
PS C:\> @("https://genxdev.net/", "https://github.com/renevaessen/") | Open-Webbrowser
re-position already open window to primary monitor on right side
PS C:\> Open-Webbrowser -Monitor 0 -right
re-position already open window to secondary monitor, full screen
PS C:\> Open-Webbrowser -Monitor 0
re-position already open window to secondary monitor, left top
PS C:\> Open-Webbrowser -Monitor 0 -Left -Top
PS C:\> wb -m 0 -left -top
````

<br/><hr/><hr/><br/>

##	Close-Webbrowser
````PowerShell
Close-Webbrowser                     --> wbc
````

### SYNOPSIS
    Closes one or more webbrowser instances

### SYNTAX
````PowerShell
Close-Webbrowser [-Edge] [-Chrome] [-Chromium] [-Firefox] [-All] [-IncludeBackgroundProcesses]
[<CommonParameters>]
````

### DESCRIPTION
    Closes one or more webbrowser instances in a selective manner, using commandline switches

### PARAMETERS
    -Edge [<SwitchParameter>]
        Closes Microsoft Edge --> -e
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -Chrome [<SwitchParameter>]
        Closes Google Chrome --> -ch
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -Chromium [<SwitchParameter>]
        Closes Microsoft Edge or Google Chrome, depending on what the default browser is --> -c
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -Firefox [<SwitchParameter>]
        Closes Firefox --> -ff
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -All [<SwitchParameter>]
        Closes all registered modern browsers -> -a
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -IncludeBackgroundProcesses [<SwitchParameter>]
        Closes all instances of the webbrowser, including background tasks and services
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

### NOTES
````PowerShell
    Requires the Windows 10+ Operating System
-------------------------- EXAMPLE 1 --------------------------
PS C:\> Close-Webbrowser -Chrome
PS C:\> Close-Webbrowser -Chrome -FireFox
PS C:\> Close-Webbrowser -All
PS C:\> wbc -a
````

<br/><hr/><hr/><br/>

##	Select-WebbrowserTab
````PowerShell
Select-WebbrowserTab                 --> Select-BrowserTab, st
````

### SYNOPSIS
    Selects a webbrowser tab

### SYNTAX
````PowerShell
Select-WebbrowserTab [[-id] <Int32>] [-Edge] [-Chrome] [<CommonParameters>]
Select-WebbrowserTab [-Name] <String> [<CommonParameters>]
Select-WebbrowserTab -ByReference <Hashtable> [<CommonParameters>]
````

### DESCRIPTION
    Selects a webbrowser tab for use by the Cmdlets 'Invoke-WebbrowserEvaluation -> et, eval',
    'Close-WebbrowserTab -> ct' and others

### PARAMETERS
    -id <Int32>
        When '-Id' is not supplied, a list of available webbrowser tabs is shown, where the right value can be
        found
        Required?                    false
        Position?                    1
        Default value                -1
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -Name <String>
        Selects the first entry that contains given name in its url
        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -Edge [<SwitchParameter>]
        Force to use 'Microsoft Edge' webbrowser for selection
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -Chrome [<SwitchParameter>]
        Force to use 'Google Chrome' webbrowser for selection
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -ByReference <Hashtable>
        Select tab using reference obtained with Get-ChromiumSessionReference
        Required?                    true
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

### NOTES
````PowerShell
    Requires the Windows 10+ Operating System
-------------------------- EXAMPLE 1 --------------------------
PS C:\> Select-WebbrowserTab
PS C:\> Select-WebbrowserTab 3
PS C:\> Select-WebbrowserTab -Chrome 14
PS C:\> st -ch 14
````

<br/><hr/><hr/><br/>

##	Invoke-WebbrowserEvaluation
````PowerShell
Invoke-WebbrowserEvaluation          --> et, Eval
````

### SYNOPSIS
    Runs one or more scripts inside a selected webbrowser tab.

### SYNTAX
````PowerShell
Invoke-WebbrowserEvaluation [[-Scripts] <Object[]>] [-Inspect] [-AsJob] [-NoAutoSelectTab]
[<CommonParameters>]
````

### DESCRIPTION
    Runs one or more scripts inside a selected webbrowser tab.
    You can access 'data' object from within javascript, to synchronize data between PowerShell and the
    Webbrowser

### PARAMETERS
    -Scripts <Object[]>
        A string containing javascript, a url or a file reference to a javascript file
        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Accept wildcard characters?  false
    -Inspect [<SwitchParameter>]
        Will cause the developer tools of the webbrowser to break, before executing the scripts, allowing you to
        debug it
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -AsJob [<SwitchParameter>]
        Will execute the evaluation as a new background job.
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -NoAutoSelectTab [<SwitchParameter>]
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

### NOTES
````PowerShell
    Requires the Windows 10+ Operating System
-------------------------- EXAMPLE 1 --------------------------
PS C:\>
Invoke-WebbrowserEvaluation "document.title = 'hello world'"
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

<br/><hr/><hr/><br/>

##	Set-WebbrowserTabLocation
````PowerShell
Set-WebbrowserTabLocation            --> lt, Nav
````

### SYNOPSIS
    Navigates current selected tab to specified url

### SYNTAX
````PowerShell
Set-WebbrowserTabLocation [-Url] <String> [<CommonParameters>]
````

### DESCRIPTION
    Navigates current selected tab to specified url

### PARAMETERS
    -Url <String>
        The Url the browsertab should navigate too
        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

### NOTES
````PowerShell
    Requires the Windows 10+ Operating System
-------------------------- EXAMPLE 1 --------------------------
PS C:\> Set-WebbrowserTabLocation "https://github.com/microsoft"
````

<br/><hr/><hr/><br/>

##	Set-BrowserVideoFullscreen
````PowerShell
Set-BrowserVideoFullscreen           --> fsvideo
````

### SYNOPSIS
    Invokes a script in the current selected webbrowser tab to maximize the video player

### SYNTAX
````PowerShell
Set-BrowserVideoFullscreen [<CommonParameters>]
````

### DESCRIPTION
    Invokes a script in the current selected webbrowser tab to maximize the video player

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><hr/><br/>

##	Close-WebbrowserTab
````PowerShell
Close-WebbrowserTab                  --> CloseTab, ct
````

### SYNOPSIS
    Closes the currently selected webbrowser tab

### SYNTAX
````PowerShell
Close-WebbrowserTab [<CommonParameters>]
````

### DESCRIPTION
    Closes the currently selected webbrowser tab

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

### NOTES
````PowerShell
    Requires the Windows 10+ Operating System
-------------------------- EXAMPLE 1 --------------------------
PS C:\> Close-WebbrowserTab
PS C:\> st; ct;
````

<br/><hr/><hr/><br/>

##	Show-WebsiteInAllBrowsers
````PowerShell
Show-WebsiteInAllBrowsers            --> Show-UrlInAllBrowsers
````

### SYNOPSIS
    Will open an url into three different browsers + a incognito window, with a window mosaic layout

### SYNTAX
````PowerShell
Show-WebsiteInAllBrowsers [-Url] <String> [<CommonParameters>]
````

### DESCRIPTION
    Will open an url into three different browsers + a incognito window, with a window mosaic layout

### PARAMETERS
    -Url <String>
        Url to open
        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

### NOTES
````PowerShell
    Requires the Windows 10+ Operating System
    To actually see four windows, you need Google Chrome, Firefox and Microsoft Edge installed
-------------------------- EXAMPLE 1 --------------------------
PS C:\> Show-WebsiteInallBrowsers "https://www.google.com/"
````

<br/><hr/><hr/><br/>

##	Set-RemoteDebuggerPortInBrowserShortcuts
````PowerShell
Set-RemoteDebuggerPortInBrowserShortcuts
````

### SYNOPSIS
    Updates all browser shortcuts for current user, to enable the remote debugging port by default

### SYNTAX
````PowerShell
Set-RemoteDebuggerPortInBrowserShortcuts [<CommonParameters>]
````

### DESCRIPTION
    Updates all browser shortcuts for current user, to enable the remote debugging port by default

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

### NOTES
````PowerShell
Requires the Windows 10+ Operating System
````

<br/><hr/><hr/><br/>

##	Get-ChromeRemoteDebuggingPort
````PowerShell
Get-ChromeRemoteDebuggingPort
````

### SYNOPSIS
    Returns the configured remote debugging port for Google Chrome

### SYNTAX
````PowerShell
Get-ChromeRemoteDebuggingPort [<CommonParameters>]
````

### DESCRIPTION
    Returns the configured remote debugging port for Google Chrome

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

### NOTES
````PowerShell
Use $Global:EdgeDebugPort to override default value of 9222
````

<br/><hr/><hr/><br/>

##	Get-EdgeRemoteDebuggingPort
````PowerShell
Get-EdgeRemoteDebuggingPort
````

### SYNOPSIS
    Returns the configured remote debugging port for Microsoft Edge

### SYNTAX
````PowerShell
Get-EdgeRemoteDebuggingPort [<CommonParameters>]
````

### DESCRIPTION
    Returns the configured remote debugging port for Microsoft Edge

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

### NOTES
````PowerShell
Use $Global:EdgeDebugPort to override default value of 9223
````

<br/><hr/><hr/><br/>

##	Get-ChromiumRemoteDebuggingPort
````PowerShell
Get-ChromiumRemoteDebuggingPort
````

### SYNOPSIS
    Returns the configured remote debugging port for Microsoft Edge or Google Chrome, which ever is the default
    browser

### SYNTAX
````PowerShell
Get-ChromiumRemoteDebuggingPort [<CommonParameters>]
````

### DESCRIPTION
    Returns the configured remote debugging port for Microsoft Edge or Google Chrome, which ever is the default
    browser

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><hr/><br/>

##	Copy-OpenWebbrowserParameters
````PowerShell
Copy-OpenWebbrowserParameters
````

### SYNOPSIS
    Proxy function dynamic parameter block for the Open-Webbrowser cmdlet

### SYNTAX
````PowerShell
Copy-OpenWebbrowserParameters [[-ParametersToSkip] <String[]>] [<CommonParameters>]
````

### DESCRIPTION
    The dynamic parameter block of a proxy function. This block can be used to copy a proxy function target's
    parameters .

### PARAMETERS
    -ParametersToSkip <String[]>
        Required?                    false
        Position?                    1
        Default value                @()
        Accept pipeline input?       false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><hr/><br/>

##	Approve-FirefoxDebugging
````PowerShell
Approve-FirefoxDebugging
````

### SYNOPSIS
    Changes firefox settings to enable remotedebugging and app-mode startups of firefox

### SYNTAX
````PowerShell
Approve-FirefoxDebugging [<CommonParameters>]
````

### DESCRIPTION
    Changes firefox settings to enable remotedebugging and app-mode startups of firefox

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><hr/><br/>

##	Get-ChromiumSessionReference
````PowerShell
Get-ChromiumSessionReference
````

### SYNOPSIS
    Returns a reference that can be used with Select-WebbrowserTab -ByReference

### SYNTAX
````PowerShell
Get-ChromiumSessionReference [<CommonParameters>]
````

### DESCRIPTION
    Returns a reference that can be used with Select-WebbrowserTab -ByReference
    This can be usefull when you want to evaluate the webbrowser inside a Job.
    With this serializable reference, you can pass the webbrowser tab session reference on to the Job
    commandblock.

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216).

<br/><hr/><hr/><br/>
