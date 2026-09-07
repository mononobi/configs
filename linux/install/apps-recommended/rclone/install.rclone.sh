#!/usr/bin/env bash
# Description: Install and configure Rclone
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Rclone official binary, FUSE 3 mount utilities, and systemd mount support.

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

if [[ "$SKIP_UPDATE" != "true" ]]; then
    sudo apt-get update
fi
sudo apt-get install -y curl fuse3 ca-certificates unzip

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

# Create mount directory
echo "[+] Creating mount directory at $HOME/Google-Drive..."
mkdir -p "$HOME/Google-Drive"

# Copy systemd service file to user systemd directory (without enabling it)
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
