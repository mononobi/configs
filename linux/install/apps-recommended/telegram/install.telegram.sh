#!/usr/bin/env bash
# Description: Install and configure Telegram
# Note: Modernized for Ubuntu with pure Flatpak installation.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Telegram Desktop messenger via Flatpak and configures home filesystem permissions.

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

echo "[+] Starting installation for Telegram via Flatpak..."

if ! command -v flatpak >/dev/null 2>&1; then
    echo "[!] Flatpak not found. Installing flatpak dependency..."
    require_app "flatpak" "apps-recommended"
fi

echo "[+] Installing org.telegram.desktop from Flathub..."
flatpak install -y flathub org.telegram.desktop

echo "[+] Configuring filesystem permissions for Telegram Desktop..."
flatpak override --user --filesystem=home org.telegram.desktop

echo "[✓] Telegram installation completed successfully!"
