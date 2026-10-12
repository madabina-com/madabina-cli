# Local service installation

The `madabina install` command currently targets Ubuntu/Debian hosts using `apt` and `systemd`. It previews fixed package names, the service it will enable, and the relevant ports; it proceeds only after an explicit `yes`. Run it in a terminal with root access or an account configured for `sudo`.

```sh
madabina install dns
madabina install telephony       # alias: madabina install asterisk
madabina install proxy
madabina help install dns
madabina -h install dns
```

These commands install BIND9, Asterisk, or Caddy packages and enable/start the corresponding systemd unit. They do not change UFW. DNS zone/view configuration and the `/dns` web manager are not included in this increment. The proxy command does not yet create a Caddyfile, operator credentials, or the Madabina Web systemd unit; configure those separately before exposing the console. Keep port 7410 bound to loopback and put an authenticated HTTPS proxy in front of it.

Public DNS also requires a public IP, inbound UDP/TCP 53, and registrar NS delegation. Caddy HTTPS requires public DNS and inbound TCP 80/443. Madabina does not change registrar records or firewall rules.

Detailed help is available through both `madabina -h install <component>` and `madabina help install <component>`.
