# npm distribution

The public npm package is a launcher for the original, unmodified Madabina CLI
binary. It does not contain or publish the Go source code. Platform packages
are assembled only from checksum-verified assets attached to an official
GitHub Release; the Madabina license and third-party notices travel with each
binary package. Windows x64 is temporarily unavailable from npm while npm
reviews the package name; Windows ARM64 remains available.

## User installation

After the first successful npm publication:

```sh
npm install --global madabina-cli
madabina --version
```

Requires Node.js/npm. Available binaries are Linux and macOS x64/ARM64 and
Windows ARM64. Termux/Android is not included.

## Publisher setup

1. Create an npm account controlled by Madabina LLC and enable two-factor
   authentication for publishing.
2. Create a narrowly scoped npm granular access token that can publish public
   packages. Do not commit the token.
3. Add it to the GitHub repository as Actions secret `NPM_TOKEN`.
4. After an official GitHub release exists, manually run **Publish npm
   packages** from GitHub Actions with its tag, such as `v0.1.1`. The binary
   release is currently created with `GITHUB_TOKEN`, so its `release: published`
   event does not reliably start another workflow. The npm workflow validates
   each archive against that release's `checksums.txt`, publishes the available
   platform packages, then publishes `madabina-cli`.
5. Confirm the package versions on npm, then install on one machine for each
   target platform before announcing availability.

The package name `madabina-cli` returned HTTP 404 from the npm registry during
preparation, indicating no public package was listed at that time. The name is
not reserved until the first publish succeeds. npm package names are
case-insensitive and the name could be claimed before publication.

Adding this workflow does not publish anything. Publication requires manually
dispatching it with an existing release tag and configuring `NPM_TOKEN`.
