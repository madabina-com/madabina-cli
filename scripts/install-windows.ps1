[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^\d+\.\d+\.\d+$')]
    [string] $Version,

    [Parameter(Mandatory)]
    [ValidateSet('x64', 'arm64')]
    [string] $Architecture
)

$ErrorActionPreference = 'Stop'
$assetArch = if ($Architecture -eq 'x64') { 'amd64' } else { 'arm64' }
$asset = "madabina_${Version}_windows_${assetArch}_setup.exe"
$baseUrl = "https://github.com/madabina-com/madabina-cli/releases/download/v$Version"
$tempDir = Join-Path ([IO.Path]::GetTempPath()) "madabina-install-$([guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory -Path $tempDir | Out-Null

try {
    $checksums = Join-Path $tempDir 'checksums.txt'
    $installer = Join-Path $tempDir $asset
    & curl.exe --fail --location --silent --show-error --retry 2 "$baseUrl/checksums.txt" --output $checksums
    if ($LASTEXITCODE -ne 0) { throw 'Unable to download the official checksum manifest.' }
    & curl.exe --fail --location --silent --show-error --retry 2 "$baseUrl/$asset" --output $installer
    if ($LASTEXITCODE -ne 0) { throw "Unable to download $asset." }

    $pattern = "(?m)^([0-9a-fA-F]{64})\s+\*?$([regex]::Escape($asset))\s*$"
    $match = [regex]::Match((Get-Content -Raw $checksums), $pattern)
    if (-not $match.Success) { throw "The official checksum manifest has no entry for $asset." }
    $expected = $match.Groups[1].Value.ToLowerInvariant()
    $actual = (Get-FileHash -LiteralPath $installer -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne $expected) { throw 'Installer SHA-256 verification failed; installation was stopped.' }

    $process = Start-Process -FilePath $installer -Wait -PassThru
    if ($process.ExitCode -ne 0) { throw "Installer exited with code $($process.ExitCode)." }
}
finally {
    Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}
