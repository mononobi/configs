#!/usr/bin/env bash
# Description: Install Retro emulator

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../../utils.sh"
SKIP_UPDATE="${SKIP_UPDATE:-false}"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Retro emulator (Mednaffe).

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

is_installed "com.github.AmatCoder.mednaffe" --type flatpak --name "Mednaffe" && exit 0

echo "[+] Starting installation for Retro emulator (Mednaffe)..."

require_app flatpak

flatpak install -y flathub com.github.AmatCoder.mednaffe

GAMES_DIR="/mnt/archives-1/Applications/Emulators/Games/Retro"
if [[ -d "$GAMES_DIR" ]]; then
    echo "[+] Found games directory at $GAMES_DIR, applying flatpak filesystem override..."
    sudo flatpak override --filesystem="$GAMES_DIR" com.github.AmatCoder.mednaffe
else
    echo "------------------------------------------------------------"
    echo "NOTE: Games directory $GAMES_DIR does not exist."
    echo "To be able to load your games into the app, you should give access to the games folders."
    echo "You can execute this command once for each folder you want to give access to:"
    echo "sudo flatpak override --filesystem=PATH_TO_GAMES_FOLDER com.github.AmatCoder.mednaffe"
    echo "------------------------------------------------------------"
fi

echo "IMPORTANT:"
echo "if you have no sound coming out from games, you should try different sound"
echo "drivers in the settings:"
echo "'Global Settings -> Sound -> Driver'"
echo "try different drivers to see which one will work."
echo "on ubuntu the 'sdl' driver works."

echo "[✓] Retro emulator setup completed successfully!"
