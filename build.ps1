<#
.SYNOPSIS
Builds PSGSuite from source into BuildOutput/.

.DESCRIPTION
Compiles every function under PSGSuite/Private and PSGSuite/Public into a
single psm1, copies the committed SDK assemblies from PSGSuite/lib, and
updates the manifest's exported functions and aliases. Building requires no
network access; the Google SDK DLLs are committed to the repo (refresh them
with tools/Update-GoogleSDK.ps1).

.PARAMETER Task
Compile - build the module into BuildOutput/PSGSuite/<version> (always runs)
Import  - import the compiled module into the current session (default)
Test    - run the Pester test suite against the compiled module

.EXAMPLE
./build.ps1

Compiles and imports the module.

.EXAMPLE
./build.ps1 -Task Test

Compiles the module and runs the Pester tests against it.
#>
[CmdletBinding()]
param(
    [parameter(Position = 0)]
    [ValidateSet('Compile', 'Import', 'Test')]
    [string[]]
    $Task = @('Compile', 'Import')
)
$ErrorActionPreference = 'Stop'

$moduleName = 'PSGSuite'
$sourceDir = Join-Path $PSScriptRoot $moduleName
$manifest = Import-PowerShellDataFile (Join-Path $sourceDir "$moduleName.psd1")
$outputDir = Join-Path $PSScriptRoot 'BuildOutput'
$outputModDir = Join-Path $outputDir $moduleName
$outputModVerDir = Join-Path $outputModDir $manifest.ModuleVersion

function Resolve-ModuleDependency {
    param([string]$Name, [string]$MinimumVersion)
    try {
        Import-Module $Name -MinimumVersion $MinimumVersion -Verbose:$false
    }
    catch {
        Write-Host "Installing module dependency: $Name >= $MinimumVersion"
        Install-Module $Name -MinimumVersion $MinimumVersion -Repository PSGallery -Scope CurrentUser -Force -AllowClobber -SkipPublisherCheck
        Import-Module $Name -MinimumVersion $MinimumVersion -Verbose:$false
    }
}

# ---------------------------------------------------------------- Compile ----
Write-Host "Compiling $moduleName $($manifest.ModuleVersion) to $outputModVerDir"
Remove-Module $moduleName -Force -ErrorAction SilentlyContinue
if (Test-Path $outputModDir) {
    Remove-Item $outputModDir -Recurse -Force
}
New-Item -Path $outputModVerDir -ItemType Directory -Force | Out-Null

$psm1 = Copy-Item -Path (Join-Path $sourceDir "$moduleName.psm1") -Destination (Join-Path $outputModVerDir "$moduleName.psm1") -PassThru
$functionsToExport = @()
foreach ($scope in @('Private', 'Public')) {
    Get-ChildItem -Path (Join-Path $sourceDir $scope) -Filter '*.ps1' -Recurse -File | ForEach-Object {
        [System.IO.File]::AppendAllText($psm1.FullName, ("$([System.IO.File]::ReadAllText($_.FullName))`n"))
        if ($scope -eq 'Public') {
            $functionsToExport += $_.BaseName
            [System.IO.File]::AppendAllText($psm1.FullName, ("Export-ModuleMember -Function '$($_.BaseName)'`n"))
        }
    }
}

$aliasFile = Join-Path $sourceDir 'Aliases' "$moduleName.Aliases.ps1"
$aliasHashContents = (Get-Content $aliasFile -Raw).Trim()
$aliasesToExport = (. $aliasFile).Keys

# Module footer: alias registration and config loading. Kept identical to what
# the previous psake build appended.
@"

Import-GoogleSDK

if (`$global:PSGSuiteKey -and `$MyInvocation.BoundParameters['Debug']) {
    `$prevDebugPref = `$DebugPreference
    `$DebugPreference = "Continue"
    Write-Debug "```$global:PSGSuiteKey is set to a `$(`$global:PSGSuiteKey.Count * 8)-bit key!"
    `$DebugPreference = `$prevDebugPref
}

`$aliasHash = $aliasHashContents

foreach (`$key in `$aliasHash.Keys) {
    try {
        New-Alias -Name `$key -Value `$aliasHash[`$key] -Force
    }
    catch {
        Write-Error "[ALIAS: `$(`$key)] `$(`$_.Exception.Message.ToString())"
    }
}

