################################################################################

<#
.SYNOPSIS
Executes JavaScript code in a selected web browser tab.

.DESCRIPTION
Executes JavaScript code in a selected browser tab with support for async/await,
promises, and data synchronization between PowerShell and the browser context.
Can execute code from strings, files, or URLs.

.PARAMETER Scripts
JavaScript code to execute. Can be string content, file paths, or URLs.
Accepts pipeline input.

.PARAMETER Inspect
Adds debugger statement before executing to enable debugging.

.PARAMETER NoAutoSelectTab
Prevents automatic tab selection if no tab is currently selected.

.PARAMETER Edge
Selects Microsoft Edge browser for execution.

.PARAMETER Chrome
Selects Google Chrome browser for execution.

.PARAMETER Page
Browser page object for execution when using ByReference mode.

.PARAMETER ByReference
Session reference object when using ByReference mode.

.EXAMPLE
# Execute simple JavaScript
Invoke-WebbrowserEvaluation "document.title = 'hello world'"
.EXAMPLE
PS>

# Synchronizing data
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
.EXAMPLE
PS>

# Support for promises
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
.EXAMPLE
PS>

# Support for promises and more

# this function returns all rows of all tables/datastores of all databases of indexedDb in the selected tab
# beware, not all websites use indexedDb, it could return an empty set

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

.EXAMPLE
PS>

# Support for yielded pipeline results
Select-WebbrowserTab -Force;
Invoke-WebbrowserEvaluation "

    for (let i = 0; i < 10; i++) {

        await (new Promise((resolve) => setTimeout(resolve, 1000)));

        yield i;
    }
