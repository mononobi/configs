#!/usr/bin/env bash
# Description: Install and configure Plex Media Server & Desktop
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Plex Media Server via official Plex APT repo and Plex Desktop client via Flatpak.

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

echo "[+] Starting installation/setup for Plex Media Server & Desktop..."

if [[ "$SKIP_UPDATE" != "true" ]]; then
    sudo apt-get update
fi
sudo apt-get install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://downloads.plex.tv/plex-keys/PlexSign.key | gpg --dearmor | sudo tee /etc/apt/keyrings/plexmediaserver.gpg > /dev/null
sudo chmod 644 /etc/apt/keyrings/plexmediaserver.gpg

echo "deb [signed-by=/etc/apt/keyrings/plexmediaserver.gpg] https://downloads.plex.tv/repo/deb public main" | sudo tee /etc/apt/sources.list.d/plexmediaserver.list

sudo apt-get update
sudo apt-get install -y plexmediaserver
sudo systemctl enable --now plexmediaserver

echo "[✓] Plex Media Server setup completed successfully!"
