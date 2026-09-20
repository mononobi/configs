#!/usr/bin/env bash
# Description: Install and configure Audacity
# Note: Modernized for Ubuntu with pure Flatpak installation.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE="${SKIP_UPDATE:-false}"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Audacity audio editor via Flatpak.

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

is_installed "org.audacityteam.Audacity" --type flatpak --name "Audacity" && exit 0

echo "[+] Starting installation for Audacity via Flatpak..."

require_app "flatpak"

echo "[+] Installing org.audacityteam.Audacity from Flathub..."
flatpak install -y flathub org.audacityteam.Audacity

echo "[✓] Audacity installation completed successfully!"
