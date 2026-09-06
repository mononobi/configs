#!/usr/bin/env bash
# Description: Install and configure fuse
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs FUSE 2 runtime libraries required for AppImage execution on modern Ubuntu.

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

echo "[+] Starting installation/setup for fuse..."

echo "[+] Adding universe repository..."
sudo add-apt-repository -y universe
sudo apt-get update

echo "[+] Installing FUSE and AppImage runtime libraries..."
sudo apt-get install -y libfuse2 libxi6 libxrender1 libxtst6 mesa-utils libfontconfig libgtk-3-bin tar dbus-user-session

echo "[✓] fuse setup completed successfully!"
