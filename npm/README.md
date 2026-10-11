# npm distribution

The public npm package is a launcher for the original, unmodified Madabina CLI
binary. It does not contain or publish the Go source code. Platform packages
are assembled only from checksum-verified assets attached to an official
GitHub Release; the Madabina license and third-party notices travel with each
binary package. Windows x64 is temporarily unavailable from npm while npm
reviews the package name; Windows ARM64 remains available.

## User installation

After npm approves the staged v0.1.1 packages:

```sh
npm install --global madabina-cli
madabina --version
```

Requires Node.js/npm. The v0.1.1 packages have been submitted to npm and are
awaiting review and approval; installation is not available until that is
complete. Available targets after approval are Linux and macOS x64/ARM64 and
Windows ARM64. Windows x64 is temporarily omitted from npm. Termux/Android is
not included.
