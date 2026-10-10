#!/usr/bin/env bash
# Description: Install and configure Bitwarden
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE="${SKIP_UPDATE:-false}"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Bitwarden Desktop client via Flatpak and links unlock helper into ~/.local/bin.

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

setup_symlinks() {
    symlink_to_local_bin "$SCRIPT_DIR/bitwarden-unlock"
}

if is_installed "com.bitwarden.desktop" --type flatpak --name "Bitwarden"; then
    setup_symlinks
    exit 0
fi

echo "[+] Starting installation/setup for Bitwarden..."

# 1. Install Bitwarden Desktop via Flatpak
require_app "flatpak"

echo "[+] Installing Bitwarden Desktop from Flathub..."
flatpak install -y flathub com.bitwarden.desktop

# 2. Setup bitwarden-unlock helper script if present
setup_symlinks

echo "[✓] Bitwarden setup completed successfully!"
