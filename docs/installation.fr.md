# Installation des services locaux

La commande `madabina install` cible actuellement Ubuntu/Debian avec `apt` et `systemd`. Elle présente les paquets fixes, le service qu’elle activera et les ports concernés, puis attend une réponse explicite `yes`. Lancez-la dans un terminal avec les droits root ou un compte configuré pour `sudo`.

```sh
madabina install dns
madabina install telephony       # alias : madabina install asterisk
madabina install proxy
madabina help install dns
madabina -h install dns
```

Ces commandes installent les paquets BIND9, Asterisk ou Caddy, puis activent et démarrent leur unité systemd. Elles ne modifient pas UFW. La configuration des zones/vues DNS et l’interface `/dns` ne sont pas incluses dans cet incrément. La commande proxy ne crée pas encore de Caddyfile, d’identifiants opérateur ni d’unité systemd pour Madabina Web ; configurez-les séparément avant d’exposer la console. Gardez le port 7410 sur loopback derrière un proxy HTTPS authentifié.

Le DNS public nécessite aussi une IP publique, l’accès entrant UDP/TCP 53 et une délégation NS chez le registrar. HTTPS avec Caddy nécessite un DNS public et l’accès entrant TCP 80/443. Madabina ne modifie ni le registrar ni le pare-feu.

Les détails sont accessibles avec `madabina -h install <composant>` ou `madabina help install <composant>`.
