#!/usr/bin/env bash
# Description: Install and configure kodi
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Kodi home theater media center via official Team Kodi PPA.

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

echo "[+] Starting installation/setup for kodi..."

sudo add-apt-repository -y ppa:team-xbmc/ppa
sudo apt-get update
sudo apt-get install -y kodi

echo "[✓] kodi setup completed successfully!"
