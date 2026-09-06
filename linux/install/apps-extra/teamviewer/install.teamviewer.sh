#!/usr/bin/env bash
# Description: Install and configure teamviewer
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Downloads and installs TeamViewer remote control software via official .deb package.

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

echo "[+] Starting installation/setup for teamviewer..."

TEMP_DEB=$(mktemp --suffix=.deb)
echo "[+] Downloading TeamViewer deb package..."
wget -O "$TEMP_DEB" https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
sudo apt-get update
sudo apt-get install -y "$TEMP_DEB"
rm -f "$TEMP_DEB"

echo "[✓] teamviewer setup completed successfully!"
