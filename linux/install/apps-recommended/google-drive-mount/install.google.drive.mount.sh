#!/usr/bin/env bash
# Description: Install and configure Google Drive mount via Rclone
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE="${SKIP_UPDATE:-false}"
FORCE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Configures a Google Drive remote in Rclone and sets up a user systemd
  service to mount Google Drive automatically at ~/Google-Drive.

Options:
  --force       Reconfigure Google Drive remote and recreate systemd service
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
        --force)
            FORCE=true
            shift
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

echo "[+] Starting installation/setup for Google Drive mount..."

# Ensure Rclone is installed
require_app rclone

# Check if already configured and active
if [[ "$FORCE" != "true" ]]; then
    if rclone listremotes 2>/dev/null | grep -q '^gdrive:$' && systemctl --user is-active --quiet rclone-gdrive.service 2>/dev/null; then
        echo "[i] Google Drive remote 'gdrive:' is already configured and rclone-gdrive.service is active, skipping..."
        exit 0
    fi
fi

# Configure Google Drive remote
if rclone listremotes 2>/dev/null | grep -q '^gdrive:$' && [[ "$FORCE" != "true" ]]; then
    echo "[i] Rclone remote 'gdrive:' is already configured."
else
    echo ""
    echo "[+] Configuring 'gdrive' remote..."
    echo "[i] Prerequisites (from install.google.drive.mount.md Step 1):"
    echo "    1. Go to https://console.cloud.google.com"
    echo "    2. Create OAuth 2.0 Desktop App credentials for Google Drive API"
    echo ""

    read -rp "Enter your Google Drive Client ID: " client_id
    if [[ -z "$client_id" ]]; then
        echo "[!] Error: Client ID cannot be empty." >&2
        exit 1
    fi

    read -rp "Enter your Google Drive Client Secret: " client_secret
    if [[ -z "$client_secret" ]]; then
        echo "[!] Error: Client Secret cannot be empty." >&2
        exit 1
    fi

    echo "[+] Creating remote 'gdrive' and opening browser for authorization..."
    rclone config create gdrive drive \
        client_id "$client_id" \
        client_secret "$client_secret" \
        scope "drive" \
        team_drive ""

    if ! rclone listremotes 2>/dev/null | grep -q '^gdrive:$'; then
        echo "[!] Error: Failed to configure 'gdrive:' remote." >&2
        exit 1
    fi
    echo "[✓] Google Drive remote 'gdrive:' configured successfully!"
fi

# Create mount directory
echo "[+] Creating mount directory at $HOME/Google-Drive..."
mkdir -p "$HOME/Google-Drive"

# Copy systemd service file and enable/start it
mkdir -p "$HOME/.config/systemd/user"

if [[ -f "$SCRIPT_DIR/files/rclone-gdrive.service" ]]; then
    echo "[+] Installing and starting rclone-gdrive.service..."
    cp "$SCRIPT_DIR/files/rclone-gdrive.service" "$HOME/.config/systemd/user/rclone-gdrive.service"
    systemctl --user daemon-reload
    systemctl --user enable --now rclone-gdrive.service
    echo "[✓] rclone-gdrive.service is enabled and started."
fi

echo "[✓] Google Drive mount setup completed successfully!"
