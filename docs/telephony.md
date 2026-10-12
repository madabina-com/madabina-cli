# Asterisk telephony console

Madabina CLI v0.2.0 adds a local Asterisk administration page at `http://127.0.0.1:7410/telephony`. It is intended for the same Ubuntu or Debian host as Asterisk, with systemd. Other operating systems can show that administration is unsupported; remote SSH management is not provided.

## What the page shows

- Whether the host is supported, whether Asterisk is installed, its version, the systemd service state, and whether the privileged helper is available.
- Loaded Asterisk modules and read-only host diagnostics: network addresses, UFW status, PJSIP transport/TLS information, and the latest Asterisk journal entries. Unavailable host tools are reported as unavailable.
- Guided configuration areas for PJSIP, dialplan extensions, queues, voicemail, module loading, and codecs. PJSIP configuration covers endpoint, transport, authentication, address-of-record, and server URI settings.

The editor handles only its supported fields and bounded values. Dialplan applications are allowlisted. Saving writes managed configuration beneath `/etc/asterisk/madabina-managed/`, adds an include to the relevant main configuration, preserves a `.madabina-backup`, and asks Asterisk to reload. If reload fails, the helper restores the prior files and retries the reload. Existing secrets are preserved when a saved section leaves its password blank. New PJSIP auth entries and voicemail mailboxes need a password.

Start, stop, and restart are separate service actions and require confirmation in the page. Network, firewall, TLS, and logs are observational only; the console does not edit them.

## Install and enable the helper

Install the matching Debian package from the official release or APT repository. The package installs `madabina-telephony-helper` and `madabina-telephony-helper.service`. Asterisk must be installed and provide its system group. Then grant the account running `madabina web` access and enable the helper:

```sh
sudo usermod -aG asterisk "$USER"
sudo systemctl enable --now madabina-telephony-helper.service
```

Sign out and back in after changing group membership, then start `madabina web` and open the page. Check the helper with `systemctl status madabina-telephony-helper.service`; check Asterisk with `systemctl status asterisk.service`. The page remains read-only when the helper is absent or the CLI account cannot access its socket.

## Security boundary

The helper runs as root because it writes Asterisk configuration and controls the Asterisk service. Its Unix socket is mode `0660`, owned by `root:asterisk`. The helper accepts only fixed status, read-config, apply-config, and start/stop/restart operations; clients cannot supply shell commands, executable paths, or arbitrary file paths. Configuration files are written atomically with restricted permissions. The telephony HTTP API is enabled only when the web server binds to a loopback address, even if other console pages use the explicit LAN bind option.

The `asterisk` group membership grants access to telephony administration on that host. Add only trusted operator accounts. Review the changes before applying them and use the `.madabina-backup` files for manual recovery if needed. This feature has not been declared runtime-verified on a host unless that specific Asterisk/systemd/helper combination was exercised.
