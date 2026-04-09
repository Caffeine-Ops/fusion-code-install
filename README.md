# Fusion Code Install

Public install entrypoint for Fusion Code.

## Quick Install

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/Caffeine-Ops/fusion-code-install/main/install.sh | bash
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/Caffeine-Ops/fusion-code-install/main/install.ps1 | iex
```

## Install a specific version

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/Caffeine-Ops/fusion-code-install/main/install.sh | bash -s -- v2.1.89
```

### Windows (PowerShell)

```powershell
$env:FUSION_CODE_VERSION='v2.1.89'; irm https://raw.githubusercontent.com/Caffeine-Ops/fusion-code-install/main/install.ps1 | iex
```

## What this does

This installer downloads the public GitHub Release binary for your platform from:

- `Caffeine-Ops/fusion-code-install`

and installs it as:

- macOS / Linux: `~/.local/bin/fusion-code`
- Windows: `%USERPROFILE%\\AppData\\Local\\FusionCode\\bin\\fusion-code.exe`

## Release asset names expected

- `fusion-code-darwin-arm64`
- `fusion-code-darwin-x64`
- `fusion-code-linux-x64`
- `fusion-code-linux-arm64`
- `fusion-code-win32-x64.exe`

## Important

The private source repository can remain private. End users only need access to this public installer repository and its public GitHub Releases.
