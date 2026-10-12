# Madabina CLI v0.2.0

This release adds the local Asterisk telephony console at `/telephony` for Ubuntu and Debian hosts running systemd. It detects Asterisk, shows service and host diagnostics, and offers guided settings for PJSIP, extensions, trunks, dialplan, queues, voicemail, modules, and codecs. Service actions require confirmation. Privileged operations go through the restricted `madabina-telephony-helper`; the web console exposes no terminal or general file editor.

The Debian packages include the Linux helper and systemd unit. Install the package and follow its Asterisk helper README before enabling configuration changes or service actions. Other operating systems show telephony administration as unsupported. Network, firewall, TLS, and logs are read-only.

## Downloads

This release includes Windows, Linux, and macOS archives for AMD64 and ARM64, plus Debian packages for AMD64 and ARM64. Termux/Android is not included. The Windows setup installers are attached by the follow-up release workflow.

The Go test suite, `go vet`, and `govulncheck` passed. Linux AMD64 and ARM64 helper builds were cross-compiled from this tagged source. Live helper installation and Asterisk service/configuration operations have not yet been verified on an Ubuntu/Debian host; complete the package setup instructions and verify against a test system before relying on telephony administration.

The attached `checksums.txt` contains SHA-256 hashes for the eight archive/package assets. A checksum downloaded from this same release helps detect transfer errors but does not independently authenticate the publisher.

## License

Madabina CLI is proprietary software. The included license permits redistribution of original, unmodified binaries only. See `LICENSE` and `THIRD_PARTY_NOTICES.md`; third-party components remain subject to their included license terms.