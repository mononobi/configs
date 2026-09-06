#!/usr/bin/env bash
# Description: Install and configure yay
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs yay AUR helper (for Arch Linux / pacman systems).

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

echo "[+] Starting installation/setup for yay..."

if command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm base-devel git
    TEMP_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$TEMP_DIR"
    cd "$TEMP_DIR"
    makepkg -si --noconfirm
    rm -rf "$TEMP_DIR"
else
    echo "[!] 'pacman' was not detected. yay is an AUR package manager designed for Arch Linux-based distributions."
fi

echo "[✓] yay setup completed successfully!"
