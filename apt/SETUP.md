# APT repository setup

The `publish-apt-repository.yml` workflow publishes Debian packages from each stable GitHub Release to GitHub Pages. It verifies release checksums, validates package name/version/architecture, creates separate AMD64 and ARM64 indexes, and signs repository metadata. It does not build or alter the proprietary CLI binaries.

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

4. Push this workflow and `apt/release.conf` to `main`. Then go to **Actions → Publish APT repository → Run workflow**, enter `v0.1.0`, and run it once to publish the current release. Future stable GitHub Releases trigger publication automatically.

5. After the first successful run, verify the published key fingerprint at `https://madabina-com.github.io/madabina-cli/apt-key-fingerprint.txt` and record it in the public installation documentation so users can compare it through an independent trusted channel.

The Pages site URL is `https://madabina-com.github.io/madabina-cli/`. Do not tell users that `apt install madabina` is available until the initial workflow succeeds and its signed `InRelease` is reachable there.
