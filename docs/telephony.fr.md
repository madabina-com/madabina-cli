# Console téléphonique Asterisk

Madabina CLI v0.2.2 ajoute l’accès sécurisé par proxy inverse à la page d’administration Asterisk `/telephony`. Le CLI et Asterisk doivent toujours fonctionner sur le même hôte Ubuntu ou Debian avec systemd; un proxy HTTPS peut exposer la page aux opérateurs distants. Sur les autres systèmes, l’administration est indisponible. La gestion distante d’un autre hôte par SSH n’est pas prise en charge.

## Informations et réglages

La page affiche la compatibilité du système, la présence et la version d’Asterisk, l’état de son service systemd et la disponibilité du helper privilégié. Elle présente aussi les modules chargés et, en lecture seule, les adresses réseau, l’état d’UFW, les informations de transport/TLS PJSIP et les dernières lignes du journal Asterisk. Les outils hôte absents sont signalés comme indisponibles.

Les formulaires guidés couvrent PJSIP, les extensions du dialplan, les files d’attente, la messagerie vocale, le chargement des modules et les codecs. Ils n’acceptent que des champs et valeurs limités; les applications du dialplan sont autorisées par liste. Les fichiers gérés sont enregistrés dans `/etc/asterisk/madabina-managed/`, inclus dans la configuration principale et sauvegardés en `.madabina-backup`. Après l’écriture atomique, Asterisk recharge sa configuration. Si le rechargement échoue, le helper restaure les fichiers précédents et tente un nouveau rechargement. Les secrets existants sont conservés si le mot de passe d’une section reste vide. Les nouveaux comptes d’authentification PJSIP et les nouvelles boîtes vocales nécessitent un mot de passe.

Les actions démarrer, arrêter et redémarrer nécessitent une confirmation dans la page. Le réseau, le pare-feu, TLS et les journaux restent en consultation seule.

## Installer et activer le helper

Installez le paquet Debian correspondant depuis une release officielle ou le dépôt APT. Il installe `madabina-telephony-helper` et `madabina-telephony-helper.service`. Asterisk doit être installé et fournir le groupe système `asterisk`. Autorisez ensuite le compte qui lance `madabina web`, puis activez le helper :

```sh
sudo usermod -aG asterisk "$USER"
sudo systemctl enable --now madabina-telephony-helper.service
```

Fermez puis rouvrez la session après le changement de groupe. Lancez `madabina web` et ouvrez la page. Vérifiez le helper avec `systemctl status madabina-telephony-helper.service` et Asterisk avec `systemctl status asterisk.service`. Sans helper ou accès à sa socket, la page reste en lecture seule.

## Accès distant sécurisé par HTTPS

Pour accéder à la console depuis un autre appareil, laissez le CLI lié à loopback et placez devant lui un proxy inverse HTTPS qui authentifie les opérateurs. N’exposez pas directement le port 7410 au LAN ou à Internet. Déclarez l’origine HTTPS publique exacte :

```sh
madabina web --trusted-origin https://pbx.example.com
```

Exemple de site Caddy (générez un hash avec `caddy hash-password` et remplacez la valeur fictive) :

```caddyfile
pbx.example.com {
    basic_auth {
        operator REMPLACER_PAR_LE_HASH_CADDY
    }
    reverse_proxy 127.0.0.1:7410
}
```

Limitez le pare-feu pour que le port 7410 reste accessible uniquement sur la machine; les clients distants ne doivent atteindre que le port HTTPS du proxy. Le proxy doit conserver l’en-tête `Host` du navigateur. `--trusted-origin` accepte une seule origine HTTPS exacte et n’active pas la téléphonie lorsque le CLI écoute sur le LAN. Protégez toutes les routes par l’authentification du proxy, car il expose toute la console, et choisissez un mot de passe opérateur unique et robuste. Le tunnel SSH reste une option si aucun proxy HTTPS n’est disponible.

## Sécurité et limites

Le serveur web doit écouter sur loopback pour activer API téléphonie; les demandes à distance ne sont acceptées que depuis une origine HTTPS unique déclarée avec --trusted-origin. Une écoute LAN directe ne donne jamais accès à la téléphonie.

L’appartenance au groupe `asterisk` donne accès à l’administration téléphonique de cet hôte : n’ajoutez que des opérateurs de confiance. Le proxy HTTPS doit authentifier les utilisateurs distants et garder le port backend privé. Vérifiez les changements avant application. Les fichiers `.madabina-backup` servent à une restauration manuelle si nécessaire. La compatibilité annoncée ne signifie pas qu’une combinaison particulière Asterisk/systemd/helper a été testée en production.
