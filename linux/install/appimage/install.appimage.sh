#!/usr/bin/env bash
# Description: Install and configure appimage
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs AppImage integration helper to automatically manage and create desktop shortcuts for AppImages.

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

echo "[+] Starting installation/setup for appimage..."

sudo apt-get update
sudo apt-get install -y software-properties-common

echo "[+] Adding AppImageLauncher PPA..."
sudo add-apt-repository -y ppa:appimagelauncher-team/stable
sudo apt-get update

echo "[+] Installing appimagelauncher..."
sudo apt-get install -y appimagelauncher

echo "[✓] appimage setup completed successfully!"
