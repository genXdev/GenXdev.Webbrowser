<hr/>

![](https://genxdev.net/Powershell.jpg)

<hr/>

## NAME

    GenXdev.Webbrowser

## SYNOPSIS

    Cmdlets for interacting with chromium webbrowsers (chrome, edge) using their debugging-ports.

    Also offers cmdlets for starting, stopping and positioning webbrowser windows
    over different monitors.

## TYPE
    PowerShell Module

## CmdLets and aliases
````Powershell

    Open-Webbrowser                                         -> wb
        [[-Url] <String[]>] [-Private] [-Edge] [-Chrome]
        [-Chromium] [-Firefox] [-All] [-Monitor <Int32>] [-FullScreen] [-Left]
        [-Right] [-Top] [-Bottom] [-Foreground] [-NoNewWindow] [<CommonParameters>]


    Select-WebbrowserTab                                    -> st
        [[-id] <Int32>] [-New] [-Edge] [-Chrome] [<CommonParameters>]


    Invoke-WebbrowserEvaluation                             -> Eval, et
        [[-scripts] <Object[]>] [-inspect] [-Edge] [-Chrome] [<CommonParameters>]


    Get-AllGoogleLinks -Query <String> [<CommonParameters>]


    Open-AllGoogleLinks                                     -> qlinks
        [-Query] <String> [<CommonParameters>]


    DownloadPDFs [<CommonParameters>]


    Close-WebbrowserTab                                     -> CloseTab, ct
        [-Edge] [-Chrome] [<CommonParameters>]


    Close-Webbrowser                                        -> wbc
        [-Edge] [-Chrome] [-Chromium] [-Firefox] [-All] [-IncludeBackgroundProcesses]
        [<CommonParameters>]


    Get-Webbrowser


    Get-DefaultWebbrowser


    Show-WebsiteInAllBrowsers    [-Url] <String> [<CommonParameters>]


    Get-ChromeRemoteDebuggingPort


    Get-ChromiumRemoteDebuggingPort


    Get-EdgeRemoteDebuggingPort


    Set-RemoteDebuggerPortInBrowserShortcuts

````
## DEPENDENCIES
    GenXdev.Helpers

## INSTALLATION
````Powershell

    Install-Module "GenXdev.Webbrowser" -Force
    Import-Module "GenXdev.Webbrowser"

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
    [-Chromium] [-Firefox] [-All] [-Monitor <Int32>] [-FullScreen] [-Left]
    [-Right] [-Top] [-Bottom] [-Foreground] [-NoNewWindow] [<CommonParameters>]
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
        Open in all registered modern browsers -> -a

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Monitor <Int32>
        The monitor to use, 0 = default, -1 is discard --> -m, -mon

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

    -Foreground [<SwitchParameter>]
        Do not restore Powershell window focus --> -fg

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -NoNewWindow [<SwitchParameter>]
        Re-use existing browser window, instead of creating a new one -> -nw,
        -nnw

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

        To disable any wait times due to this, you can disable it by;
            setting : -Monitor -1 -Foreground
            AND     : not providing any of these switches: -Left -Right -Top -Bottom

        Webbrowsers that are not installed on the system, cause no actions or errors

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\> Open-Webbrowser -Chrome -Left -Top -Url "https://genxdev.net/"

    PS C:\> @("https://genxdev.net/", "https://github.com/renevaessen/") |
                    Open-Webbrowser -Monitor -1 -Foreground -NoNewWindow
````
<br/><hr/><hr/><hr/><hr/><br/>

### NAME
    Select-WebbrowserTab

### SYNOPSIS
    Selects a webbrowser tab

### SYNTAX
    Select-WebbrowserTab [[-id] <Int32>] [-Edge] [-Chrome]
    [<CommonParameters>]

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

    -New [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
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
    Invoke-WebbrowserEvaluation [[-scripts] <Object[]>] [-inspect] [<CommonParameters>]
````
### DESCRIPTION
    Runs one or more scripts inside a selected webbrowser tab.
    You can access 'data' object from within javascript, to synchronize data
    between Powershell and the Webbrowser.

### PARAMETERS
````
    -scripts <Object[]>
        A string containing the javascript, or a file reference to a
        javascript file

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Accept wildcard characters?  false

    -inspect [<SwitchParameter>]
        Will cause the developer tools of the webbrowser to break, before
        executing the scripts, allowing you to debug it.

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

    PS C:\>

        # select last used webbrowser tab
        Select-WebbrowserTab;

        # create some data to transfer
        $Global:Data = @{ files= (Get-ChildItem *.* -file | % FullName)};

        # Synchronizing data
        [int] $number = Invoke-WebbrowserEvaluation "
            // show the data as json inside the browser
            document.body.innerHTML = JSON.stringify(data.files);

            // transfer the document title back to Powershell
            data.title = document.title; 123;";

        # show the results
        Write-Host "
            Document title : $($Global:Data.title)
            return value   : $Number
        ";

    PS C:\> Get-ChildItem *.js | Invoke-WebbrowserEvaluation -Edge
    PS C:\> ls *.js | et -e
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
````PowerShell
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

    -IncludeBackgroundProcesses [<SwitchParameter>] -> -Force
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
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters

        (https://go.microsoft.com/fwlink/?LinkID=113216).

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
    Get-Webbrowser [<CommonParameters>]

### DESCRIPTION
    Returns an collection of objects each describing a installed modern
    webbrowser

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters

        (https://go.microsoft.com/fwlink/?LinkID=113216).

### NOTES
````Powershell
    Requires the Windows 10+ Operating System

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\> Get-Webbrowser | Foreach-Object { & $PSItem.Path https://www.github.com/ }

    PS C:\> Get-Webbrowser | select Name, Description | Format-Table

    PS C:\> Get-Webbrowser | select Name, Path | Format-Table
````

<br/><hr/><hr/><hr/><hr/><br/>

### NAME
    Close-WebbrowserTab

### SYNOPSIS
    Closes the currently selected webbrowser tab


### SYNTAX
````Powershell
    Close-WebbrowserTab [<CommonParameters>]
````
### DESCRIPTION
    Closes the currently selected webbrowser tab

### PARAMETERS
````Powershell

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters

        (https://go.microsoft.com/fwlink/?LinkID=113216).
````
### NOTES
````Powershell
    Requires the Windows 10+ Operating System

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\> Close-WebbrowserTab

    PS C:\> st; ct;
````

<br/><hr/><hr/><hr/><hr/><br/>

### NAME
    Get-AllGoogleLinks

### SYNOPSIS
    Performs a google search in previously selected webbrowser tab and
    returns the links

### SYNTAX
````Powershell
    Get-AllGoogleLinks [-Query] <String> [<CommonParameters>]
````
### DESCRIPTION
    Performs a  google search in previously selected webbrowser tab and
    returns the links
### PARAMETERS
````Powershell
    -Query <String>
        The google query to perform

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
````Powershell

    Requires the Windows 10+ Operating System

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\>

        Select-WebbrowserTab;
        $Urls = Get-AllGoogleLinks "site:github.com Powershell module";
        $Urls
````

<br/><hr/><hr/><hr/><hr/><br/>

### NAME
    Open-AllGoogleLinks

### SYNOPSIS
    Performs an infinite auto opening google search in previously selected
    webbrowser tab.

### SYNTAX
````Powershell
    Open-AllGoogleLinks [-Query] <String> [<CommonParameters>]
````
### DESCRIPTION
    Performs a google search in previously selected webbrowser tab.
    Opens 10 tabs each times, pauses until initial tab is revisited
    Press ctrl-c to stop, or close the initial tab
### PARAMETERS
````Powershell
    -Query <String>
        The google query to perform

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
````Powershell

    Requires the Windows 10+ Operating System

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\>

        Select-WebbrowserTab;
        Open-AllGoogleLinks "site:github.com Powershell module"
````

<br/><hr/><hr/><hr/><hr/><br/>

### NAME
    DownloadPDFs

### SYNOPSIS
    Performs a google query in the previously selected webbrowser tab, and
    download all found pdf's into current directory

### SYNTAX
````Powershell
    DownloadPDFs [-Query] <String> [<CommonParameters>]
````
### DESCRIPTION
    Performs a google query in the previously selected webbrowser tab, and
    download all found pdf's into current directory
### PARAMETERS
````
    -Query <String>
        Parameter description

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
````Powershell
    Requires the Windows 10+ Operating System

    -------------------------- EXAMPLE 1 --------------------------

    PS D:\Downloads>

        mkdir pdfs;
        cd pdfs;
        Select-WebbrowserTab;
        DownloadPDFS "scientific paper co2"

````

<br/><hr/><hr/><hr/><hr/><br/>

### NAME
    Show-WebsiteInAllBrowsers

### SYNOPSIS
    Will open an url into three different browsers + a incognito window, with
    a window mosaic layout

### SYNTAX
````Powershell
    Show-WebsiteInAllBrowsers [-Url] <String> [<CommonParameters>]
````
### DESCRIPTION
    Will open an url into three different browsers + a incognito window, with
    a window mosaic layout
### PARAMETERS
````Powershell
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
````Powershell

        Requires the Windows 10+ Operating System

        To actually see four windows, you need Google Chrome, Firefox and
        Microsoft Edge installed

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\> Show-WebsiteInallBrowsers "https://www.google.com/"
````

<br/><hr/><hr/><hr/><hr/><br/>


### NAME
    Set-RemoteDebuggerPortInBrowserShortcuts

### SYNOPSIS
    Updates all browser shortcuts for current user, to enable the remote
    debugging port by default

### SYNTAX
````Powershell
    Set-RemoteDebuggerPortInBrowserShortcuts [<CommonParameters>]
````
### DESCRIPTION
    Updates all browser shortcuts for current user, to enable the remote
    debugging port by default
### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters

        (https://go.microsoft.com/fwlink/?LinkID=113216).
### NOTES

    Requires the Windows 10+ Operating System
<br/><hr/><hr/><hr/><hr/><br/>
