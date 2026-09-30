#!/usr/bin/env bash
# Description: Install and configure Rclone
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE="${SKIP_UPDATE:-false}"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Rclone official binary, FUSE 3 mount utilities, configures Google Drive
  remote, sets up systemd auto-mount service, and adds Nautilus bookmark.

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

echo "[+] Starting installation/setup for Rclone..."

require_app curl ca-certificates unzip

conditional_apt_update
sudo apt-get install -y fuse3

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "[+] Downloading official Rclone install script..."
if ! curl -fsSL https://rclone.org/install.sh -o "$TEMP_DIR/rclone-install.sh"; then
    echo "[!] Error: Failed to download Rclone installation script." >&2
    exit 1
fi

echo "[+] Running official Rclone install script..."
set +e
sudo bash "$TEMP_DIR/rclone-install.sh"
rclone_exit=$?
set -e

# Rclone official install script returns exit code 3 when the latest version is already installed
if [[ $rclone_exit -ne 0 && $rclone_exit -ne 3 ]]; then
    echo "[!] Error: Rclone installation failed with exit code: ${rclone_exit}" >&2
    exit "$rclone_exit"
fi

if [[ $rclone_exit -eq 3 ]]; then
    echo "[i] The latest version of Rclone is already installed and up to date."
fi

rclone version

# Configure Google Drive remote
if rclone listremotes 2>/dev/null | grep -q '^gdrive:$'; then
    echo "[i] Rclone remote 'gdrive:' is already configured."
else
    echo ""
    echo "[+] Configuring 'gdrive' remote..."
    echo "[i] Prerequisites (from install.rclone.md Step 1):"
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

echo "[✓] Rclone setup completed successfully!"
