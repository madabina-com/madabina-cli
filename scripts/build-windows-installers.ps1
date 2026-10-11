[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^v?\d+\.\d+\.\d+$')]
    [string] $Tag
)

$ErrorActionPreference = 'Stop'
$version = $Tag.TrimStart('v')
$tagName = "v$version"
$repo = 'madabina-com/madabina-cli'
$baseUrl = "https://github.com/$repo/releases/download/$tagName"
$root = Split-Path -Parent $PSScriptRoot
$tempRoot = if ($env:RUNNER_TEMP) { $env:RUNNER_TEMP } else { [IO.Path]::GetTempPath() }
$work = Join-Path $tempRoot "madabina-windows-$version"
$outDir = Join-Path $root "build/windows-installers/$version"
New-Item -ItemType Directory -Force -Path $work, $outDir | Out-Null

$checksumPath = Join-Path $work 'checksums.txt'
& curl.exe --fail --location --silent --show-error "$baseUrl/checksums.txt" --output $checksumPath
if ($LASTEXITCODE -ne 0) { throw 'Could not download the published release checksums.' }
$checksumText = Get-Content -Raw $checksumPath

foreach ($arch in @('amd64', 'arm64')) {
    $zipName = "madabina_${version}_windows_${arch}.zip"
    $zipPath = Join-Path $work $zipName
    & curl.exe --fail --location --silent --show-error "$baseUrl/$zipName" --output $zipPath
    if ($LASTEXITCODE -ne 0) { throw "Could not download $zipName." }

    $escapedName = [regex]::Escape($zipName)
    $match = [regex]::Match($checksumText, "(?m)^([0-9a-fA-F]{64})\s+\*?$escapedName\s*$")
    if (-not $match.Success) { throw "No SHA-256 entry found for $zipName." }
    $expected = $match.Groups[1].Value.ToLowerInvariant()
    $actual = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne $expected) { throw "SHA-256 mismatch for $zipName." }

    $stage = Join-Path $work "stage-$arch"
    Expand-Archive -LiteralPath $zipPath -DestinationPath $stage -Force
    foreach ($required in @('madabina.exe', 'LICENSE', 'README.md', 'README.fr.md', 'README.ar.md', 'third_party_licenses')) {
        if (-not (Test-Path -LiteralPath (Join-Path $stage $required))) { throw "$zipName is missing $required." }
    }

    $installerName = "madabina_${version}_windows_${arch}_setup.exe"
    $installerPath = Join-Path $outDir $installerName
    & makensis.exe "/DVERSION=$version" "/DARCH=$arch" "/DSOURCE_DIR=$stage" "/DOUTPUT_FILE=$installerPath" (Join-Path $root 'packaging/windows/madabina.nsi')
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $installerPath)) { throw "NSIS failed to create $installerName." }
}

$existing = @($checksumText -split "`r?`n" | Where-Object { $_ -and $_ -notmatch '_setup\.exe\s*$' })
$newLines = foreach ($file in Get-ChildItem -LiteralPath $outDir -Filter '*_setup.exe' -File) {
    $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    "$hash  $($file.Name)"
}
Set-Content -LiteralPath (Join-Path $outDir 'checksums.txt') -Value (@($existing) + @($newLines)) -Encoding ascii

$wingetDir = Join-Path (Join-Path $outDir 'winget-manifests\m\Madabina\MadabinaCLI') $version
New-Item -ItemType Directory -Force -Path $wingetDir | Out-Null
$x64Hash = (Get-FileHash -LiteralPath (Join-Path $outDir "madabina_${version}_windows_amd64_setup.exe") -Algorithm SHA256).Hash.ToLowerInvariant()
$arm64Hash = (Get-FileHash -LiteralPath (Join-Path $outDir "madabina_${version}_windows_arm64_setup.exe") -Algorithm SHA256).Hash.ToLowerInvariant()

$versionManifest = @"
PackageIdentifier: Madabina.MadabinaCLI
PackageVersion: $version
DefaultLocale: en-US
ManifestType: version
ManifestVersion: 1.6.0
"@
$installerManifest = @"
PackageIdentifier: Madabina.MadabinaCLI
PackageVersion: $version
Installers:
  - Architecture: x64
    InstallerType: nullsoft
    InstallerUrl: https://github.com/madabina-com/madabina-cli/releases/download/v$version/madabina_${version}_windows_amd64_setup.exe
    InstallerSha256: $x64Hash
    Scope: user
    InstallerSwitches:
      Silent: /S
      SilentWithProgress: /S
  - Architecture: arm64
    InstallerType: nullsoft
    InstallerUrl: https://github.com/madabina-com/madabina-cli/releases/download/v$version/madabina_${version}_windows_arm64_setup.exe
    InstallerSha256: $arm64Hash
    Scope: user
    InstallerSwitches:
      Silent: /S
      SilentWithProgress: /S
ManifestType: installer
ManifestVersion: 1.6.0
"@
$localeManifest = @"
PackageIdentifier: Madabina.MadabinaCLI
PackageVersion: $version
PackageLocale: en-US
Publisher: Madabina LLC
PublisherUrl: https://madabina.com
PackageName: Madabina CLI
PackageUrl: https://github.com/madabina-com/madabina-cli
License: Proprietary
LicenseUrl: https://raw.githubusercontent.com/madabina-com/madabina-cli/main/LICENSE
ShortDescription: Native command-line interface for the Madabina ecosystem
Tags:
  - madabina
  - cli
ManifestType: defaultLocale
ManifestVersion: 1.6.0
"@
Set-Content -LiteralPath (Join-Path $wingetDir 'Madabina.MadabinaCLI.yaml') -Value $versionManifest -Encoding utf8
Set-Content -LiteralPath (Join-Path $wingetDir 'Madabina.MadabinaCLI.installer.yaml') -Value $installerManifest -Encoding utf8
Set-Content -LiteralPath (Join-Path $wingetDir 'Madabina.MadabinaCLI.locale.en-US.yaml') -Value $localeManifest -Encoding utf8
Get-ChildItem -LiteralPath $outDir -Recurse -File | Get-FileHash -Algorithm SHA256 | Format-Table -AutoSize
