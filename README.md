# Madabina CLI binaries

Madabina CLI is proprietary software distributed by Madabina LLC. This repository is the public distribution page for official binary releases. It does not contain the CLI source code.

## Release status

Madabina CLI `v0.2.0` is the latest release. Download the versioned archives, Debian packages, Windows installers, and SHA-256 manifest from the [Madabina CLI Releases page](https://github.com/madabina-com/madabina-cli/releases). Choose the package for your operating system and CPU architecture, then verify its checksum before installing it. A checksum downloaded from the same release confirms transfer integrity; it does not independently authenticate the publisher.

Release v0.2.0 includes the local Asterisk console at `/telephony`. Its supported host is Ubuntu/Debian with systemd; a separately installed helper is required for configuration changes and service actions. See the [English](docs/telephony.md), [French](docs/telephony.fr.md), or [Arabic](docs/telephony.ar.md) feature guide. Do not install or redistribute files marked `SNAPSHOT`; they are local validation candidates, not official releases.

## npm installation (pending review)

The `madabina-cli` v0.1.1 npm release and its platform packages have been submitted to npm and are awaiting review and approval. npm installation is not available yet. After approval, install with `npm install --global madabina-cli`, then run `madabina --version`. npm binaries will support Linux and macOS x64/ARM64 and Windows ARM64; Windows x64 remains available from the GitHub release installers. Termux/Android is not included. See [`npm/README.md`](npm/README.md) for installation status and supported platforms.

## Windows installation

Per-user setup installers for Windows x64 and ARM64 are available on the [v0.2.0 release page](https://github.com/madabina-com/madabina-cli/releases/tag/v0.2.0).

### One-command installer

Open PowerShell and paste this one-line command. It downloads and verifies the bootstrap script, selects the latest stable release and your Windows architecture, verifies the setup executable against the release checksum, and starts the per-user installer:

```powershell
$d=Join-Path $env:TEMP ('madabina-'+[guid]::NewGuid().ToString('N'));New-Item -ItemType Directory -Path $d|Out-Null;try{$s=Join-Path $d 'madabina-install-windows.ps1';$m=Join-Path $d 'install-windows.ps1.sha256';curl.exe -fsSL https://packages.madabina.com/install-windows.ps1 -o $s;if($LASTEXITCODE -ne 0){throw 'Script download failed'};curl.exe -fsSL https://packages.madabina.com/install-windows.ps1.sha256 -o $m;if($LASTEXITCODE -ne 0){throw 'Checksum download failed'};$e=[regex]::Match((Get-Content -Raw $m),'(?m)^([0-9a-fA-F]{64})\s+madabina-install-windows\.ps1\s*$').Groups[1].Value;$a=(Get-FileHash -LiteralPath $s -Algorithm SHA256).Hash;if(-not $e -or $a -ne $e){throw 'Bootstrap SHA-256 verification failed'};powershell.exe -NoProfile -ExecutionPolicy Bypass -File $s;if($LASTEXITCODE -ne 0){throw "Installer failed with code $LASTEXITCODE"}}finally{Remove-Item -LiteralPath $d -Recurse -Force -ErrorAction SilentlyContinue}
```

The SHA-256 manifest is hosted on the same HTTPS domain, so it detects transfer errors but does not independently authenticate the bootstrap publisher.

### Manual download and verification

To download the setup yourself, choose `amd64` for Windows x64 or `arm64` for Windows ARM64, verify its hash against `checksums.txt`, then launch it:

```powershell
$version = '0.2.0'; $arch = 'amd64' # use 'arm64' for Windows ARM64
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

Version `v0.2.0` includes Windows, Linux, and macOS on AMD64 and ARM64, plus Debian packages for AMD64 and ARM64. Android/Termux ARM64 is planned for a later release.

## Debian / Ubuntu APT repository

### One-command installer

On Debian or Ubuntu (AMD64 or ARM64), this single command downloads the installer and its SHA-256 manifest, checks the file before running it, then adds the signed APT source and installs Madabina CLI:

```sh
d="$(mktemp -d)" && trap 'rm -rf "$d"' EXIT && curl -fsSL https://packages.madabina.com/install.sh -o "$d/madabina-install.sh" && curl -fsSL https://packages.madabina.com/install.sh.sha256 -o "$d/install.sh.sha256" && (cd "$d" && sha256sum -c install.sh.sha256) && bash "$d/madabina-install.sh"
```

The installer checks that the downloaded APT signing key has the pinned fingerprint `A6561F99594315269612AD984B8D3B0CB32D4F67` before configuring the repository. It asks for `sudo` when required. The SHA-256 manifest is served from the same HTTPS domain, so it detects transfer errors but does not independently authenticate the installer publisher.

### Manual APT setup

If you prefer configuring APT yourself, use:

```sh
curl -fsSL https://packages.madabina.com/madabina-archive-keyring.gpg -o /tmp/madabina-archive-keyring.gpg
fingerprint="$(gpg --batch --show-keys --with-colons /tmp/madabina-archive-keyring.gpg | awk -F: '$1 == "fpr" { print toupper($10); exit }')"
test "$fingerprint" = 'A6561F99594315269612AD984B8D3B0CB32D4F67' || { echo 'APT signing key fingerprint mismatch' >&2; exit 1; }
sudo install -D -m 0644 /tmp/madabina-archive-keyring.gpg /usr/share/keyrings/madabina-cli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/madabina-cli-archive-keyring.gpg] https://packages.madabina.com stable main" | sudo tee /etc/apt/sources.list.d/madabina-cli.list >/dev/null
sudo apt update
sudo apt install madabina
```

The repository covers Debian/Ubuntu AMD64 and ARM64. See [`apt/SETUP.md`](apt/SETUP.md) for publisher configuration.
