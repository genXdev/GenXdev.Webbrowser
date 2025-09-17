<##############################################################################
Part of PowerShell module : GenXdev.Webbrowser
Original cmdlet filename  : Invoke-WebbrowserEvaluation.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.274.2025
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
Executes JavaScript code in a selected web browser tab.

.DESCRIPTION
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
Execute simple JavaScript
Invoke-WebbrowserEvaluation "document.title = 'hello world'"
.EXAMPLE
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
.EXAMPLE
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
.EXAMPLE
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

.EXAMPLE
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

.EXAMPLE
PS>

Support for yielded pipeline results
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
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [Alias('Eval', 'et')]

    param(
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = 'JavaScript code, file path or URL to execute',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)
        ]
        [Alias('FullName')]
        [object[]] $Scripts,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Break in browser debugger before executing',
            ValueFromPipeline = $false)
        ]
        [switch] $Inspect,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $false,
            HelpMessage = 'Prevent automatic tab selection'
        )]
        [switch] $NoAutoSelectTab,
        ###############################################################################
        [Alias('e')]
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Use Microsoft Edge browser'
        )]
        [switch] $Edge,
        ###############################################################################
        [Alias('ch')]
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Use Google Chrome browser'
        )]
        [switch] $Chrome,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Browser page object reference',
            ValueFromPipeline = $false
        )]
        [object] $Page,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Browser session reference object',
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
                $reference = GenXdev.Webbrowser\Get-ChromiumSessionReference
                $Page = $Global:chromeController
            }
            catch {
                if ($NoAutoSelectTab -eq $true) {
                    throw $PSItem.Exception
                }

                # attempt auto-selection of browser tab
                try {
                    Microsoft.PowerShell.Utility\Write-Verbose "Auto-selecting browser tab due to missing session reference..."
                    GenXdev.Webbrowser\Select-WebbrowserTab -Chrome:$Chrome -Edge:$Edge | Microsoft.PowerShell.Core\Out-Null
                    $Page = $Global:chromeController
                    $reference = GenXdev.Webbrowser\Get-ChromiumSessionReference
                    Microsoft.PowerShell.Utility\Write-Verbose "Auto-selection completed successfully"
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Verbose "Auto-selection failed: $($PSItem.Exception.Message)"
                    # Re-throw with more context about what failed
                    throw "Failed to establish browser connection. Auto-selection error: $($PSItem.Exception.Message). Try running 'Select-WebbrowserTab -Force' manually first."
                }
            }
        }
        else {
            $reference = $ByReference
        }

        # validate browser context
        if (($null -eq $Page) -or ($null -eq $reference)) {

            throw 'No browser tab selected, use Select-WebbrowserTab to select a tab first.'
        }

        # Define the custom JavaScript for Visibility API events and CSS overrides
        $visibilityScript = @'
document.addEventListener('visibilitychange', function() {
    console.log('Visibility changed to: ' + document.visibilityState);
});
'@

        $cssOverrideScript = @'
document.documentElement.style.setProperty('--default-color-scheme', 'dark');
'@

        # Subscribe to the FrameNavigated event to inject the custom JavaScript
        $null = Microsoft.PowerShell.Utility\Register-ObjectEvent -InputObject $page -EventName FrameNavigated -Action {
            $null = $page.EvaluateAsync($visibilityScript).Wait()
            $null = $page.EvaluateAsync($cssOverrideScript).Wait()
        }
    }


    process {
        Microsoft.PowerShell.Utility\Write-Verbose 'Processing JavaScript evaluation request...'

        # enumerate provided scripts
        foreach ($js in $Scripts) {

            try {

                if ($js -is [System.IO.FileInfo]) {

                    # make it a string
                    $js = $js.FullName;
                }

                Microsoft.PowerShell.Utility\Set-Variable -Name 'Data' -Value $reference.data -Scope Global

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

                            [Uri]::TryCreate("$js", 'absolute', [ref] $uri) -or (
                                $js.ToLowerInvariant().StartsWith('www.') -and
                                [Uri]::TryCreate("http://$js", 'absolute', [ref] $uri)
                            )
                        ) -and $uri.IsWellFormedOriginalString() -and $uri.Scheme -like 'http*';

                        if ($IsUri) {
                            Microsoft.PowerShell.Utility\Write-Verbose 'is Uri'
                            $httpResult = Microsoft.PowerShell.Utility\Invoke-WebRequest -Uri $Js

                            if ($httpResult.StatusCode -eq 200) {

                                $type = 'text/javascript';

                                if ($httpResult.Content -Match "[`r`n\s`t;,]import ") {

                                    $type = 'module';
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

                                    scriptTag.innerHTML = $(($httpResult.Content | Microsoft.PowerShell.Utility\ConvertTo-Json));
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

                Microsoft.PowerShell.Utility\Write-Verbose "Processing: `r`n$($js.Trim())"

                # convert data object to json, and then again to make it a json string
                $json = ($reference.data | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 100 | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 100);

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

                        " | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 100));
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
                    $result = ($result | Microsoft.PowerShell.Utility\ConvertFrom-Json);

                    if ($null -ne $result) {

                        Microsoft.PowerShell.Utility\Write-Verbose "Got results: [$($result.getType())] $($result | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 100)"
                    }

                    # all good?
                    if ($result -is [PSCustomObject]) {

                        # there was an exception thrown?
                        if ($result.subtype -eq 'error') {

                            # re-throw
                            throw $result;
                        }

                        # got a data object?
                        if ($null -ne $result.data) {

                            # initialize
                            $reference.data = @{}

                            # enumerate properties
                            $result.data |
                                Microsoft.PowerShell.Utility\Get-Member -ErrorAction SilentlyContinue |
                                Microsoft.PowerShell.Core\Where-Object -Property MemberType -Like *Property* |
                                Microsoft.PowerShell.Core\ForEach-Object -ErrorAction SilentlyContinue {

                                    # set in a case-sensitive manner
                                    $reference.data."$($PSItem.Name)" = $result.data."$($PSItem.Name)"
                                }

                            Microsoft.PowerShell.Utility\Set-Variable -Name 'Data' -Value ($reference.data) -Scope Global
                        }

                        $pollCount++;

                        if (($null -ne $result.returnValues) -and ($result.returnValues.Length -gt 0)) {

                            $result.returnValues | Microsoft.PowerShell.Utility\Write-Output
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

                    throw 'An unknown script parsing error occured';
                }

                if ($null -ne $result.returnValue) {

                    Microsoft.PowerShell.Utility\Write-Output $result.returnValue;
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