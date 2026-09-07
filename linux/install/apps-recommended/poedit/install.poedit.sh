#!/usr/bin/env bash
# Description: Install and configure Poedit
# Note: Modernized for Ubuntu with pure Flatpak installation.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Poedit translation and gettext editor via Flatpak.

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

echo "[+] Starting installation for Poedit via Flatpak..."

if ! command -v flatpak >/dev/null 2>&1; then
    echo "[!] Flatpak not found. Installing flatpak dependency..."
    require_app "flatpak" "apps-recommended"
fi

echo "[+] Installing net.poedit.Poedit from Flathub..."
flatpak install -y flathub net.poedit.Poedit

echo "[✓] Poedit installation completed successfully!"
