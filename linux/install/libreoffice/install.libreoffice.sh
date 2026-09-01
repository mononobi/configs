#!/usr/bin/env bash
# Description: Install and configure libreoffice
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs and upgrades LibreOffice office suite to the latest fresh release via official LibreOffice PPA.

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

echo "[+] Starting installation/setup for libreoffice..."

sudo add-apt-repository -y ppa:libreoffice/ppa
sudo apt-get update
sudo apt-get install -y libreoffice libreoffice-gtk3

echo "[✓] libreoffice setup completed successfully!"
