# Madabina CLI v0.1.1

This release adds configurable IPv4 binding for the local web console. It continues to bind to `127.0.0.1` by default. To make it reachable from other devices on a trusted LAN, run `madabina web --host 0.0.0.0` (also accepted as `madabina web -host=0.0.0.0`) and allow the selected port in the host firewall. Do not expose the console to untrusted networks.

## Downloads

This release includes Windows, Linux, and macOS archives for AMD64 and ARM64, plus Debian packages for AMD64 and ARM64. Termux/Android is not included.

The Windows AMD64 executable was run on Windows and its LAN-binding mode returned HTTP 200 from the local status endpoint. Linux and macOS assets were cross-compiled; they were not run on those operating systems. The Windows ARM64 asset was cross-compiled and was not run on ARM64 hardware. Linux package installation was not validated on an actual Linux runtime.

The attached `checksums.txt` contains SHA-256 hashes for the eight archive/package assets. A checksum downloaded from this same release helps detect transfer errors but does not independently authenticate the publisher. The Windows per-user setup installers will be attached by the release workflow after publication.

## License

Madabina CLI is proprietary software. The included license permits redistribution of original, unmodified binaries only. See `LICENSE` and `THIRD_PARTY_NOTICES.md`; third-party components remain subject to their included license terms.
