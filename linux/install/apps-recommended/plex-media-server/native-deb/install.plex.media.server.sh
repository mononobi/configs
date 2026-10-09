#!/usr/bin/env bash
# Description: Install and configure Plex Media Server & Desktop
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../../utils.sh"
SKIP_UPDATE="${SKIP_UPDATE:-false}"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Plex Media Server via official Plex APT repo and Plex Desktop client via Flatpak.

Options:
  --no-update   Skip apt update before installation
  -f, --force   Force reinstallation even if already installed
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
        -f|--force)
            FORCE=true
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
    if [[ -f "${SCRIPT_DIR}/plex-reset" ]]; then
        ensure_local_bin_in_path
        chmod +x "${SCRIPT_DIR}/plex-reset"
        ln -sf "${SCRIPT_DIR}/plex-reset" "${HOME}/.local/bin/plex-reset"
        echo "[+] Linked plex-reset helper into ${HOME}/.local/bin/plex-reset"
    fi
}

if is_installed "plexmediaserver" --name "Plex Media Server"; then
    setup_symlinks
    exit 0
fi

echo "[+] Starting installation/setup for Plex Media Server & Desktop..."

conditional_apt_update
require_app ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://downloads.plex.tv/plex-keys/PlexSign.key | gpg --dearmor | sudo tee /etc/apt/keyrings/plexmediaserver.gpg > /dev/null
sudo chmod 644 /etc/apt/keyrings/plexmediaserver.gpg

echo "deb [signed-by=/etc/apt/keyrings/plexmediaserver.gpg] https://downloads.plex.tv/repo/deb public main" | sudo tee /etc/apt/sources.list.d/plexmediaserver.list

sudo apt-get update
sudo apt-get install -y plexmediaserver
sudo systemctl enable --now plexmediaserver

setup_symlinks

echo "[✓] Plex Media Server setup completed successfully!"
