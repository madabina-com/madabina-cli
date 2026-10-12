# Console téléphonique Asterisk

Madabina CLI v0.2.0 ajoute une page d’administration locale à `http://127.0.0.1:7410/telephony`. Elle cible le même hôte Ubuntu ou Debian qu’Asterisk, avec systemd. Sur les autres systèmes, l’administration est indiquée comme indisponible. La gestion distante par SSH n’est pas prise en charge.

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

## Sécurité et limites

Le helper tourne en root pour modifier la configuration Asterisk et piloter son service. Sa socket Unix est en mode `0660` et appartient à `root:asterisk`. Il n’accepte qu’un ensemble fixe d’opérations de statut, lecture, application et service; aucune commande shell, aucun chemin exécutable ni chemin de fichier libre ne peut être envoyé par le client. Les fichiers sont écrits atomiquement avec des permissions restreintes. L’API téléphonie est activée uniquement si le serveur web écoute sur loopback, même si une option d’écoute LAN est utilisée pour les autres pages.

L’appartenance au groupe `asterisk` donne accès à l’administration téléphonique de cet hôte : n’ajoutez que des opérateurs de confiance. Vérifiez les changements avant application. Les fichiers `.madabina-backup` servent à une restauration manuelle si nécessaire. La compatibilité annoncée ne signifie pas qu’une combinaison particulière Asterisk/systemd/helper a été testée en production.
