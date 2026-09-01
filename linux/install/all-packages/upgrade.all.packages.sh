#!/usr/bin/env bash
# Description: Install and configure all-packages
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Performs a complete upgrade of all packages across APT, Flatpak, and Snap package managers.

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

echo "[+] Starting installation/setup for all-packages..."

echo "[+] Updating APT packages..."
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get autoremove -y

if command -v flatpak >/dev/null 2>&1; then
    echo "[+] Updating Flatpak applications..."
    flatpak update -y
fi

if command -v snap >/dev/null 2>&1; then
    echo "[+] Updating Snap packages..."
    sudo snap refresh
fi

echo "[✓] all-packages setup completed successfully!"
