#!/usr/bin/env bash
# Description: Install and configure XDM (Xtreme Download Manager)
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

DOWNLOAD_URL="https://github.com/subhra74/xdm/releases/download/7.2.11/xdm-setup-7.2.11.tar.xz"

SKIP_UPDATE="${SKIP_UPDATE:-false}"
FORCE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Downloads and installs XDM (Xtreme Download Manager 7.2.11).

Options:
  -F, --force        Force reinstallation even if already installed
  --no-update        Skip apt update before installation
  -h, --help         Show this help message and exit
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        --no-update|--skip-update)
            SKIP_UPDATE=true
            shift
            ;;
        -F|--force)
            FORCE=true
            shift
            ;;
        -u|--url)
            DOWNLOAD_URL="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
    esac
done

is_installed "xdman" --name "XDM" && exit 0

echo "[+] Starting installation/setup for XDM (Xtreme Download Manager)..."

require_app curl tar xz-utils ca-certificates

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "[+] Downloading XDM from $DOWNLOAD_URL..."
curl -fsSL "$DOWNLOAD_URL" -o "$TEMP_DIR/xdm.tar.xz"
tar -xf "$TEMP_DIR/xdm.tar.xz" -C "$TEMP_DIR"

SETUP_SH=$(find "$TEMP_DIR" -type f -name "install.sh" | head -n 1)
if [[ -n "$SETUP_SH" && -f "$SETUP_SH" ]]; then
    chmod +x "$SETUP_SH"
    echo "[+] Running XDM installer..."
    sudo bash "$SETUP_SH"
else
    echo "[!] Error: 'install.sh' not found in downloaded XDM archive." >&2
    exit 1
fi

# Configure OpenJ9 Java shared class cache to live under ~/.cache/xdman instead of ~/javasharedresources
if [[ -f "/opt/xdman/xdman" ]]; then
    echo "[+] Configuring Java shared class cache under ~/.cache/xdman..."
    if ! grep -q "cacheDir=" /opt/xdman/xdman; then
        sudo sed -i 's|/opt/xdman/jre/bin/java|/opt/xdman/jre/bin/java -Xshareclasses:cacheDir="${HOME}/.cache/xdman"|g' /opt/xdman/xdman
    fi
    mkdir -p "${HOME}/.cache/xdman"
    rm -rf "${HOME}/javasharedresources"
fi

echo "[✓] XDM (Xtreme Download Manager) setup completed successfully!"
