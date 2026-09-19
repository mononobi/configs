#!/usr/bin/env bash
# Description: Install and configure teamviewer
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"
SKIP_UPDATE=false
FORCE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Downloads and installs TeamViewer remote control software via official .deb package.

Options:
  -F, --force   Force reinstallation even if already installed
  --no-update   Skip apt update before installation
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
        --no-update|--skip-update)
            SKIP_UPDATE=true
            shift
            ;;
        -F|--force)
            FORCE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

is_installed "teamviewer" --name "TeamViewer" && exit 0

echo "[+] Starting installation/setup for teamviewer..."

require_app wget

TEMP_DEB=$(mktemp --suffix=.deb)
echo "[+] Downloading TeamViewer deb package..."
wget -O "$TEMP_DEB" https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
conditional_apt_update
sudo apt-get install -y "$TEMP_DEB"
rm -f "$TEMP_DEB"

echo "[+] Adding TeamViewer repository signing key..."
wget --quiet -O - https://dl.teamviewer.com/download/linux/signature/TeamViewer2017.asc | sudo tee /etc/apt/trusted.gpg.d/teamviewer.asc > /dev/null

echo "[✓] teamviewer setup completed successfully!"
