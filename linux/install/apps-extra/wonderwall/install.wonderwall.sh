#!/usr/bin/env bash
# Description: Install and configure Wonderwall
# Note: Modernized for Ubuntu with pure Flatpak installation.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Wonderwall wallpaper manager via Flatpak.

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

echo "[+] Starting installation for Wonderwall via Flatpak..."

if ! command -v flatpak >/dev/null 2>&1; then
    echo "[+] Flatpak not found. Installing flatpak and adding flathub remote..."
    sudo apt-get update
    sudo apt-get install -y flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

echo "[+] Installing com.gitlab.wonderwall from Flathub..."
flatpak install -y flathub com.gitlab.wonderwall

echo "[✓] Wonderwall installation completed successfully!"