Export-ModuleMember -Alias '*'

if (!(Test-Path (Join-Path "~" ".scrthq"))) {
    New-Item -Path (Join-Path "~" ".scrthq") -ItemType Directory -Force | Out-Null
}

if (`$PSVersionTable.ContainsKey('PSEdition') -and `$PSVersionTable.PSEdition -eq 'Core' -and !`$Global:PSGSuiteKey -and !`$IsWindows) {
    if (!(Test-Path (Join-Path (Join-Path "~" ".scrthq") "BlockCoreCLREncryptionWarning.txt"))) {
        Write-Warning "CoreCLR does not support DPAPI encryption! Setting a basic AES key to prevent errors. Please create a unique key as soon as possible as this will only obfuscate secrets from plain text in the Configuration, the key is not secure as is. If you would like to prevent this message from displaying in the future, run the following command:`n`nBlock-CoreCLREncryptionWarning`n"
    }
    `$Global:PSGSuiteKey = [Byte[]]@(1..16)
    `$ConfigScope = "User"
}

if (`$Global:PSGSuiteKey -is [System.Security.SecureString]) {
    `$Method = "SecureString"
    if (!`$ConfigScope) {
        `$ConfigScope = "Machine"
    }
}
elseif (`$Global:PSGSuiteKey -is [System.Byte[]]) {
    `$Method = "AES Key"
    if (!`$ConfigScope) {
        `$ConfigScope = "Machine"
    }
}
else {
    `$Method = "DPAPI"
    `$ConfigScope = "User"
}

Add-MetadataConverter -Converters @{
    [SecureString] = {
        `$encParams = @{}
        if (`$Global:PSGSuiteKey -is [System.Byte[]]) {
            `$encParams["Key"] = `$Global:PSGSuiteKey
        }
        elseif (`$Global:PSGSuiteKey -is [System.Security.SecureString]) {
            `$encParams["SecureKey"] = `$Global:PSGSuiteKey
        }
    'ConvertTo-SecureString "{0}"' -f (ConvertFrom-SecureString `$_ @encParams)
    }
    "Secure" = {
        param([string]`$String)
        `$encParams = @{}
        if (`$Global:PSGSuiteKey -is [System.Byte[]]) {
            `$encParams["Key"] = `$Global:PSGSuiteKey
        }
        elseif (`$Global:PSGSuiteKey -is [System.Security.SecureString]) {
            `$encParams["SecureKey"] = `$Global:PSGSuiteKey
        }
        ConvertTo-SecureString `$String @encParams
    }
    "ConvertTo-SecureString" = {
        param([string]`$String)
        `$encParams = @{}
        if (`$Global:PSGSuiteKey -is [System.Byte[]]) {
            `$encParams["Key"] = `$Global:PSGSuiteKey
        }
        elseif (`$Global:PSGSuiteKey -is [System.Security.SecureString]) {
            `$encParams["SecureKey"] = `$Global:PSGSuiteKey
        }
        ConvertTo-SecureString `$String @encParams
    }
}

try {
    `$confParams = @{
        Scope = `$ConfigScope
    }
    if (`$ConfigName) {
        `$confParams["ConfigName"] = `$ConfigName
        `$Script:ConfigName = `$ConfigName
    }
    try {
        if (`$global:PSGSuite) {
            Write-Warning "Using config `$(if (`$global:PSGSuite.ConfigName){"name '`$(`$global:PSGSuite.ConfigName)' "})found in variable: ```$global:PSGSuite"
            Write-Verbose "`$((`$global:PSGSuite | Format-List | Out-String).Trim())"
            if (`$global:PSGSuite -is [System.Collections.Hashtable]) {
                `$global:PSGSuite = New-Object PSObject -Property `$global:PSGSuite
            }
            `$script:PSGSuite = `$global:PSGSuite
        }
        else {
            Get-PSGSuiteConfig @confParams -ErrorAction Stop
        }
    }
    catch {
        if (Test-Path "`$ModuleRoot\`$env:USERNAME-`$env:COMPUTERNAME-`$env:PSGSuiteDefaultDomain-PSGSuite.xml") {
            Get-PSGSuiteConfig -Path "`$ModuleRoot\`$env:USERNAME-`$env:COMPUTERNAME-`$env:PSGSuiteDefaultDomain-PSGSuite.xml" -ErrorAction Stop
            Write-Warning "No Configuration.psd1 found at scope '`$ConfigScope'; falling back to legacy XML. If you would like to convert your legacy XML to the newer Configuration.psd1, run the following command:`n`nGet-PSGSuiteConfig -Path '`$ModuleRoot\`$env:USERNAME-`$env:COMPUTERNAME-`$env:PSGSuiteDefaultDomain-PSGSuite.xml' -PassThru | Set-PSGSuiteConfig`n"
        }
        else {
            Write-Warning "There was no config returned! Please make sure you are using the correct key or have a configuration already saved."
        }
    }
}
catch {
    Write-Warning "There was no config returned! Please make sure you are using the correct key or have a configuration already saved."
}

