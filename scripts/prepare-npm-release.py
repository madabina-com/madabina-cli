#!/usr/bin/env python3
"""Stage npm binary or launcher packages from official release archives."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import tarfile
import zipfile
from pathlib import Path, PurePosixPath


ROOT = Path(__file__).resolve().parents[1]
NPM_ROOT = ROOT / "npm"
VERSION_RE = re.compile(r"^[0-9]+\.[0-9]+\.[0-9]+(?:-[0-9A-Za-z.-]+)?$")
TARGETS = {
    "linux-x64": ("linux", "x64", "amd64", "tar.gz", "madabina"),
    "linux-arm64": ("linux", "arm64", "arm64", "tar.gz", "madabina"),
    "darwin-x64": ("darwin", "x64", "amd64", "tar.gz", "madabina"),
    "darwin-arm64": ("darwin", "arm64", "arm64", "tar.gz", "madabina"),
    "win32-x64": ("win32", "x64", "amd64", "zip", "madabina.exe"),
    "win32-arm64": ("win32", "arm64", "arm64", "zip", "madabina.exe"),
}
LAUNCHER_TARGETS = tuple(target for target in TARGETS if target != "win32-x64")


def checked_version(value: str) -> str:
    if not VERSION_RE.fullmatch(value):
        raise ValueError("version must be a release version such as 0.1.1")
    return value


def verify_checksum(asset: Path, manifest: Path) -> None:
    matches = []
    for line in manifest.read_text(encoding="utf-8").splitlines():
        match = re.fullmatch(r"([0-9a-fA-F]{64})\s+\*?(.+?)\s*", line)
        if match and match.group(2) == asset.name:
            matches.append(match.group(1).lower())
    if len(matches) != 1:
        raise ValueError(f"checksums.txt must contain exactly one entry for {asset.name}")
    digest = hashlib.sha256(asset.read_bytes()).hexdigest()
    if digest != matches[0]:
        raise ValueError(f"SHA-256 mismatch for {asset.name}")


def safe_archive_path(name: str) -> PurePosixPath:
    if "\\" in name:
        raise ValueError(f"unsafe archive member path: {name!r}")
    path = PurePosixPath(name)
    if path.is_absolute() or ".." in path.parts:
        raise ValueError(f"unsafe archive member path: {name!r}")
    return path


def read_members(asset: Path) -> list[tuple[str, bytes]]:
    members: list[tuple[str, bytes]] = []
    if asset.name.endswith(".tar.gz"):
        with tarfile.open(asset, "r:gz") as archive:
            for entry in archive.getmembers():
                safe_archive_path(entry.name)
                if entry.isfile():
                    stream = archive.extractfile(entry)
                    if stream is None:
                        raise ValueError(f"cannot read archive member {entry.name!r}")
                    members.append((entry.name, stream.read()))
    elif asset.suffix == ".zip":
        with zipfile.ZipFile(asset) as archive:
            for entry in archive.infolist():
                safe_archive_path(entry.filename)
                mode = entry.external_attr >> 16
                if entry.is_dir() or (mode and (mode & 0o170000) not in (0, 0o100000)):
                    continue
                members.append((entry.filename, archive.read(entry)))
    else:
        raise ValueError("release asset must be .tar.gz or .zip")
    return members


def find_root_file(members: list[tuple[str, bytes]], basename: str) -> tuple[str, bytes]:
    found = [(name, data) for name, data in members if name == basename]
    if len(found) != 1:
        raise ValueError(f"expected exactly one {basename} in the release archive; found {len(found)}")
    return found[0]


def stage_platform(version: str, target: str, asset: Path, manifest: Path, output: Path) -> Path:
    version = checked_version(version)
    if target not in TARGETS:
        raise ValueError(f"unsupported target {target!r}")
    os_name, cpu, goarch, extension, binary_name = TARGETS[target]
    expected_asset = f"madabina_{version}_{'windows' if os_name == 'win32' else 'darwin' if os_name == 'darwin' else 'linux'}_{goarch}.{extension}"
    if asset.name != expected_asset:
        raise ValueError(f"expected release asset {expected_asset}, received {asset.name}")
    verify_checksum(asset, manifest)
    members = read_members(asset)
    _, binary = find_root_file(members, binary_name)
    _, license = find_root_file(members, "LICENSE")

    package_name = f"madabina-cli-{target}"
    package_dir = output / package_name
    package_bin = package_dir / "bin"
    package_bin.mkdir(parents=True, exist_ok=False)
    (package_bin / binary_name).write_bytes(binary)
    (package_dir / "LICENSE").write_bytes(license)

    for member_name, content in members:
        parts = safe_archive_path(member_name).parts
        if "third_party_licenses" not in parts:
            continue
        marker = parts.index("third_party_licenses")
        relative = Path(*parts[marker + 1 :])
        if relative.parts:
            destination = package_dir / "third_party_licenses" / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(content)

    third_party_dir = package_dir / "third_party_licenses"
    if not third_party_dir.is_dir() or not any(third_party_dir.rglob("*")):
        raise ValueError("release archive is missing its third-party license texts")
    if os_name != "win32":
        (package_bin / binary_name).chmod(0o755)

    package = {
        "name": package_name,
        "version": version,
        "description": f"Original Madabina CLI binary for {target}",
        "license": "SEE LICENSE IN LICENSE",
        "repository": "https://github.com/madabina-com/madabina-cli",
        "homepage": "https://github.com/madabina-com/madabina-cli/releases",
        "os": [os_name],
        "cpu": [cpu],
        "files": ["bin/", "LICENSE", "third_party_licenses/"],
    }
    (package_dir / "package.json").write_text(
        json.dumps(package, indent=2) + "\n", encoding="utf-8"
    )
    return package_dir


def stage_launcher(version: str, output: Path) -> Path:
    version = checked_version(version)
    package_dir = output / "madabina-cli"
    bin_dir = package_dir / "bin"
    bin_dir.mkdir(parents=True, exist_ok=False)
    shutil.copyfile(NPM_ROOT / "bin" / "madabina.js", bin_dir / "madabina.js")
    shutil.copyfile(ROOT / "LICENSE", package_dir / "LICENSE")
    notices = ROOT / "THIRD_PARTY_NOTICES.md"
    if notices.exists():
        shutil.copyfile(notices, package_dir / notices.name)
    shutil.copyfile(NPM_ROOT / "README.md", package_dir / "README.md")
    package = {
        "name": "madabina-cli",
        "version": version,
        "description": "Madabina CLI launcher for Windows, Linux, and macOS",
        "license": "SEE LICENSE IN LICENSE",
        "repository": "https://github.com/madabina-com/madabina-cli",
        "homepage": "https://github.com/madabina-com/madabina-cli/releases",
        "engines": {"node": ">=18"},
        "bin": {"madabina": "bin/madabina.js"},
        "files": ["bin/madabina.js", "LICENSE", "THIRD_PARTY_NOTICES.md", "README.md"],
        "optionalDependencies": {
            f"madabina-cli-{target}": version for target in LAUNCHER_TARGETS
        },
    }
    (package_dir / "package.json").write_text(
        json.dumps(package, indent=2) + "\n", encoding="utf-8"
    )
    return package_dir


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)
    platform_parser = subparsers.add_parser("platform")
    platform_parser.add_argument("--version", required=True)
    platform_parser.add_argument("--target", required=True)
    platform_parser.add_argument("--asset", type=Path, required=True)
    platform_parser.add_argument("--checksums", type=Path, required=True)
    platform_parser.add_argument("--output", type=Path, required=True)
    launcher_parser = subparsers.add_parser("launcher")
    launcher_parser.add_argument("--version", required=True)
    launcher_parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    if args.command == "platform":
        package_dir = stage_platform(
            args.version, args.target, args.asset, args.checksums, args.output
        )
    else:
        package_dir = stage_launcher(args.version, args.output)
    print(package_dir)


if __name__ == "__main__":
    main()
