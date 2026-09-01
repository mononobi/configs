#!/usr/bin/env bash
# Description: Install and configure zoom
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Downloads and installs Zoom video conferencing client official .deb package.

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

echo "[+] Starting installation/setup for zoom..."

TEMP_DEB=$(mktemp --suffix=.deb)
echo "[+] Downloading Zoom deb package..."
wget -O "$TEMP_DEB" https://zoom.us/client/latest/zoom_amd64.deb
sudo apt-get update
sudo apt-get install -y "$TEMP_DEB"
rm -f "$TEMP_DEB"

echo "[✓] zoom setup completed successfully!"
