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
    Open-Webbrowser -> wb

        [[-Url] <String[]>]
        [ ([-Edge] [-Chrome] [-Chromium] [-Firefox]) | [-All]]
        ( [-ApplicationMode] | [-Private] | [-NewWindow] )
        [-NoBrowserExtensions] [-RestoreFocus]
        [-Monitor <Int32>] [-FullScreen]
        [-Left] [-Top] [-Right] [-Bottom]
        [<CommonParameters>]
````
````Powershell
    Select-WebbrowserTab -> st

        [[-id] <Int32>] [-New] [-Edge] [-Chrome] [<CommonParameters>]
````
````Powershell
    Invoke-WebbrowserEvaluation -> Eval, et

        [[-scripts] <Object[]>] [-inspect] [-Edge] [-Chrome] [<CommonParameters>]
````
````Powershell
    Get-GoogleSearchResultUrls -Query <String> [[-Max] <int>] [<CommonParameters>]
````
````Powershell
    Open-AllGoogleLinks -> qlinks
        [-Query] <String> [<CommonParameters>]
````
````Powershell
    DownloadPDFs [[-Max] <int>] [<CommonParameters>]
````
````Powershell
    Close-WebbrowserTab -> CloseTab, ct
        [-Edge] [-Chrome] [<CommonParameters>]
````
````Powershell
    Close-Webbrowser -> wbc
        [-Edge] [-Chrome] [-Chromium] [-Firefox] [-All] [-IncludeBackgroundProcesses]
        [<CommonParameters>]
````
````Powershell
    Get-Webbrowser
````
````Powershell
    Get-DefaultWebbrowser
````
````Powershell
    Show-WebsiteInAllBrowsers [-Url] <String> [<CommonParameters>]
````
````Powershell
    Get-ChromeRemoteDebuggingPort
````
````Powershell
    Get-ChromiumRemoteDebuggingPort
````
````Powershell
    Get-EdgeRemoteDebuggingPort
````
````Powershell
    Set-RemoteDebuggerPortInBrowserShortcuts
````
## DEPENDENCIES
    GenXdev.Helpers, GenXdev.Windows

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
                [-Right] [-Top] [-Bottom] [-ApplicationMode] [-NoBrowserExtensions]
                [-RestoreFocus] [-NewWindow] [<CommonParameters>]
````
### DESCRIPTION
    Opens one or more webbrowsers in a configurable manner, using commandline
    switches
### PARAMETERS\r
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
    Restore Powershell window focus --> -bg
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
    It is best not to touch the keyboard or mouse, while it is doing that,
    for the best experience.
    setting: -Monitor -1
    AND    : not using any of these switches: -Left -Right -Top -Bottom -RestoreFocus
    -Bottom -RestoreFocus
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
            ValueFromRemainingArguments = $false,
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
Select-WebbrowserTab [[-id] <Int32>] [-Edge] [-Chrome] [<CommonParameters>]
````
### DESCRIPTION
    Selects a webbrowser tab for use by the cmdlets
    'Invoke-WebbrowserEvaluation -> et, eval', 'Close-WebbrowserTab -> ct' and
    others
### PARAMETERS\r
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
### PARAMETERS\r
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
    # Synchronizing data
    Select-WebbrowserTab;
    $Global:Data = @{ files= (Get-ChildItem *.* -file | % FullName)};
    [int] $number = Invoke-WebbrowserEvaluation "
        document.body.innerHTML =
            JSON.stringify(data.files); data.title = document.title; 123;
        ";

    Write-Host "
        Document title : $($Global:Data.title)
        return value   : $Number
    ";

PS C:\> Get-ChildItem *.js | Invoke-WebbrowserEvaluation -Edge
PS C:\> ls *.js | et -e
````
<br/><hr/><hr/><hr/><hr/><br/>
### NAME
    DownloadPDFs
### SYNOPSIS
    Performs a google query in the previously selected webbrowser tab, and
    download all found pdf's into current directory
### SYNTAX
````PowerShell
DownloadPDFs [-Query] <String> [<CommonParameters>]
````
### DESCRIPTION
    Performs a google query in the previously selected webbrowser tab, and
    download all found pdf's into current directory
### PARAMETERS\r
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
````PowerShell
Requires the Windows 10+ Operating System


-------------------------- EXAMPLE 1 --------------------------
PS D:\Downloads>mkdir pdfs; cd pdfs; Select-WebbrowserTab; DownloadPDFS
"scientific paper co2"
````
<br/><hr/><hr/><hr/><hr/><br/>
### NAME
    Get-GoogleSearchResultUrls
### SYNOPSIS
    Performs a  google search in previously selected webbrowser tab and
    returns the links
### SYNTAX
````PowerShell
Get-GoogleSearchResultUrls [-Query] <String> [<CommonParameters>]
````
### DESCRIPTION
    Performs a  google search in previously selected webbrowser tab and
    returns the links
### PARAMETERS\r
````
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
````PowerShell
Requires the Windows 10+ Operating System


-------------------------- EXAMPLE 1 --------------------------
PS C:\> Select-WebbrowserTab; $Urls = Get-GoogleSearchResultUrls "site:github.com Powershell module"; $Urls
````
<br/><hr/><hr/><hr/><hr/><br/>
### NAME
    Get-ChromeRemoteDebuggingPort
### SYNTAX
````PowerShell
Get-ChromeRemoteDebuggingPort
````
### PARAMETERS\r
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
### PARAMETERS\r
````
None
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
### PARAMETERS\r
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
### PARAMETERS\r
````
None
````
<br/><hr/><hr/><hr/><hr/><br/>
### NAME
    Open-AllGoogleLinks
### SYNOPSIS
    Performs an infinite auto opening google search in previously selected
    webbrowser tab.
### SYNTAX
````PowerShell
Open-AllGoogleLinks [-Query] <String> [<CommonParameters>]
````
### DESCRIPTION
    Performs a google search in previously selected webbrowser tab.
    Opens 10 tabs each times, pauses until initial tab is revisited
    Press ctrl-c to stop, or close the initial tab
### PARAMETERS\r
````
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
````PowerShell
Requires the Windows 10+ Operating System

-------------------------- EXAMPLE 1 --------------------------
PS C:\> Select-WebbrowserTab; Open-AllGoogleLinks "site:github.com Powershell module"
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
### PARAMETERS\r
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
### PARAMETERS\r
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
### PARAMETERS\r
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
### PARAMETERS\r
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
### PARAMETERS\r
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
### PARAMETERS\r
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
### PARAMETERS\r
````
<CommonParameters>
    This cmdlet supports the common parameters: Verbose, Debug,
    ErrorAction, ErrorVariable, WarningAction, WarningVariable,
    OutBuffer, PipelineVariable, and OutVariable. For more information, see
    about_CommonParameters
    (https://go.microsoft.com/fwlink/?LinkID=113216).
````
<br/><hr/><hr/><hr/><hr/><br/>