";
.EXAMPLE
PS> Get-ChildItem *.js | Invoke-WebbrowserEvaluation -Edge
.EXAMPLE
PS> ls *.js | et -e
.NOTES
Requires the Windows 10+ Operating System
#>
function Invoke-WebbrowserEvaluation {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
    [Alias("Eval", "et")]

    param(
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = "JavaScript code, file path or URL to execute",
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)
        ]
        [Alias('FullName')]
        [object[]] $Scripts,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Break in browser debugger before executing",
            ValueFromPipeline = $false)
        ]
        [switch] $Inspect,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $false,
            HelpMessage = "Prevent automatic tab selection"
        )]
        [switch] $NoAutoSelectTab,
        ###############################################################################
        [Alias("e")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Use Microsoft Edge browser"
        )]
        [switch] $Edge,
        ###############################################################################
        [Alias("ch")]
        [parameter(
            Mandatory = $false,
            HelpMessage = "Use Google Chrome browser"
        )]
        [switch] $Chrome,
        ###############################################################################
        [Parameter(
            HelpMessage = "Browser page object reference",
            ValueFromPipeline = $false
        )]
        [object] $Page,
        ###############################################################################
        [Parameter(
            HelpMessage = "Browser session reference object",
            ValueFromPipeline = $false
        )]
        [PSCustomObject] $ByReference
    )

    Begin {
        # initialize reference tracking
        $reference = $null

        # handle reference initialization
        if (($null -eq $Page) -or ($null -eq $ByReference)) {

            try {
                $reference = Get-ChromiumSessionReference
                $Page = $Global:chromeController
            }
            catch {
                if ($NoAutoSelectTab -eq $true) {
                    throw $PSItem.Exception
                }

                # attempt auto-selection of browser tab
                Select-WebbrowserTab -Chrome:$Chrome -Edge:$Edge | Out-Null
                $Page = $Global:chromeController
                $reference = Get-ChromiumSessionReference
            }
        }
        else {
            $reference = $ByReference
        }

        # validate browser context
        if (($null -eq $Page) -or ($null -eq $reference)) {
            throw "No browser tab selected"
        }
    }

    Process {
        Write-Verbose "Processing JavaScript evaluation request..."

        # Define the custom JavaScript for Visibility API events and CSS overrides
        $visibilityScript = @"
document.addEventListener('visibilitychange', function() {
    console.log('Visibility changed to: ' + document.visibilityState);
});
"@

        $cssOverrideScript = @"
document.documentElement.style.setProperty('--default-color-scheme', 'dark');
"@

        # Subscribe to the FrameNavigated event to inject the custom JavaScript
        $null = Register-ObjectEvent -InputObject $page -EventName FrameNavigated -Action {
            $null = $page.EvaluateAsync($visibilityScript).Wait()
            $null = $page.EvaluateAsync($cssOverrideScript).Wait()
        }

        # enumerate provided scripts
        foreach ($js in $Scripts) {

            try {
                Set-Variable -Name "Data" -Value $reference.data -Scope Global

                # is it a file reference?
                if (($js -is [IO.FileInfo]) -or (($js -is [System.String]) -and [IO.File]::Exists($js))) {

                    # comming from Get-ChildItem command?
                    if ($js -is [IO.FileInfo]) {

                        # make it a string
                        $js = $js.FullName;
                    }

                    # it's a string with a path, load the content
                    $js = [IO.File]::ReadAllText($js, [System.Text.Encoding]::UTF8)
                }
                else {

                    # make it a string, if it isn't yet
                    if ($js -isnot [System.String] -or [string]::IsNullOrWhiteSpace($js)) {

                        $js = "$js";
                    }

                    if ([string]::IsNullOrWhiteSpace($js) -eq $false) {

                        [Uri] $uri = $null;
                        $isUri = (

                            [Uri]::TryCreate("$js", "absolute", [ref] $uri) -or (
                                $js.ToLowerInvariant().StartsWith("www.") -and
                                [Uri]::TryCreate("http://$js", "absolute", [ref] $uri)
                            )
                        ) -and $uri.IsWellFormedOriginalString() -and $uri.Scheme -like "http*";

                        if ($IsUri) {
                            Write-Verbose "is Uri"
                            $httpResult = Invoke-WebRequest -Uri $Js

                            if ($httpResult.StatusCode -eq 200) {

                                $type = "text/javascript";

                                if ($httpResult.Content -Match "[`r`n\s`t;,]import ") {

                                    $type = "module";
                                }
                                $ScriptHash = [GenXdev.Helpers.Hash]::FormatBytesAsHexString(
                                    [GenXdev.Helpers.Hash]::GetSha256BytesOfString($httpResult.Content));
                                $js = "
                                    let scripts = document.getElementsByTagName('script');
                                    for (let i = 0; i < scripts.length; i++) {

                                        let script = scripts[i];
                                        if (!!script && typeof script.getAttribute === 'function' && script.getAttribute('data-hash') === '$scriptHash') {
                                            return;
                                        }
                                    }
                                    let scriptTag = document.createElement('script');
                                    let scriptLoaded = false;
                                    let loaded = () => {  };

                                    scriptTag.innerHTML = $(($httpResult.Content | ConvertTo-Json));
                                    scriptTag.setAttribute('type', '$type');
                                    scriptTag.setAttribute('data-hash', '$ScriptHash');
                                    let head = document.getElementsByTagName('head')[0];
                                    if (!head) {
                                        head = document.createElement('head');
                                        document.appendChild(head);
                                    }
                                    head.appendChild(scriptTag);
                                ";
                            }
                            else {

                                throw "Downloading script '$js' resulted in http statuscode $($HttpResult.StatusCode) - $($HttpResult.StatusDescription)"
                            }
                        }
                    }
                }

                # '-Inspect' parameter provided?
                if ($Inspect -eq $true) {

                    # invoke a debug break-point
                    $js = "debugger;`r`n$js"
                }

                Write-Verbose "Processing: `r`n$($js.Trim())"

                # convert data object to json, and then again to make it a json string
                $json = ($reference.data | ConvertTo-Json -Compress -Depth 100 | ConvertTo-Json -Compress -Depth 100);

                # init result
                $result = $null;
                $ScriptHash = [GenXdev.Helpers.Hash]::FormatBytesAsHexString(
                    [GenXdev.Helpers.Hash]::GetSha256BytesOfString($js));

                $js = "(function(data) {

                let resultData = window['iwae$ScriptHash'] || {

                    started: false,
                    done: false,
                    success: true,
                    data: data,
                    returnValues: []
                }

                window['iwae$ScriptHash'] = resultData;

                function catcher(e) {

                    let resultData = window['iwae$ScriptHash'];
                    resultData.success = false;
                    resultData.done = true;
                    try {
                        resultData.returnValue = JSON.stringify(e);
                    }
                    catch (e2) {

                        resultData.returnValue = e+'';
                    }
                }

                if (!resultData.started) {

                    resultData.started = true;

                    try {

                        eval($("

                        (async () => {
                            let result;
                            try {

                                result = (async function*() { $js })();

                                let resultCount = 0;
                                let resultValue;
                                do {
                                    resultValue = await result.next();

                                    if (resultValue.value instanceof Promise) {

                                        resultValue.value = await resultValue.value;
                                    }

                                    let resultData = window['iwae$ScriptHash']

                                    if (resultCount++ === 0 && resultValue.done) {

                                        resultData.returnValue = resultValue.value;
                                    }
                                    else {
                                        if (!resultValue.done) {

                                            resultData.returnValues.push(resultValue.value);
                                        }
                                    }
                                } while (!resultValue.done)

                                let resultData = window['iwae$ScriptHash']
                                resultData.done = true;
                                resultData.success = true;
                            }
                            catch (e) {

                                catcher(e);
                            }
                        })()

                        " | ConvertTo-Json -Compress -Depth 100));
                    }
                    catch(e) {

                        catcher(e);
                    }
                }

                if (resultData.done) {

                    delete window['iwae$ScriptHash'];
                }

                let clone = JSON.parse(JSON.stringify(resultData));
                resultData.returnValues = [];
                return clone;
            })(JSON.parse($json));
        ";
                [int] $pollCount = 0;
                $result = $null;
                do {
                    # de-serialize outputed result object
                    # $reference = Get-ChromiumSessionReference
                    $result = $Page.EvaluateAsync($js, @()).Result
                    if ($null -eq $result) {

                        continue;
                    }
                    $result = ($result | ConvertFrom-Json);

                    if ($null -ne $result) {

                        Write-Verbose "Got results: [$($result.getType())] $($result | ConvertTo-Json -Compress -Depth 100)"
                    }

                    # all good?
                    if ($result -is [PSCustomObject]) {

                        # there was an exception thrown?
                        if ($result.subtype -eq "error") {

                            # re-throw
                            throw $result;
                        }

                        # got a data object?
                        if ($null -ne $result.data) {

                            # initialize
                            $reference.data = @{}

                            # enumerate properties
                            $result.data |
                            Get-Member -ErrorAction SilentlyContinue |
                            Where-Object -Property MemberType -Like *Property* |
                            ForEach-Object -ErrorAction SilentlyContinue {

                                # set in a case-sensitive manner
                                $reference.data."$($PSItem.Name)" = $result.data."$($PSItem.Name)"
                            }

                            Set-Variable -Name "Data" -Value ($reference.data) -Scope Global
                        }

                        $pollCount++;

                        if (($null -ne $result.returnValues) -and ($result.returnValues.Length -gt 0)) {

                            $result.returnValues | Write-Output
                            $result.returnValues = @();
                        }
                        $result.returnValues = @();
                    }
                } while (!!$result -and !$result.done -and (-not [Console]::KeyAvailable));

                # result indicate an exception thrown?
                if ($result.success -eq $false) {

                    if ($result.returnValue -is [string]) {

                        # re-throw
                        throw $result.returnValue;
                    }

                    throw "An unknown script parsing error occured";
                }

                if ($null -ne $result.returnValue) {

                    Write-Output $result.returnValue;
                }
            }
            Catch {

                throw "
                        $($PSItem.Exception) $($PSItem.InvocationInfo.PositionMessage)
                        $($PSItem.InvocationInfo.Line)
                    "
            }
        }
    }

    End {

    }
}
################################################################################
