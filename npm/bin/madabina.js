#!/usr/bin/env node
'use strict';

const { spawnSync } = require('node:child_process');
const { existsSync } = require('node:fs');
const path = require('node:path');

const platformPackages = {
  'linux-x64': 'madabina-cli-linux-x64',
  'linux-arm64': 'madabina-cli-linux-arm64',
  'darwin-x64': 'madabina-cli-darwin-x64',
  'darwin-arm64': 'madabina-cli-darwin-arm64',
  'win32-arm64': 'madabina-cli-win32-arm64',
};

const key = `${process.platform}-${process.arch}`;
const packageName = platformPackages[key];

if (!packageName) {
  console.error(`Madabina CLI does not provide an npm binary for ${key}.`);
  console.error('Available npm binaries: Linux and macOS x64/ARM64, and Windows ARM64.');
  process.exit(1);
}

let packageRoot;
try {
  packageRoot = path.dirname(require.resolve(`${packageName}/package.json`));
} catch {
  console.error(`The Madabina CLI binary package for ${key} is not installed.`);
  console.error('Reinstall with: npm install --global madabina-cli');
  process.exit(1);
}

const executable = path.join(
  packageRoot,
  'bin',
  process.platform === 'win32' ? 'madabina.exe' : 'madabina',
);

if (!existsSync(executable)) {
  console.error(`The Madabina CLI binary is missing: ${executable}`);
  process.exit(1);
}

const result = spawnSync(executable, process.argv.slice(2), {
  stdio: 'inherit',
  windowsHide: true,
});

if (result.error) {
  console.error(`Could not start Madabina CLI: ${result.error.message}`);
  process.exit(1);
}

if (result.signal) {
  console.error(`Madabina CLI stopped by signal ${result.signal}.`);
  process.exit(1);
}

process.exit(result.status ?? 1);
