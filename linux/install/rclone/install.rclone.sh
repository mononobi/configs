#!/usr/bin/env bash
# Description: Install and configure Rclone
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Rclone official binary, FUSE 3 mount utilities, and systemd mount support.

Options:
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
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

echo "[+] Starting installation/setup for Rclone..."

sudo apt-get update
sudo apt-get install -y curl fuse3 ca-certificates

echo "[+] Running official Rclone install script..."
curl https://rclone.org/install.sh | sudo bash

rclone version

# Create mount directory
echo "[+] Creating mount directory at $HOME/Google-Drive..."
mkdir -p "$HOME/Google-Drive"

# Copy systemd service file to user systemd directory (without enabling it)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$HOME/.config/systemd/user"

if [[ -f "$SCRIPT_DIR/files/rclone-gdrive.service" ]]; then
    echo "[+] Copying rclone-gdrive.service to $HOME/.config/systemd/user/..."
    cp "$SCRIPT_DIR/files/rclone-gdrive.service" "$HOME/.config/systemd/user/rclone-gdrive.service"
    systemctl --user daemon-reload 2>/dev/null || true
    echo "[+] Service file placed at $HOME/.config/systemd/user/rclone-gdrive.service (not enabled)."
    echo "    After configuring your 'gdrive' remote via 'rclone config', enable it with:"
    echo "    systemctl --user enable --now rclone-gdrive.service"
fi

echo "[✓] Rclone setup completed successfully!"
