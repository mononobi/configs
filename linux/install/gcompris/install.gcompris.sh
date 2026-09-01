#!/usr/bin/env bash
# Description: Install and configure GCompris
# Note: Modernized for Ubuntu with pure Flatpak installation.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs GCompris educational software suite via Flatpak.

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

echo "[+] Starting installation for GCompris via Flatpak..."

if ! command -v flatpak >/dev/null 2>&1; then
    echo "[+] Flatpak not found. Installing flatpak and adding flathub remote..."
    sudo apt-get update
    sudo apt-get install -y flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

echo "[+] Installing net.gcompris.GCompris from Flathub..."
flatpak install -y flathub net.gcompris.GCompris

echo "[✓] GCompris installation completed successfully!"
