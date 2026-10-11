#!/usr/bin/env bash
set -euo pipefail

repository_url="https://packages.madabina.com"
expected_fingerprint="A6561F99594315269612AD984B8D3B0CB32D4F67"
keyring_path="/usr/share/keyrings/madabina-cli-archive-keyring.gpg"
source_path="/etc/apt/sources.list.d/madabina-cli.list"

fail() {
  printf 'Madabina CLI installer: %s\n' "$1" >&2
  exit 1
}

as_root() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

command -v apt-get >/dev/null 2>&1 || fail 'This installer supports Debian and Ubuntu systems with apt-get.'
command -v dpkg >/dev/null 2>&1 || fail 'dpkg is required.'
command -v curl >/dev/null 2>&1 || fail 'curl is required.'
if [[ "$(id -u)" -ne 0 ]]; then
  command -v sudo >/dev/null 2>&1 || fail 'sudo is required to add the APT key and source.'
  sudo -v
fi

architecture="$(dpkg --print-architecture)"
case "$architecture" in
  amd64|arm64) ;;
  *) fail "Unsupported Debian architecture: $architecture (supported: amd64, arm64)." ;;
esac

if ! command -v gpg >/dev/null 2>&1; then
  as_root apt-get update
  as_root apt-get install --yes gnupg
fi

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT HUP INT TERM
key_path="$workdir/madabina-archive-keyring.gpg"

curl --fail --location --silent --show-error --proto '=https' --tlsv1.2 \
  "$repository_url/madabina-archive-keyring.gpg" --output "$key_path" \
  || fail 'Could not download the repository signing key over HTTPS.'

fingerprint="$(gpg --batch --show-keys --with-colons "$key_path" | awk -F: '$1 == "fpr" { print toupper($10); exit }')"
[[ "$fingerprint" == "$expected_fingerprint" ]] \
  || fail "Repository key fingerprint mismatch. Expected $expected_fingerprint, received ${fingerprint:-none}."

as_root install -D -m 0644 "$key_path" "$keyring_path"
printf 'deb [arch=%s signed-by=%s] %s stable main\n' \
  "$architecture" "$keyring_path" "$repository_url" \
  | as_root tee "$source_path" >/dev/null

as_root apt-get update
as_root apt-get install --yes madabina
printf 'Madabina CLI installed. Run: madabina --version\n'
