#!/usr/bin/env bash
# Description: Install and configure XDM (Xtreme Download Manager)
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Downloads and installs Xtreme Download Manager (XDM) latest release and prerequisites.

Options:
  -h, --help    Show this help message and exit
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

echo "[+] Starting installation/setup for XDM (Xtreme Download Manager)..."

sudo apt-get update
sudo apt-get install -y curl tar ca-certificates default-jre || sudo apt-get install -y openjdk-17-jre || true

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "[+] Fetching latest XDM release from GitHub..."
DOWNLOAD_URL=$(curl -fsSL https://api.github.com/repos/subhra74/xdm/releases/latest | grep -Po '"browser_download_url":\s*"\K[^"]*linux_setup\.tar\.gz' | head -n 1 || true)

if [[ -n "$DOWNLOAD_URL" ]]; then
    echo "[+] Downloading XDM from $DOWNLOAD_URL..."
    curl -fsSL "$DOWNLOAD_URL" -o "$TEMP_DIR/xdm.tar.gz"
    tar -xzf "$TEMP_DIR/xdm.tar.gz" -C "$TEMP_DIR"
    SETUP_SH=$(find "$TEMP_DIR" -type f -name "install.sh" | head -n 1)
    if [[ -n "$SETUP_SH" ]]; then
        sudo bash "$SETUP_SH"
    fi
else
    echo "[!] Could not fetch download URL automatically. Please download from https://github.com/subhra74/xdm/releases"
fi

echo "[✓] XDM (Xtreme Download Manager) setup completed successfully!"
