# Fusion Code Install

Public install entrypoint for Fusion Code.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/Caffeine-Ops/fusion-code-install/main/install.sh | bash
```

## Install a specific version

```bash
curl -fsSL https://raw.githubusercontent.com/Caffeine-Ops/fusion-code-install/main/install.sh | bash -s -- v2.1.87
```

## What this does

This script downloads the public GitHub Release binary for your platform from:

- `Caffeine-Ops/fusion-code`

and installs it as:

- `~/.local/bin/fusion-code`

## Release asset names expected

- `fusion-code-darwin-arm64`
- `fusion-code-darwin-x64`
- `fusion-code-linux-x64`
- `fusion-code-linux-arm64`