"@ | Add-Content -Path $psm1 -Encoding UTF8

Copy-Item -Path (Join-Path $sourceDir 'lib') -Destination $outputModVerDir -Recurse
Copy-Item -Path (Join-Path $sourceDir "$moduleName.psd1") -Destination $outputModVerDir

# Manifest validation needs the module's RequiredModules present
Resolve-ModuleDependency -Name Configuration -MinimumVersion 1.3.1
Update-ModuleManifest -Path (Join-Path $outputModVerDir "$moduleName.psd1") -FunctionsToExport ($functionsToExport | Sort-Object) -AliasesToExport ($aliasesToExport | Sort-Object)
Write-Host "Compiled $($functionsToExport.Count) functions and $($aliasesToExport.Count) aliases"

# ----------------------------------------------------------------- Import ----
if ($Task -contains 'Import') {
    Write-Host "Importing compiled module"
    Import-Module (Join-Path $outputModVerDir "$moduleName.psd1") -Force -Global -Verbose:$false
}

# ------------------------------------------------------------------- Test ----
if ($Task -contains 'Test') {
    # The test suite is written for Pester 4
    try {
        Import-Module Pester -MinimumVersion 4.10.1 -MaximumVersion 4.99.99 -ErrorAction Stop -Verbose:$false
    }
    catch {
        Write-Host "Installing Pester 4"
        Install-Module Pester -RequiredVersion 4.10.1 -Repository PSGallery -Scope CurrentUser -Force -SkipPublisherCheck
        Import-Module Pester -RequiredVersion 4.10.1 -Verbose:$false
    }

    # Environment the test files expect
    $env:BHProjectName = $moduleName
    $env:BHProjectPath = $PSScriptRoot
    $env:BHBranchName = "$(git rev-parse --abbrev-ref HEAD)".Trim()
    $env:BHCommitMessage = (@(git log -1 --pretty=%B) -join "`n").Trim()

    $pathSeparator = [System.IO.Path]::PathSeparator
    $origModulePath = $env:PSModulePath
    if ($env:PSModulePath.Split($pathSeparator) -notcontains $outputDir) {
        $env:PSModulePath = $outputDir + $pathSeparator + $origModulePath
    }
    # Module functions branch on $ErrorActionPreference (throw vs Write-Error), and
    # they resolve it from the global scope. The tests expect Stop, which the old
    # psake harness set for the whole run.
    $origGlobalEap = $global:ErrorActionPreference
    $global:ErrorActionPreference = 'Stop'
    try {
        Remove-Module $moduleName -Force -ErrorAction SilentlyContinue
        Import-Module $outputModDir -Force -Verbose:$false
        Write-Host "Invoking Pester"
        $testResults = Invoke-Pester -Path (Join-Path $PSScriptRoot 'Tests') -OutputFormat NUnitXml -OutputFile (Join-Path $outputDir 'TestResults.xml') -PassThru
        if ($testResults.FailedCount -gt 0) {
            $testResults.TestResult | Where-Object { -not $_.Passed } | Format-List | Out-String | Write-Host
            throw "$($testResults.FailedCount) Pester test(s) failed."
        }
        Write-Host "All $($testResults.PassedCount) Pester tests passed"
    }
    finally {
        $global:ErrorActionPreference = $origGlobalEap
        $env:PSModulePath = $origModulePath
    }
}
