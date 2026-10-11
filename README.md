# Madabina CLI binaries

Madabina CLI is proprietary software distributed by Madabina LLC. This repository is the public distribution page for official binary releases. It does not contain the CLI source code.

## Release status

Madabina CLI `v0.1.0` is the first official binary release. Download the versioned archives, Debian packages, and SHA-256 manifest from the [Madabina CLI Releases page](https://github.com/madabina-com/madabina-cli/releases). Choose the package for your operating system and CPU architecture, then verify its checksum before installing it. A checksum downloaded from the same release confirms transfer integrity; it does not independently authenticate the publisher.

The Linux installer was not validated on an actual Linux runtime for this release. See the release notes before installing. Do not install or redistribute files marked `SNAPSHOT`; they are local validation candidates, not official releases.

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
