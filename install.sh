#!/usr/bin/env bash
set -euo pipefail

# Fusion Code installer
# Usage: curl -fsSL https://raw.githubusercontent.com/Caffeine-Ops/fusion-code-install/main/install.sh | bash
#        curl -fsSL https://raw.githubusercontent.com/Caffeine-Ops/fusion-code-install/main/install.sh | bash -s -- v2.1.87

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

REPO_OWNER="Caffeine-Ops"
REPO_NAME="fusion-code-install"
VERSION="latest"
PRINT_URL="0"
INSTALL_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fusion-code"
LINK_DIR="$HOME/.local/bin"
BINARY_NAME="fusion-code"

info()  { printf "${CYAN}[*]${RESET} %s\n" "$*"; }
ok()    { printf "${GREEN}[+]${RESET} %s\n" "$*"; }
warn()  { printf "${YELLOW}[!]${RESET} %s\n" "$*"; }
fail()  { printf "${RED}[x]${RESET} %s\n" "$*"; exit 1; }

header() {
  echo ""
  printf "${BOLD}${CYAN}"
  cat << 'ART'
 ______           _                 _____          _
|  ____|         (_)               / ____|        | |
| |__ _   _ ___   _  ___  _ __    | |     ___   __| | ___
|  __| | | / __| | |/ _ \| '_ \   | |    / _ \ / _` |/ _ \
| |  | |_| \__ \ | | (_) | | | |  | |___| (_) | (_| |  __/
|_|   \__,_|___/ |_|\___/|_| |_|   \_____\___/ \__,_|\___|
ART
  printf "${RESET}"
  printf "${DIM}  The Fusion Code build of Claude Code${RESET}\n"
  echo ""
}

parse_args() {
  for arg in "$@"; do
    case "$arg" in
      --print-url)
        PRINT_URL="1"
        ;;
      *)
        VERSION="$arg"
        ;;
    esac
  done
}

check_os() {
  case "$(uname -s)" in
    Darwin) OS="darwin" ;;
    Linux)  OS="linux" ;;
    *)      fail "Unsupported OS: $(uname -s). macOS or Linux required." ;;
  esac
  ok "OS: $(uname -s) $(uname -m)"
}

check_curl() {
  if ! command -v curl &>/dev/null; then
    fail "curl is required but not installed. Please install curl and try again."
  fi
  ok "curl: $(curl --version | head -1)"
}

detect_arch() {
  case "$(uname -m)" in
    x86_64|amd64) ARCH="x64" ;;
    arm64|aarch64) ARCH="arm64" ;;
    *) fail "Unsupported architecture: $(uname -m). Supported: x64, arm64." ;;
  esac
  PLATFORM="${OS}-${ARCH}"
  ASSET_NAME="fusion-code-${PLATFORM}"
  ok "Platform: ${PLATFORM}"
}

build_download_url() {
  if [ "$VERSION" = "latest" ]; then
    DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/latest/download/${ASSET_NAME}"
  else
    DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${VERSION}/${ASSET_NAME}"
  fi
}

download_binary() {
  mkdir -p "$INSTALL_DIR"
  TMP_BINARY="$(mktemp "$INSTALL_DIR/.fusion-code.XXXXXX")"

  info "Downloading ${ASSET_NAME} from GitHub Releases..."
  if ! curl -fL --progress-bar "$DOWNLOAD_URL" -o "$TMP_BINARY"; then
    rm -f "$TMP_BINARY"
    fail "Download failed. Make sure the public release asset exists at: ${DOWNLOAD_URL}"
  fi

  chmod +x "$TMP_BINARY"
  mv "$TMP_BINARY" "$INSTALL_DIR/$BINARY_NAME"
  ok "Binary installed: $INSTALL_DIR/$BINARY_NAME"
}

link_binary() {
  mkdir -p "$LINK_DIR"
  ln -sf "$INSTALL_DIR/$BINARY_NAME" "$LINK_DIR/$BINARY_NAME"
  ok "Symlinked: $LINK_DIR/$BINARY_NAME"

  if ! echo "$PATH" | tr ':' '\n' | grep -qx "$LINK_DIR"; then
    warn "$LINK_DIR is not on your PATH"
    echo ""
    printf "${YELLOW}  Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):${RESET}\n"
    printf "${BOLD}    export PATH=\"$HOME/.local/bin:\$PATH\"${RESET}\n"
    echo ""
  fi
}

main() {
  parse_args "$@"
  header

  check_os
  check_curl
  detect_arch
  build_download_url

  if [ "$PRINT_URL" = "1" ]; then
    printf '%s\n' "$DOWNLOAD_URL"
    exit 0
  fi

  echo ""
  info "Starting installation..."
  info "Version: $VERSION"
  info "Asset: $ASSET_NAME"
  echo ""

  download_binary
  link_binary

  echo ""
  printf "${GREEN}${BOLD}  Installation complete!${RESET}\n"
  echo ""
  printf "  ${BOLD}Run it:${RESET}\n"
  printf "    ${CYAN}fusion-code${RESET}                          # interactive REPL\n"
  printf "    ${CYAN}fusion-code -p \"your prompt\"${RESET}          # one-shot mode\n"
  echo ""
  printf "  ${BOLD}Set your API key:${RESET}\n"
  printf "    ${CYAN}export ANTHROPIC_API_KEY=\"sk-ant-...\"${RESET}\n"
  echo ""
  printf "  ${BOLD}Or log in with Claude.ai:${RESET}\n"
  printf "    ${CYAN}fusion-code /login${RESET}\n"
  echo ""
  printf "  ${DIM}Install dir: $INSTALL_DIR${RESET}\n"
  printf "  ${DIM}Binary:      $INSTALL_DIR/$BINARY_NAME${RESET}\n"
  printf "  ${DIM}Link:        $LINK_DIR/$BINARY_NAME${RESET}\n"
  printf "  ${DIM}Asset:       $ASSET_NAME${RESET}\n"
  echo ""
}

main "$@"
