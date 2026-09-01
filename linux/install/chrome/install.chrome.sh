#!/usr/bin/env bash
# Description: Install and configure chrome
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Google Chrome Browser using the official Google Chrome .deb package (recommended method).

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

echo "[+] Starting installation/setup for chrome..."

TEMP_DEB="$(mktemp --suffix=.deb)"
echo "[+] Downloading Google Chrome debian package..."
wget -O "$TEMP_DEB" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
sudo apt-get update
sudo apt-get install -y "$TEMP_DEB"
rm -f "$TEMP_DEB"

echo "[✓] chrome setup completed successfully!"
