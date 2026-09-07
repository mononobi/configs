#!/usr/bin/env bash
# Description: Install and configure XDM (Xtreme Download Manager)
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

DOWNLOAD_URL="https://github.com/subhra74/xdm/releases/download/7.2.11/xdm-setup-7.2.11.tar.xz"

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Downloads and installs XDM (Xtreme Download Manager 7.2.11).

Options:
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

echo "[+] Starting installation/setup for XDM (Xtreme Download Manager)..."

if [[ "$SKIP_UPDATE" != "true" ]]; then
    sudo apt-get update
fi
sudo apt-get install -y curl tar xz-utils ca-certificates

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

echo "[✓] XDM (Xtreme Download Manager) setup completed successfully!"
