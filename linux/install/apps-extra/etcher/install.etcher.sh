#!/usr/bin/env bash
# Description: Install and configure etcher
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Balena Etcher SD card and USB flash tool.

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

echo "[+] Starting installation/setup for etcher..."

sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

echo "[+] Adding Balena Etcher repository via official Cloudsmith script..."
curl -1sLf 'https://dl.cloudsmith.io/public/balena/etcher/setup.deb.sh' | sudo -E bash

sudo apt-get update
sudo apt-get install -y balena-etcher-electron

echo "[✓] etcher setup completed successfully!"
