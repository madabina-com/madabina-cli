# Madabina CLI binaries

Madabina CLI is proprietary software distributed by Madabina LLC. This repository is the public distribution page for official binary releases. It does not contain the CLI source code.

## Release status

Madabina CLI `v0.1.0` is the first official binary release. Download the versioned archives, Debian packages, and SHA-256 manifest from the [Madabina CLI Releases page](https://github.com/madabina-com/madabina-cli/releases). Choose the package for your operating system and CPU architecture, then verify its checksum before installing it. A checksum downloaded from the same release confirms transfer integrity; it does not independently authenticate the publisher.

The Linux installer was not validated on an actual Linux runtime for this release. See the release notes before installing. Do not install or redistribute files marked `SNAPSHOT`; they are local validation candidates, not official releases.

## Windows installation

Per-user setup installers for Windows x64 and ARM64 are being attached to v0.1.0. Once the `*_setup.exe` files appear on the release page, use PowerShell to download the installer and checksum manifest, verify SHA-256, and launch it:

```powershell
$version = '0.1.0'; $arch = 'amd64' # use 'arm64' for Windows ARM64
$name = "madabina_${version}_windows_${arch}_setup.exe"
$base = "https://github.com/madabina-com/madabina-cli/releases/download/v$version"
$checksums = Join-Path $env:TEMP 'madabina-checksums.txt'; $installer = Join-Path $env:TEMP $name
curl.exe --fail --location --silent --show-error "$base/checksums.txt" --output $checksums; if ($LASTEXITCODE -ne 0) { throw 'Checksum download failed' }
curl.exe --fail --location --silent --show-error "$base/$name" --output $installer; if ($LASTEXITCODE -ne 0) { throw 'Installer download failed' }
$expected = ([regex]::Match((Get-Content -Raw $checksums), "(?m)^([0-9a-fA-F]{64})\s+\*?$([regex]::Escape($name))\s*$")).Groups[1].Value
if (-not $expected -or (Get-FileHash $installer -Algorithm SHA256).Hash -ne $expected) { throw 'SHA-256 verification failed' }
Start-Process $installer -Wait
```

The installer uses the current user's local programs directory, updates the user's `PATH`, preserves the CLI license and third-party notices, and does not require administrator rights. The community WinGet manifest is prepared by the release workflow but has not yet been submitted or merged; `winget install Madabina.MadabinaCLI` is not available yet. A checksum served with the same HTTPS release verifies transfer integrity but does not independently authenticate the publisher.

## License and notices

The Madabina CLI license permits use and free redistribution of the original, unmodified binaries only, subject to the included license. It does not grant rights to redistribute source code or modified binaries. Resale requires separate written permission from Madabina LLC. See [LICENSE](LICENSE) and the [third-party notices](THIRD_PARTY_NOTICES.md).

Third-party components remain subject to their own license terms, included under `third_party_licenses/` when applicable.

## Supported release targets

Version `v0.1.0` includes Windows, Linux, and macOS on AMD64 and ARM64, plus Debian packages for AMD64 and ARM64. Android/Termux ARM64 is planned for a later release.

## Debian / Ubuntu APT repository

APT repository publication is being configured. After the first successful deployment, install with:

```sh
curl -fsSL https://madabina-com.github.io/madabina-cli/madabina-archive-keyring.gpg | sudo tee /usr/share/keyrings/madabina-cli-archive-keyring.gpg >/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/madabina-cli-archive-keyring.gpg] https://madabina-com.github.io/madabina-cli stable main" | sudo tee /etc/apt/sources.list.d/madabina-cli.list >/dev/null
sudo apt update
sudo apt install madabina
```

The repository covers Debian/Ubuntu AMD64 and ARM64. Until the first deployment succeeds, install the `.deb` package from the [releases page](https://github.com/madabina-com/madabina-cli/releases) instead. See [`apt/SETUP.md`](apt/SETUP.md) for the one-time publisher setup.
