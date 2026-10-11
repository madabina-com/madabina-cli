# Binaires Madabina CLI

Madabina CLI est un logiciel propriétaire distribué par Madabina LLC. Ce dépôt est destiné à la distribution publique des versions officielles sous forme de binaires. Il ne contient pas le code source du CLI.

## État des releases

Madabina CLI `v0.1.0` est la première release officielle des binaires. Téléchargez les archives versionnées, les paquets Debian et le manifeste SHA-256 depuis la [page des releases Madabina CLI](https://github.com/madabina-com/madabina-cli/releases). Choisissez le paquet correspondant à votre système et à l’architecture du processeur, puis vérifiez son checksum avant l’installation. Un checksum téléchargé depuis la même release confirme l’intégrité du transfert, mais n’authentifie pas l’éditeur de manière indépendante.

L’installateur Linux n’a pas été validé sur un véritable environnement Linux pour cette release. Consultez les notes de release avant l’installation. N’installez pas et ne redistribuez pas les fichiers marqués `SNAPSHOT` : ce sont des candidats locaux de validation, pas des versions officielles.

## Licence et mentions

La licence de Madabina CLI autorise l’utilisation et la redistribution gratuite des binaires originaux non modifiés, sous réserve de la licence incluse. Elle n’autorise pas la redistribution du code source ni des binaires modifiés. La revente exige une autorisation écrite distincte de Madabina LLC. Consultez la [licence](LICENSE) et les [mentions des composants tiers](THIRD_PARTY_NOTICES.md).

Les composants tiers restent soumis à leurs propres licences, disponibles dans `third_party_licenses/` lorsqu’elles s’appliquent.

## Cibles prévues

La version `v0.1.0` inclut Windows, Linux et macOS en AMD64 et ARM64, ainsi que des paquets Debian en AMD64 et ARM64. Android/Termux ARM64 est prévu dans une prochaine release.
