<#
.SYNOPSIS
Refreshes the .NET assemblies committed under PSGSuite/lib.

.DESCRIPTION
Downloads the NuGet packages PSGSuite depends on and replaces the contents of
PSGSuite/lib with their assemblies. The DLLs are committed to the repo so that
building the module requires no network access; run this script only when you
want to pick up newer Google SDK releases, then review and commit the result.

Packages marked 'latest' resolve to the newest stable version on nuget.org.
The remaining pins match what the upstream PSGSuite build shipped.

.EXAMPLE
./tools/Update-GoogleSDK.ps1
#>
[CmdletBinding()]
param(
    [string]
    $Destination = (Join-Path (Split-Path $PSScriptRoot -Parent) 'PSGSuite' 'lib')
)

$ErrorActionPreference = 'Stop'

$packages = @(
    @{ Id = 'BouncyCastle.Crypto.dll'; Version = '1.8.1' }
    @{ Id = 'MimeKit'; Version = '1.10.1' }
    @{ Id = 'Newtonsoft.Json'; Version = '12.0.3' }
    @{ Id = 'Google.Apis'; Version = 'latest' }
    @{ Id = 'Google.Apis.Admin.DataTransfer.datatransfer_v1'; Version = 'latest' }
    @{ Id = 'Google.Apis.Admin.Directory.directory_v1'; Version = 'latest' }
    @{ Id = 'Google.Apis.Admin.Reports.reports_v1'; Version = 'latest' }
    @{ Id = 'Google.Apis.AlertCenter.v1beta1'; Version = 'latest' }
    @{ Id = 'Google.Apis.Auth'; Version = 'latest' }
    @{ Id = 'Google.Apis.Calendar.v3'; Version = 'latest' }
    @{ Id = 'Google.Apis.Classroom.v1'; Version = 'latest' }
    @{ Id = 'Google.Apis.Core'; Version = 'latest' }
    @{ Id = 'Google.Apis.Docs.v1'; Version = 'latest' }
    @{ Id = 'Google.Apis.Drive.v3'; Version = 'latest' }
    @{ Id = 'Google.Apis.DriveActivity.v2'; Version = 'latest' }
    @{ Id = 'Google.Apis.Gmail.v1'; Version = 'latest' }
    @{ Id = 'Google.Apis.Groupssettings.v1'; Version = 'latest' }
    @{ Id = 'Google.Apis.HangoutsChat.v1'; Version = 'latest' }
    @{ Id = 'Google.Apis.Licensing.v1'; Version = 'latest' }
    @{ Id = 'Google.Apis.Oauth2.v2'; Version = 'latest' }
    @{ Id = 'Google.Apis.PeopleService.v1'; Version = 'latest' }
    @{ Id = 'Google.Apis.Script.v1'; Version = 'latest' }
    @{ Id = 'Google.Apis.Sheets.v4'; Version = 'latest' }
    @{ Id = 'Google.Apis.Slides.v1'; Version = 'latest' }
    @{ Id = 'Google.Apis.Tasks.v1'; Version = 'latest' }
)

$staging = Join-Path ([System.IO.Path]::GetTempPath()) "PSGSuite-SDK-$([System.Guid]::NewGuid().ToString('N'))"
$outDir = Join-Path $staging 'out'
New-Item -Path $staging, $outDir -ItemType Directory | Out-Null

try {
    $summary = foreach ($package in $packages) {
        $id = $package.Id
        $version = $package.Version
        if ($version -eq 'latest') {
            # flatcontainer's version index is sorted ascending; take the newest stable
            $index = Invoke-RestMethod "https://api.nuget.org/v3-flatcontainer/$($id.ToLower())/index.json"
            $version = @($index.versions | Where-Object { $_ -notmatch '-' })[-1]
        }
        Write-Host "[$id] $version"

        $nupkg = Join-Path $staging "$id.zip"
        Invoke-WebRequest "https://api.nuget.org/v3-flatcontainer/$($id.ToLower())/$version/$($id.ToLower()).$version.nupkg" -OutFile $nupkg
        $extracted = Join-Path $staging "$id.extracted"
        Expand-Archive -Path $nupkg -DestinationPath $extracted

        # Google/MimeKit/Newtonsoft packages ship netstandard targets; BouncyCastle's DLL sits at the lib root
        $libDir = @('netstandard2.0', 'netstandard1.3', '') |
            ForEach-Object { Join-Path $extracted 'lib' $_ } |
            Where-Object { Test-Path (Join-Path $_ '*.dll') } |
            Select-Object -First 1
        if (-not $libDir) {
            throw "[$id] No DLLs found under the package's lib folder!"
        }
        $dlls = Get-ChildItem $libDir -Filter '*.dll' | Copy-Item -Destination $outDir -PassThru

        [PSCustomObject]@{
            Package = $id
            Version = $version
            DLLs    = $dlls.Name -join ', '
        }
        Remove-Item $nupkg -Force
        Remove-Item $extracted -Recurse -Force
    }

    if (Test-Path $Destination) {
        Get-ChildItem $Destination -Filter '*.dll' | Remove-Item -Force
    }
    else {
        New-Item -Path $Destination -ItemType Directory | Out-Null
    }
    Get-ChildItem $outDir -Filter '*.dll' | Copy-Item -Destination $Destination -Force

    $summary | Format-Table -AutoSize
    Write-Host "Updated $((Get-ChildItem $Destination -Filter '*.dll').Count) DLLs in $Destination"
}
finally {
    Remove-Item $staging -Recurse -Force -ErrorAction SilentlyContinue
}
