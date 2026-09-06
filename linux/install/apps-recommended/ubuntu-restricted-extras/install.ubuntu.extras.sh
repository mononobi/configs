#!/usr/bin/env bash
# Description: Install and configure ubuntu-restricted-extras
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs ubuntu-restricted-extras package (audio/video codecs, fonts, unrar).

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

echo "[+] Starting installation/setup for ubuntu-restricted-extras..."

sudo apt-get update
# Pre-accept Microsoft TrueType core fonts EULA to prevent interactive hang
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections || true
sudo apt-get install -y ubuntu-restricted-extras

echo "[✓] ubuntu-restricted-extras setup completed successfully!"
