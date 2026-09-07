#!/usr/bin/env bash
# Description: Install and configure XDM (Xtreme Download Manager)
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

DOWNLOAD_URL=""

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Downloads and installs Xtreme Download Manager (XDM) latest release and prerequisites.

Options:
  -u, --url <URL>    Specify direct download URL for XDM linux_setup.tar.gz
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
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

echo "[+] Starting installation/setup for XDM (Xtreme Download Manager)..."

if [[ "$SKIP_UPDATE" != "true" ]]; then
    sudo apt-get update
fi
sudo apt-get install -y curl tar ca-certificates

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "[+] Fetching latest XDM release from GitHub..."
    DOWNLOAD_URL=$(curl -fsSL https://api.github.com/repos/subhra74/xdm/releases/latest 2>/dev/null | grep -Po '"browser_download_url":\s*"\K[^"]*linux_setup\.tar\.gz' | head -n 1 || true)
fi

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "[!] Could not automatically find latest download URL from GitHub."
    read -r -p "[?] Please enter the direct download URL for XDM (.tar.gz): " DOWNLOAD_URL
fi

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "[!] Error: No download URL provided."
    exit 1
fi

echo "[+] Downloading XDM from $DOWNLOAD_URL..."
curl -fsSL "$DOWNLOAD_URL" -o "$TEMP_DIR/xdm.tar.gz"
tar -xzf "$TEMP_DIR/xdm.tar.gz" -C "$TEMP_DIR"
SETUP_SH=$(find "$TEMP_DIR" -type f -name "install.sh" | head -n 1)
if [[ -n "$SETUP_SH" ]]; then
    sudo bash "$SETUP_SH"
else
    echo "[!] Error: 'install.sh' not found in downloaded XDM archive."
    exit 1
fi

echo "[✓] XDM (Xtreme Download Manager) setup completed successfully!"
