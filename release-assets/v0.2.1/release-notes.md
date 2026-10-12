# Madabina CLI v0.2.1

This patch release refreshes the localized Asterisk telephony documentation and includes the guides in the downloadable archives and Debian packages. The telephony implementation is unchanged from v0.2.0.

The guides explain supported Ubuntu/Debian systemd hosts, installation and permissions for `madabina-telephony-helper`, the PJSIP/dialplan/queue/voicemail/module/codec forms, backup and rollback behavior, confirmed service actions, and the local-only security boundary. English, French, and Arabic copies are included in each archive and Debian package.

## Downloads

This release includes Windows, Linux, and macOS archives for AMD64 and ARM64, plus Debian packages for AMD64 and ARM64. Windows per-user setup installers are attached by the follow-up release workflow. Termux/Android is not included.

`go test ./...`, `go vet ./...`, `govulncheck ./...`, and Gitleaks passed. GoReleaser cross-built the target executables and generated the two Debian packages from the v0.2.1 source tag; the six archives were assembled from those matching build outputs. The Windows AMD64 executable reports version 0.2.1. Linux and macOS artifacts were cross-compiled and were not executed on those operating systems. Live Asterisk helper installation and service/configuration changes have not been validated against a host.

The attached `checksums.txt` contains SHA-256 hashes for the eight archive/package assets. A checksum downloaded from this same release detects transfer errors but does not independently authenticate the publisher.

## License

Madabina CLI is proprietary software. The included license permits redistribution of original, unmodified binaries only. See `LICENSE` and `THIRD_PARTY_NOTICES.md`; third-party components remain subject to their included license terms.
