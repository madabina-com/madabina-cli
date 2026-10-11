# Binaires Madabina CLI

Madabina CLI est un logiciel propriétaire distribué par Madabina LLC. Ce dépôt est destiné à la distribution publique des versions officielles sous forme de binaires. Il ne contient pas le code source du CLI.

## État des releases

Madabina CLI `v0.1.0` est la première release officielle des binaires. Téléchargez les archives versionnées, les paquets Debian et le manifeste SHA-256 depuis la [page des releases Madabina CLI](https://github.com/madabina-com/madabina-cli/releases). Choisissez le paquet correspondant à votre système et à l’architecture du processeur, puis vérifiez son checksum avant l’installation. Un checksum téléchargé depuis la même release confirme l’intégrité du transfert, mais n’authentifie pas l’éditeur de manière indépendante.

L’installateur Linux n’a pas été validé sur un véritable environnement Linux pour cette release. Consultez les notes de release avant l’installation. N’installez pas et ne redistribuez pas les fichiers marqués `SNAPSHOT` : ce sont des candidats locaux de validation, pas des versions officielles.

## Installation Windows

Les installateurs utilisateur pour Windows x64 et ARM64 sont disponibles sur la [page de release v0.1.0](https://github.com/madabina-com/madabina-cli/releases/tag/v0.1.0). Utilisez PowerShell pour télécharger l’installateur et le manifeste de checksums, vérifier SHA-256, puis le lancer :

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

#### Installation en une commande

Sur Debian ou Ubuntu AMD64/ARM64, cette commande télécharge l’installateur et son manifeste SHA-256, vérifie le fichier, puis configure la source APT signée et installe Madabina CLI :

```sh
d="$(mktemp -d)" && trap 'rm -rf "$d"' EXIT && curl -fsSL https://packages.madabina.com/install.sh -o "$d/madabina-install.sh" && curl -fsSL https://packages.madabina.com/install.sh.sha256 -o "$d/install.sh.sha256" && (cd "$d" && sha256sum -c install.sh.sha256) && bash "$d/madabina-install.sh"
```

L’installateur vérifie que la clé APT téléchargée possède l’empreinte épinglée `A6561F99594315269612AD984B8D3B0CB32D4F67` avant d’ajouter le dépôt. Il demande `sudo` lorsque nécessaire. Le SHA-256 vient du même domaine HTTPS : il détecte les erreurs de transfert, mais n’authentifie pas indépendamment l’éditeur du script.

#### Configuration APT manuelle

Si vous préférez configurer APT vous-même :

```sh
curl -fsSL https://packages.madabina.com/madabina-archive-keyring.gpg -o /tmp/madabina-archive-keyring.gpg
fingerprint="$(gpg --batch --show-keys --with-colons /tmp/madabina-archive-keyring.gpg | awk -F: '$1 == "fpr" { print toupper($10); exit }')"
test "$fingerprint" = 'A6561F99594315269612AD984B8D3B0CB32D4F67' || { echo 'Empreinte de clé APT incorrecte' >&2; exit 1; }
sudo install -D -m 0644 /tmp/madabina-archive-keyring.gpg /usr/share/keyrings/madabina-cli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/madabina-cli-archive-keyring.gpg] https://packages.madabina.com stable main" | sudo tee /etc/apt/sources.list.d/madabina-cli.list >/dev/null
sudo apt update
sudo apt install madabina
```

Le dépôt couvre Debian/Ubuntu AMD64 et ARM64. Consultez [`apt/SETUP.md`](apt/SETUP.md) pour la configuration de publication.
