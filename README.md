<hr/>

<img src="powershell.jpg" alt="drawing" width="50%"/>

<hr/>

### NAME

    GenXdev.Webbrowser

### SYNOPSIS
    A Windows PowerShell module that allows you to run scripts against your casual desktop webbrowser-tab

[![GenXdev.Webbrowser](https://img.shields.io/powershellgallery/v/GenXdev.Webbrowser.svg?style=flat-square&label=GenXdev.Webbrowser)](https://www.powershellgallery.com/packages/GenXdev.Webbrowser/) [![License](https://img.shields.io/github/license/renevaessen/GenXdev.Webbrowser?style=flat-square)](./LICENSE)

### FEATURES

    * ✅ evaluating javascript-string, javascript-files in opened webbrowser-tab
    * ✅ adding html script tags, by urll, to opened webbrowser-tabs, for normal javascript files or modules
    * ✅ evaluating scripts, with support for async patterns, like promises
    * ✅ evaluating asynchronous scripts, with support for yielded PowerShell pipeline returns

    * ✅ launching of default browser, Microsoft Edge, Google Chrome or Firefox
    * ✅ launching of webbrowser with full control of window positioning
    * ✅ launching of webbrowser in ApplicationMode, Incognito/In-Private
    * ✅ repositioning of already opened webbrowser

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
# Support for yielded pipeline results
    Select-WebbrowserTab;
    Invoke-WebbrowserEvaluation "

        for (let i = 0; i < 10; i++) {

            await (new Promise((resolve) => setTimeout(resolve, 1000)));

            yield i;
        }
    ";
````
### DEPENDENCIES
[![WinOS - Windows-10](https://img.shields.io/badge/WinOS-Windows--10--10.0.19041--SP0-brightgreen)](https://www.microsoft.com/en-us/windows/get-windows-10)
[![GenXdev.Helpers](https://img.shields.io/powershellgallery/v/GenXdev.Helpers.svg?style=flat-square&label=GenXdev.Helpers)](https://www.powershellgallery.com/packages/GenXdev.Helpers/) [![GenXdev.Windows](https://img.shields.io/powershellgallery/v/GenXdev.Windows.svg?style=flat-square&label=GenXdev.Windows)](https://www.powershellgallery.com/packages/GenXdev.Windows/)

### INSTALLATION
````PowerShell
Install-Module "GenXdev.Webbrowser" -Force
Import-Module "GenXdev.Webbrowser"
````
### UPDATE
````PowerShell
Update-Module
````
<br/><hr/><hr/><hr/><hr/><br/>
## SYNTAX
````PowerShell
    Open-Webbrowser -> wb

        [[-Url] <String[]>]
        [ ([-Edge] [-Chrome] [-Chromium] [-Firefox]) | [-All]]
        ( [-ApplicationMode] | [-Private] | [-NewWindow] )
        [-NoBrowserExtensions] [-RestoreFocus]
        [-Monitor <Int32>] [-FullScreen]
        [-Left] [-Top] [-Right] [-Bottom] [-Centered]
        [-ReturnProcess] [<CommonParameters>]
````
````PowerShell
    Select-WebbrowserTab -> st

        [[-id] <Int32>] [-Edge] [-Chrome] [<CommonParameters>]
````
````PowerShell
    Invoke-WebbrowserEvaluation -> Eval, et

        [[-Scripts] <Object[]>] [-Inspect] [-Edge] [-Chrome] [<CommonParameters>]
````
````PowerShell
    Close-WebbrowserTab -> CloseTab, ct
        [-Edge] [-Chrome] [<CommonParameters>]
````
````PowerShell
    Close-Webbrowser -> wbc
        [-Edge] [-Chrome] [-Chromium] [-Firefox] [-All] [-IncludeBackgroundProcesses]
        [<CommonParameters>]
````
````PowerShell
    Get-Webbrowser
````
````PowerShell
    Get-DefaultWebbrowser
````
````PowerShell
    Show-WebsiteInAllBrowsers [-Url] <String> [<CommonParameters>]
````
````PowerShell
    Get-ChromeRemoteDebuggingPort
````
````PowerShell
    Get-ChromiumRemoteDebuggingPort
````
````PowerShell
    Get-EdgeRemoteDebuggingPort
````
````PowerShell
    Set-RemoteDebuggerPortInBrowserShortcuts
````
<br/><hr/><hr/><hr/><hr/><br/>
# Cmdlets
### NAME
    Open-Webbrowser
### SYNOPSIS
    Opens one or more webbrowser instances
### SYNTAX
````PowerShell
Open-Webbrowser [[-Url] <String[]>] [-Private] [-Edge] [-Chrome]
                [-Chromium] [-Firefox] [-All] [-Monitor <Int32>] [-FullScreen]
                [-Left] [-Right] [-Top] [-Bottom] [-Centered] [-ApplicationMode] [-NoBrowserExtensions]
                [-RestoreFocus] [-NewWindow [-ReturnProcess] [<CommonParameters>]
````
### DESCRIPTION
    Opens one or more webbrowsers in a configurable manner, using commandline
    switches
### PARAMETERS
````
-Url <String[]>
    The url to open
    Required?                    false
    Position?                    1
    Default value
    Accept pipeline input?       true (ByValue)
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
    Open in Microsoft Edge or Google Chrome, depending on what the default
    browser is --> -c
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
    The monitor to use, 0 = default, 1 = secondary, -1 is discard --> -m, -mon
    Required?                    false
    Position?                    named
    Default value                1
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
    Default value                0
    Accept pipeline input?       false
    Accept wildcard characters?  false
-Height <Int32>
    The initial height of the webbrowser window
    Required?                    false
    Position?                    named
    Default value                0
    Accept pipeline input?       false
    Accept wildcard characters?  false
-X <Int32>
    The initial X position of the webbrowser window
    Required?                    false
    Position?                    named
    Default value                0
    Accept pipeline input?       false
    Accept wildcard characters?  false
-Y <Int32>
    The initial Y position of the webbrowser window
    Required?                    false
    Position?                    named
    Default value                0
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
-ReturnProcess [<SwitchParameter>]
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false

<CommonParameters>
    This cmdlet supports the common parameters: Verbose, Debug,
    ErrorAction, ErrorVariable, WarningAction, WarningVariable,
    OutBuffer, PipelineVariable, and OutVariable. For more information, see
    about_CommonParameters
    (https://go.microsoft.com/fwlink/?LinkID=113216).
````
### NOTES
````PowerShell
Requires the Windows 10+ Operating System

    This cmdlet was mend to be used, interactively.
    It performs some strange tricks to position windows, including
    invoking alt-tab keystrokes.
    It is best not to touch the keyboard or mouse, while it is doing that.

    For fast launches of multple urls:
    SET    : -Monitor -1
    AND    : DO NOT use any of these switches: -X, -Y, -Left, -Right, -Top, -Bottom or -RestoreFocus

    For browsers that are not installed on the system, no actions may be
    performed or errors occur - at all.
-------------------------- EXAMPLE 1 --------------------------
PS C:\> Open-Webbrowser -Chrome -Left -Top -Url "https://genxdev.net/"
PS C:\> @("https://genxdev.net/", "https://github.com/renevaessen/") | Open-Webbrowser

-------------------------- EXAMPLE 2 --------------------------

You can use the Open-Webbrowser cmdlet as a template, like so:

function Open-GoogleQuery {

    [CmdletBinding()]
    [Alias("q")]

    Param(
        [Alias("q", "Value", "Name", "Text")]
        [parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromRemainingArguments = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]] $Queries,
        ############################################################################
        # change default from default secondary monitor 1, to no specific monitor -1
        # this will speed up launching multiple webbrowsers at once
        [Alias("m", "mon")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "The monitor to use, 0 = default, -1 is discard"
        )]
        [int] $Monitor = -1
    )

    DynamicParam {

        Copy-OpenWebbrowserParameters -ParametersToSkip "Url", "Monitor"
    }

    Process {

        $PSBoundParameters.Remove("Queries") | Out-Null;
        $PSBoundParameters.Add("Url", "Url") | Out-Null;

        foreach ($Query in $Queries) {

            $PSBoundParameters["Url"] = (
              "https://www.google.com/search?q=$([Uri]::EscapeUriString($Query))"
            );

            Open-Webbrowser @PSBoundParameters
        }
    }
}
````
<br/><hr/><hr/><hr/><hr/><br/>
### NAME
    Select-WebbrowserTab
### SYNOPSIS
    Selects a webbrowser tab
### SYNTAX
````PowerShell
Select-WebbrowserTab [-id <Int32>] [-Edge] [-Chrome] [<CommonParameters>]

Select-WebbrowserTab [-ByReference] <Hashtable> [<CommonParameters>]
````
### DESCRIPTION
    Selects a webbrowser tab for use by the cmdlets
    'Invoke-WebbrowserEvaluation -> et, eval', 'Close-WebbrowserTab -> ct' and
    others
### PARAMETERS
````
-id <Int32>
    When '-Id' is not supplied, a list of available webbrowser tabs is
    shown, where the right value can be found
    Required?                    false
    Position?                    1
    Default value                -1
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
    Position?                    1
    Default value
    Accept pipeline input?       false
    Accept wildcard characters?  false

<CommonParameters>
    This cmdlet supports the common parameters: Verbose, Debug,
    ErrorAction, ErrorVariable, WarningAction, WarningVariable,
    OutBuffer, PipelineVariable, and OutVariable. For more information, see
    about_CommonParameters
    (https://go.microsoft.com/fwlink/?LinkID=113216).
````
### NOTES
````PowerShell
Requires the Windows 10+ Operating System

-------------------------- EXAMPLE 1 --------------------------
PS C:\> Select-WebbrowserTab
PS C:\> Select-WebbrowserTab 3
PS C:\> Select-WebbrowserTab -Chrome 14
PS C:\> st -ch 14
````
<br/><hr/><hr/><hr/><hr/><br/>
### NAME
    Invoke-WebbrowserEvaluation
### SYNOPSIS
    Runs one or more scripts inside a selected webbrowser tab.
### SYNTAX
````PowerShell
Invoke-WebbrowserEvaluation [[-Scripts] <Object[]>] [-Inspect] [-AsJob] [<CommonParameters>]
````
### DESCRIPTION
    Runs one or more scripts inside a selected webbrowser tab.
    You can access 'data' object from within javascript, to synchronize data
    between PowerShell and the Webbrowser.
### PARAMETERS
````
-Scripts <Object[]>
    A string containing javascript, a url or a file reference to a javascript file
    Required?                    false
    Position?                    1
    Default value
    Accept pipeline input?       true (ByValue, ByPropertyName)
    Accept wildcard characters?  false
-Inspect [<SwitchParameter>]
    Will cause the developer tools of the webbrowser to break, before executing the scripts, allowing you to debug it.
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
<CommonParameters>
    This cmdlet supports the common parameters: Verbose, Debug,
    ErrorAction, ErrorVariable, WarningAction, WarningVariable,
    OutBuffer, PipelineVariable, and OutVariable. For more information, see
    about_CommonParameters
    (https://go.microsoft.com/fwlink/?LinkID=113216).
````
### NOTES
````PowerShell
Requires the Windows 10+ Operating System

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
<br/><hr/><hr/><hr/><hr/><br/>

### NAME
    Get-ChromeRemoteDebuggingPort
### SYNTAX
````PowerShell
Get-ChromeRemoteDebuggingPort
````
### PARAMETERS
````
None
````
<br/><hr/><hr/><hr/><hr/><br/>
### NAME
    Get-ChromiumRemoteDebuggingPort
### SYNTAX
````PowerShell
Get-ChromiumRemoteDebuggingPort
````
### PARAMETERS
````
None
````
<br/><hr/><hr/><hr/><hr/><br/>

NAME
    Set-WebbrowserTabLocation

SYNOPSIS
    Navigates current selected tab to specified url

SYNTAX
````PowerShell
Set-WebbrowserTabLocation [-Url] <String> [<CommonParameters>]
````
DESCRIPTION
    Navigates current selected tab to specified url

PARAMETERS
````
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
    about_CommonParameters
    (https://go.microsoft.com/fwlink/?LinkID=113216).
````

NOTES
````PowerShell
    Requires the Windows 10+ Operating System

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\> Set-WebbrowserTabLocation "https://github.com/microsoft"
````
<br/><hr/><hr/><hr/><hr/><br/>
### NAME
    Close-WebbrowserTab
### SYNOPSIS
    Closes the currently selected webbrowser tab
### SYNTAX
````PowerShell
Close-WebbrowserTab [<CommonParameters>]
````
### DESCRIPTION
    Closes the currently selected webbrowser tab
### PARAMETERS
````
<CommonParameters>
    This cmdlet supports the common parameters: Verbose, Debug,
    ErrorAction, ErrorVariable, WarningAction, WarningVariable,
    OutBuffer, PipelineVariable, and OutVariable. For more information, see
    about_CommonParameters
    (https://go.microsoft.com/fwlink/?LinkID=113216).
````
### NOTES
````PowerShell
Requires the Windows 10+ Operating System


-------------------------- EXAMPLE 1 --------------------------
PS C:\> Close-WebbrowserTab
PS C:\> st; ct;
````
<br/><hr/><hr/><hr/><hr/><br/>
### NAME
    Get-EdgeRemoteDebuggingPort
### SYNTAX
````PowerShell
Get-EdgeRemoteDebuggingPort
````
### PARAMETERS
````
None
````
<br/><hr/><hr/><hr/><hr/><br/>

-------------------------- EXAMPLE 1 --------------------------
PS C:\> Close-WebbrowserTab
PS C:\> st; ct;
````
<br/><hr/><hr/><hr/><hr/><br/>
### NAME
    Close-Webbrowser
### SYNOPSIS
    Closes one or more webbrowser instances
### SYNTAX
````PowerShell
Close-Webbrowser [-Edge] [-Chrome] [-Chromium] [-Firefox] [-All]
[-IncludeBackgroundProcesses] [<CommonParameters>]
````
### DESCRIPTION
    Closes one or more webbrowser instances in a selective manner, using
    commandline switches
### PARAMETERS
````
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
    Closes Microsoft Edge or Google Chrome, depending on what the default
    browser is --> -c
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
    Closes all instances of the webbrowser, including background tasks and
    services
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
<CommonParameters>
    This cmdlet supports the common parameters: Verbose, Debug,
    ErrorAction, ErrorVariable, WarningAction, WarningVariable,
    OutBuffer, PipelineVariable, and OutVariable. For more information, see
    about_CommonParameters
    (https://go.microsoft.com/fwlink/?LinkID=113216).
````
### NOTES
````PowerShell
Requires the Windows 10+ Operating System


-------------------------- EXAMPLE 1 --------------------------
PS C:\> Close-Webbrowser -Chrome
PS C:\> Close-Webbrowser -Chrome -FireFox
PS C:\> Close-Webbrowser -All
PS C:\> wbc -a
````
<br/><hr/><hr/><hr/><hr/><br/>
### NAME
    Get-DefaultWebbrowser
### SYNOPSIS
    Returns the configured current webbrowser
### SYNTAX
````PowerShell
Get-DefaultWebbrowser [<CommonParameters>]
````
### DESCRIPTION
    Returns an object describing the configured current webbrowser for the
    current-user.
### PARAMETERS
````
<CommonParameters>
    This cmdlet supports the common parameters: Verbose, Debug,
    ErrorAction, ErrorVariable, WarningAction, WarningVariable,
    OutBuffer, PipelineVariable, and OutVariable. For more information, see
    about_CommonParameters
    (https://go.microsoft.com/fwlink/?LinkID=113216).
````
### NOTES
````PowerShell
Requires the Windows 10+ Operating System


-------------------------- EXAMPLE 1 --------------------------
PS C:\> & (Get-DefaultWebbrowser).Path https://www.github.com/
PS C:\> Get-DefaultWebbrowser | Format-List
````
<br/><hr/><hr/><hr/><hr/><br/>
### NAME
    Get-Webbrowser
### SYNOPSIS
    Returns a collection of installed modern webbrowsers
### SYNTAX
````PowerShell
Get-Webbrowser [<CommonParameters>]
````
### DESCRIPTION
    Returns an collection of objects each describing a installed modern
    webbrowser
### PARAMETERS
````
<CommonParameters>
    This cmdlet supports the common parameters: Verbose, Debug,
    ErrorAction, ErrorVariable, WarningAction, WarningVariable,
    OutBuffer, PipelineVariable, and OutVariable. For more information, see
    about_CommonParameters
    (https://go.microsoft.com/fwlink/?LinkID=113216).
````
### NOTES
````PowerShell
Requires the Windows 10+ Operating System

-------------------------- EXAMPLE 1 --------------------------
PS C:\> Get-Webbrowser | Foreach-Object { & $PSItem.Path https://www.github.com/ }
PS C:\> Get-Webbrowser | select Name, Description | Format-Table
PS C:\> Get-Webbrowser | select Name, Path | Format-Table
````
<br/><hr/><hr/><hr/><hr/><br/>
### NAME
    Set-RemoteDebuggerPortInBrowserShortcuts
### SYNOPSIS
    Updates all browser shortcuts for current user, to enable the remote
    debugging port by default
### SYNTAX
````PowerShell
Set-RemoteDebuggerPortInBrowserShortcuts [<CommonParameters>]
````
### DESCRIPTION
    Updates all browser shortcuts for current user, to enable the remote
    debugging port by default
### PARAMETERS
````
<CommonParameters>
    This cmdlet supports the common parameters: Verbose, Debug,
    ErrorAction, ErrorVariable, WarningAction, WarningVariable,
    OutBuffer, PipelineVariable, and OutVariable. For more information, see
    about_CommonParameters
    (https://go.microsoft.com/fwlink/?LinkID=113216).
````
### NOTES
````PowerShell
Requires the Windows 10+ Operating System

````
<br/><hr/><hr/><hr/><hr/><br/>
### NAME
    Show-WebsiteInAllBrowsers
### SYNOPSIS
    Will open an url into three different browsers + a incognito window, with
    a window mosaic layout
### SYNTAX
````PowerShell
Show-WebsiteInAllBrowsers [-Url] <String> [<CommonParameters>]
````
### DESCRIPTION
    Will open an url into three different browsers + a incognito window, with a window mosaic layout
### PARAMETERS
````
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
    about_CommonParameters
    (https://go.microsoft.com/fwlink/?LinkID=113216).
````
### NOTES
````PowerShell
Requires the Windows 10+ Operating System


    To actually see four windows, you need Google Chrome, Firefox and Microsoft Edge installed

-------------------------- EXAMPLE 1 --------------------------
PS C:\> Show-WebsiteInallBrowsers "https://www.google.com/"
````
<br/><hr/><hr/><hr/><hr/><br/>
### NAME
    Approve-FirefoxDebugging
### SYNOPSIS
    Changes firefox settings to enable remotedebugging and app-mode startups
    of firefox
### SYNTAX
````PowerShell
Approve-FirefoxDebugging [<CommonParameters>]
````
### DESCRIPTION
    Changes firefox settings to enable remotedebugging and app-mode startups
    of firefox
### PARAMETERS
````
<CommonParameters>
    This cmdlet supports the common parameters: Verbose, Debug,
    ErrorAction, ErrorVariable, WarningAction, WarningVariable,
    OutBuffer, PipelineVariable, and OutVariable. For more information, see
    about_CommonParameters
    (https://go.microsoft.com/fwlink/?LinkID=113216).
````
<br/><hr/><hr/><hr/><hr/><br/>
