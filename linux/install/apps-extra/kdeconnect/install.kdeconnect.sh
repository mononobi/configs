#!/usr/bin/env bash
# Description: Install and configure kdeconnect
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs KDE Connect device integration tool via APT.

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

echo "[+] Starting installation/setup for kdeconnect..."

sudo apt-get update
sudo apt-get install -y kdeconnect
echo "[+] Note: If using GNOME Shell, the GSConnect extension (https://extensions.gnome.org/extension/1319/gsconnect/) is also recommended."

echo "[✓] kdeconnect setup completed successfully!"
