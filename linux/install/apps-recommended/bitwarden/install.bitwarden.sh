#!/usr/bin/env bash
# Description: Install and configure Bitwarden
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Bitwarden Desktop client via Flatpak and unlock helper.

Options:
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
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

echo "[+] Starting installation/setup for Bitwarden..."

# 1. Install Bitwarden Desktop via Flatpak
if ! command -v flatpak >/dev/null 2>&1; then
    if [[ "$SKIP_UPDATE" != "true" ]]; then
        sudo apt-get update
    fi
    sudo apt-get install -y flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

echo "[+] Installing Bitwarden Desktop from Flathub..."
flatpak install -y flathub com.bitwarden.desktop

# 2. Setup bitwarden-unlock helper script if present
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/bitwarden-unlock" ]]; then
    mkdir -p "$HOME/.local/bin"
    install -m 755 "$SCRIPT_DIR/bitwarden-unlock" "$HOME/.local/bin/bitwarden-unlock"
    echo "[+] Installed bitwarden-unlock helper to $HOME/.local/bin/bitwarden-unlock"
fi

echo "[✓] Bitwarden setup completed successfully!"
