# Binaires Madabina CLI

Madabina CLI est un logiciel propriétaire distribué par Madabina LLC. Ce dépôt est destiné à la distribution publique des versions officielles sous forme de binaires. Il ne contient pas le code source du CLI.

## État des releases

Aucune release publique versionnée n’est disponible pour le moment. N’installez pas et ne redistribuez pas les fichiers marqués `SNAPSHOT` : ce sont des candidats locaux de validation, pas des versions officielles.

Lorsqu’une version officielle sera publiée, ses archives, paquets Debian et manifeste SHA-256 seront joints à la release. Choisissez le paquet correspondant à votre système et à l’architecture du processeur, puis vérifiez son checksum avant l’installation. Un checksum téléchargé depuis la même release confirme l’intégrité du transfert, mais n’authentifie pas l’éditeur de manière indépendante.

## Licence et mentions

La licence de Madabina CLI autorise l’utilisation et la redistribution gratuite des binaires originaux non modifiés, sous réserve de la licence incluse. Elle n’autorise pas la redistribution du code source ni des binaires modifiés. La revente exige une autorisation écrite distincte de Madabina LLC. Consultez la [licence](LICENSE) et les [mentions des composants tiers](THIRD_PARTY_NOTICES.md).

Les composants tiers restent soumis à leurs propres licences, disponibles dans `third_party_licenses/` lorsqu’elles s’appliquent.

## Cibles prévues

Les cibles prévues sont Windows, Linux et macOS en AMD64 et ARM64, des paquets Debian pour les architectures Linux prises en charge, ainsi qu’une archive séparée Android/Termux ARM64. Une cible n’est prise en charge que si elle figure dans une release publiée.
