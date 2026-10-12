# Asterisk telephony console

Madabina CLI v0.2.2 adds secure reverse-proxy access to the Asterisk administration page at `/telephony`. The CLI and Asterisk still run on the same Ubuntu or Debian host with systemd; a TLS reverse proxy can expose the page to remote operators. Other operating systems can show that administration is unsupported; remote SSH management is not provided.

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

## Secure remote access through HTTPS

For access from another device, keep the CLI bound to loopback and put an HTTPS reverse proxy with operator authentication in front of it. Do not expose port 7410 directly to the LAN or Internet. Configure the exact public HTTPS origin:

```sh
madabina web --trusted-origin https://pbx.example.com
```

Example Caddy site (generate a password hash with `caddy hash-password` and replace the placeholder):

```caddyfile
pbx.example.com {
    basic_auth {
        operator REPLACE_WITH_CADDY_PASSWORD_HASH
    }
    reverse_proxy 127.0.0.1:7410
}
```

Keep firewall access to port 7410 restricted to the local machine; allow remote clients to reach only the proxy's HTTPS listener. The proxy must preserve the browser's `Host` header. `--trusted-origin` accepts one exact HTTPS origin and does not enable telephony on a LAN-bound CLI. Protect every route with the proxy's authentication, since the proxy exposes the full console, and use a strong unique operator password. SSH port forwarding remains an option when no HTTPS proxy is available.

## Security boundary

The web server must bind to loopback for telephony APIs; remote access is enabled only for the exact HTTPS origin configured with --trusted-origin. Direct LAN binding never enables telephony.

The `asterisk` group membership grants access to telephony administration on that host. Add only trusted operator accounts. The HTTPS proxy must authenticate remote users and keep the backend port private. Review changes before applying them and use the `.madabina-backup` files for manual recovery if needed. This feature has not been declared runtime-verified on a host unless that specific Asterisk/systemd/helper combination was exercised.
