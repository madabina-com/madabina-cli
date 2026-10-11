# Binaires Madabina CLI

Madabina CLI est un logiciel propriétaire distribué par Madabina LLC. Ce dépôt est destiné à la distribution publique des versions officielles sous forme de binaires. Il ne contient pas le code source du CLI.

## État des releases

Madabina CLI `v0.1.0` était la première release officielle des binaires; `v0.1.1` est la version la plus récente. Téléchargez les archives versionnées, les paquets Debian et le manifeste SHA-256 depuis la [page des releases Madabina CLI](https://github.com/madabina-com/madabina-cli/releases). Choisissez le paquet correspondant à votre système et à l’architecture du processeur, puis vérifiez son checksum avant l’installation. Un checksum téléchargé depuis la même release confirme l’intégrité du transfert, mais n’authentifie pas l’éditeur de manière indépendante.

Les binaires Linux et macOS `v0.1.1` ont été compilés pour ces plateformes, mais n’y ont pas été exécutés. Consultez les notes de release avant l’installation. N’installez pas et ne redistribuez pas les fichiers marqués `SNAPSHOT` : ce sont des candidats locaux de validation, pas des versions officielles.

## Installation npm (en préparation)

Le paquet npm `madabina-cli` est en préparation. Après sa première publication, installez Madabina CLI avec `npm install --global madabina-cli`, puis vérifiez avec `madabina --version`. npm sélectionnera un binaire original vérifié pour Windows, Linux ou macOS, en x64 ou ARM64. L’installation npm n’est pas encore disponible. Consultez [`npm/README.md`](npm/README.md) pour la configuration de publication.

## Installation Windows

Les installateurs utilisateur pour Windows x64 et ARM64 sont disponibles sur la [page de release v0.1.1](https://github.com/madabina-com/madabina-cli/releases/tag/v0.1.1).

### Installation en une commande

Ouvrez PowerShell et collez cette commande. Elle télécharge et vérifie le script d’installation, sélectionne la dernière release stable et l’architecture Windows, vérifie le setup avec le checksum de la release, puis lance l’installation utilisateur :

```powershell
$d=Join-Path $env:TEMP ('madabina-'+[guid]::NewGuid().ToString('N'));New-Item -ItemType Directory -Path $d|Out-Null;try{$s=Join-Path $d 'madabina-install-windows.ps1';$m=Join-Path $d 'install-windows.ps1.sha256';curl.exe -fsSL https://packages.madabina.com/install-windows.ps1 -o $s;if($LASTEXITCODE -ne 0){throw 'Échec du téléchargement du script'};curl.exe -fsSL https://packages.madabina.com/install-windows.ps1.sha256 -o $m;if($LASTEXITCODE -ne 0){throw 'Échec du téléchargement du checksum'};$e=[regex]::Match((Get-Content -Raw $m),'(?m)^([0-9a-fA-F]{64})\s+madabina-install-windows\.ps1\s*$').Groups[1].Value;$a=(Get-FileHash -LiteralPath $s -Algorithm SHA256).Hash;if(-not $e -or $a -ne $e){throw 'Échec de la vérification SHA-256 du script'};powershell.exe -NoProfile -ExecutionPolicy Bypass -File $s;if($LASTEXITCODE -ne 0){throw "L’installation a échoué, code $LASTEXITCODE"}}finally{Remove-Item -LiteralPath $d -Recurse -Force -ErrorAction SilentlyContinue}
```

Le manifeste SHA-256 est hébergé sur le même domaine HTTPS : il détecte les erreurs de transfert, mais n’authentifie pas indépendamment l’éditeur du script.

### Téléchargement et vérification manuels

Pour télécharger le setup vous-même, choisissez `amd64` pour Windows x64 ou `arm64` pour Windows ARM64, vérifiez son hash dans `checksums.txt`, puis lancez-le :

```powershell
$version = '0.1.1'; $arch = 'amd64' # utiliser 'arm64' pour Windows ARM64
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
