$ErrorActionPreference = 'Stop'

$RepoOwner = 'Caffeine-Ops'
$RepoName = 'fusion-code-install'
$Version = if ($env:FUSION_CODE_VERSION) { $env:FUSION_CODE_VERSION } else { 'latest' }
$InstallDir = Join-Path $env:LOCALAPPDATA 'FusionCode\bin'
$BinaryName = 'fusion-code.exe'

function Write-Info($msg) {
  Write-Host "[*] $msg" -ForegroundColor Cyan
}

function Write-Ok($msg) {
  Write-Host "[+] $msg" -ForegroundColor Green
}

function Get-PlatformAssetName {
  if (-not [Environment]::Is64BitOperatingSystem) {
    throw 'Unsupported Windows architecture: only x64 is currently supported.'
  }

  switch ($env:PROCESSOR_ARCHITECTURE) {
    'AMD64' { return 'fusion-code-win32-x64.exe' }
    default { return 'fusion-code-win32-x64.exe' }
  }
}

function Get-DownloadUrl([string]$AssetName) {
  if ($Version -eq 'latest') {
    return "https://github.com/$RepoOwner/$RepoName/releases/latest/download/$AssetName"
  }
  return "https://github.com/$RepoOwner/$RepoName/releases/download/$Version/$AssetName"
}

function Add-ToUserPath([string]$Dir) {
  $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
  $paths = @()
  if ($userPath) {
    $paths = $userPath.Split(';', [System.StringSplitOptions]::RemoveEmptyEntries)
  }
  if ($paths -notcontains $Dir) {
    $newPath = if ($userPath) { "$userPath;$Dir" } else { $Dir }
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Info "$Dir was added to your user PATH. Restart your terminal to pick it up."
  }
}

$assetName = Get-PlatformAssetName
$downloadUrl = Get-DownloadUrl $assetName

Write-Info "Starting Fusion Code installation..."
Write-Info "Version: $Version"
Write-Info "Asset: $assetName"

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
$tempFile = Join-Path $InstallDir 'fusion-code.tmp.exe'

try {
  Write-Info "Downloading $assetName from GitHub Releases..."
  Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile
  Move-Item -Force $tempFile (Join-Path $InstallDir $BinaryName)
} catch {
  if (Test-Path $tempFile) {
    Remove-Item -Force $tempFile
  }
  throw "Download failed. Make sure the public release asset exists at: $downloadUrl"
}

Add-ToUserPath $InstallDir
Write-Ok "Binary installed: $(Join-Path $InstallDir $BinaryName)"
Write-Host ''
Write-Host '  Installation complete!' -ForegroundColor Green
Write-Host ''
Write-Host '  Run it:'
Write-Host '    fusion-code                          # interactive REPL' -ForegroundColor Cyan
Write-Host '    fusion-code -p "your prompt"          # one-shot mode' -ForegroundColor Cyan
Write-Host ''
Write-Host '  Set your API key:'
Write-Host '    $env:ANTHROPIC_API_KEY="sk-ant-..."' -ForegroundColor Cyan
Write-Host ''
Write-Host '  Or log in with Claude.ai:'
Write-Host '    fusion-code /login' -ForegroundColor Cyan
Write-Host ''
Write-Host "  Install dir: $InstallDir" -ForegroundColor DarkGray
Write-Host "  Binary:      $(Join-Path $InstallDir $BinaryName)" -ForegroundColor DarkGray
Write-Host "  Asset:       $assetName" -ForegroundColor DarkGray
