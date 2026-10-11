# Binaires Madabina CLI

Madabina CLI est un logiciel propriétaire distribué par Madabina LLC. Ce dépôt est destiné à la distribution publique des versions officielles sous forme de binaires. Il ne contient pas le code source du CLI.

## État des releases

Madabina CLI `v0.1.0` est la première release officielle des binaires. Téléchargez les archives versionnées, les paquets Debian et le manifeste SHA-256 depuis la [page des releases Madabina CLI](https://github.com/madabina-com/madabina-cli/releases). Choisissez le paquet correspondant à votre système et à l’architecture du processeur, puis vérifiez son checksum avant l’installation. Un checksum téléchargé depuis la même release confirme l’intégrité du transfert, mais n’authentifie pas l’éditeur de manière indépendante.

L’installateur Linux n’a pas été validé sur un véritable environnement Linux pour cette release. Consultez les notes de release avant l’installation. N’installez pas et ne redistribuez pas les fichiers marqués `SNAPSHOT` : ce sont des candidats locaux de validation, pas des versions officielles.

## Installation Windows

Les installateurs utilisateur pour Windows x64 et ARM64 sont en cours d’ajout à la release v0.1.0. Dès que les fichiers `*_setup.exe` seront visibles sur la page de release, utilisez PowerShell pour télécharger l’installateur et le manifeste de checksums, vérifier SHA-256, puis le lancer :

```powershell
$version = '0.1.0'; $arch = 'amd64' # utiliser 'arm64' pour Windows ARM64
$name = "madabina_${version}_windows_${arch}_setup.exe"
$base = "https://github.com/madabina-com/madabina-cli/releases/download/v$version"
$checksums = Join-Path $env:TEMP 'madabina-checksums.txt'; $installer = Join-Path $env:TEMP $name
curl.exe --fail --location --silent --show-error "$base/checksums.txt" --output $checksums; if ($LASTEXITCODE -ne 0) { throw 'Échec du téléchargement du checksum' }
curl.exe --fail --location --silent --show-error "$base/$name" --output $installer; if ($LASTEXITCODE -ne 0) { throw 'Échec du téléchargement de l’installateur' }
$expected = ([regex]::Match((Get-Content -Raw $checksums), "(?m)^([0-9a-fA-F]{64})\s+\*?$([regex]::Escape($name))\s*$")).Groups[1].Value
if (-not $expected -or (Get-FileHash $installer -Algorithm SHA256).Hash -ne $expected) { throw 'Échec de la vérification SHA-256' }
Start-Process $installer -Wait
```

L’installateur utilise le dossier local des programmes de l’utilisateur, met à jour son `PATH`, conserve la licence et les mentions des composants tiers, et ne requiert pas de droits administrateur. Le workflow prépare le manifeste WinGet communautaire, mais celui-ci n’a pas encore été soumis ni fusionné; `winget install Madabina.MadabinaCLI` n’est donc pas encore disponible. Un checksum servi avec la même release HTTPS vérifie l’intégrité du transfert, mais n’authentifie pas l’éditeur de manière indépendante.

## Licence et mentions

La licence de Madabina CLI autorise l’utilisation et la redistribution gratuite des binaires originaux non modifiés, sous réserve de la licence incluse. Elle n’autorise pas la redistribution du code source ni des binaires modifiés. La revente exige une autorisation écrite distincte de Madabina LLC. Consultez la [licence](LICENSE) et les [mentions des composants tiers](THIRD_PARTY_NOTICES.md).

Les composants tiers restent soumis à leurs propres licences, disponibles dans `third_party_licenses/` lorsqu’elles s’appliquent.

## Cibles prévues

La version `v0.1.0` inclut Windows, Linux et macOS en AMD64 et ARM64, ainsi que des paquets Debian en AMD64 et ARM64. Android/Termux ARM64 est prévu dans une prochaine release.

## Dépôt APT Debian / Ubuntu

La publication du dépôt APT est en cours de configuration. Après son premier déploiement réussi, installez le CLI ainsi :

```sh
curl -fsSL https://madabina-com.github.io/madabina-cli/madabina-archive-keyring.gpg | sudo tee /usr/share/keyrings/madabina-cli-archive-keyring.gpg >/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/madabina-cli-archive-keyring.gpg] https://madabina-com.github.io/madabina-cli stable main" | sudo tee /etc/apt/sources.list.d/madabina-cli.list >/dev/null
sudo apt update
sudo apt install madabina
```

Le dépôt couvrira Debian/Ubuntu AMD64 et ARM64. Tant que son premier déploiement n’a pas réussi, installez plutôt le paquet `.deb` depuis la [page des releases](https://github.com/madabina-com/madabina-cli/releases). Consultez [`apt/SETUP.md`](apt/SETUP.md) pour la configuration initiale côté éditeur.
