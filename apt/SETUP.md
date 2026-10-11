# APT repository setup

The `publish-apt-repository.yml` workflow publishes Debian packages from each stable GitHub Release to GitHub Pages. It verifies release checksums, validates package name/version/architecture, creates separate AMD64 and ARM64 indexes, signs repository metadata, and publishes Linux and Windows bootstrap installers with SHA-256 manifests. A push that changes either installer or this workflow republishes the latest stable release. It does not build or alter the proprietary CLI binaries.

## One-time GitHub configuration

1. Create a dedicated RSA 4096 signing key on a trusted workstation. Protect it with a strong passphrase and keep an offline backup:

   ```sh
   gpg --quick-generate-key "Madabina LLC APT repository <packages@madabina.com>" rsa4096 sign 2y
   gpg --list-secret-keys --keyid-format LONG
   ```

2. Add two **Actions secrets** in the `madabina-com/madabina-cli` repository settings:
   - `APT_SIGNING_KEY`: ASCII-armored output of `gpg --armor --export-secret-keys KEY_ID`.
   - `APT_SIGNING_KEY_PASSPHRASE`: the key's passphrase.

   Keep the private key out of Git, issues, logs, and chat. The workflow imports it into the temporary runner only to sign repository metadata.

3. In **Settings → Pages**, set the publishing source to **GitHub Actions**.

4. Push this workflow, `apt/install.sh`, `scripts/install-windows.ps1`, and `apt/release.conf` to `main`. The push publishes the latest stable release plus both bootstrap installers and their SHA-256 manifests. You can also go to **Actions → Publish APT repository → Run workflow**, enter `v0.1.0`, and run it manually. Future stable GitHub Releases trigger publication automatically.

5. After a successful run, verify the published install scripts and checksum manifests at `https://packages.madabina.com/install.sh`, `https://packages.madabina.com/install.sh.sha256`, `https://packages.madabina.com/install-windows.ps1`, and `https://packages.madabina.com/install-windows.ps1.sha256`. Also verify `https://packages.madabina.com/apt-key-fingerprint.txt` matches the pinned signing-key fingerprint `A6561F99594315269612AD984B8D3B0CB32D4F67`.

The public Pages URL is `https://packages.madabina.com/`. Do not tell users that `apt install madabina` is available until the workflow succeeds and its signed `InRelease` is reachable there.
