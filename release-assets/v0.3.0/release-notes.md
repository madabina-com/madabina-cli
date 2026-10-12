# Madabina CLI v0.3.0

This release adds confirmed local package installers for Ubuntu/Debian hosts with systemd:

- `madabina install dns` installs and starts BIND9.
- `madabina install telephony` (alias `asterisk`) installs and starts Asterisk.
- `madabina install proxy` installs and starts Caddy.

Each command previews package, service, and port effects and requires explicit confirmation. It does not modify UFW. These installers do not configure DNS zones or views, authenticated Caddy routing, operator credentials, or a Madabina Web systemd unit. The `/dns` management page is not included. The Asterisk helper must still be installed and enabled separately for telephony configuration and service actions.

The release also includes the existing `/telephony` console and `--trusted-origin` proxy support. Supported binary targets are Windows, Linux, and macOS AMD64/ARM64, with Debian packages for AMD64/ARM64. Android/Termux is not included. Read the localized installation and feature guides in the distribution repository.

SHA-256 checksums are provided for all eight archives and Debian packages. They verify transfer integrity when downloaded from the same HTTPS release but do not independently authenticate the publisher.
