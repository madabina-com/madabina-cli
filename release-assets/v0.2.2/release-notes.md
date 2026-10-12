# Madabina CLI v0.2.2

Patch release for the local Asterisk administration console.

## What changed

- Allow `/telephony` administration through an explicitly trusted HTTPS reverse-proxy origin while the web console remains bound to loopback.
- Keep telephony API access unavailable when the console is bound directly to a LAN interface; reject other hosts and cross-origin requests.
- Mark session cookies `Secure` when a trusted HTTPS origin is configured.
- Add `madabina web --trusted-origin https://pbx.example.com`; this option requires loopback binding and cannot be combined with desktop mode.
- Update the French, English, and Arabic README and Asterisk setup guides with Caddy reverse-proxy instructions.

## Validation

- `go test ./...`
- `go vet ./...`
- GoReleaser v2.18.3 Linux, Windows, and macOS archives plus Debian packages.
- Windows AMD64 binary reports `madabina version 0.2.2`.
- All eight release artifacts are covered by `checksums.txt`.

The Debian packages target Linux AMD64 and ARM64. A live Ubuntu/Debian Asterisk host was not available for an end-to-end helper/service test.
