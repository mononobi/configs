#!/usr/bin/env bash
# Description: Install and configure Sugar Labs Music Keyboard for kids
# Note: Installs via Flatpak from Flathub.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE=\"${SKIP_UPDATE:-false}\"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Sugar Labs Music Keyboard (a piano/keyboard simulator for kids) via Flatpak.

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

is_installed "org.sugarlabs.MusicKeyboard" --type flatpak --name "Sugar Labs Music Keyboard" && exit 0

echo "[+] Starting installation for Sugar Labs Music Keyboard via Flatpak..."

require_app "flatpak"

echo "[+] Installing org.sugarlabs.MusicKeyboard from Flathub..."
flatpak install -y flathub org.sugarlabs.MusicKeyboard

echo "[✓] Sugar Labs Music Keyboard installation completed successfully!"
