#!/usr/bin/env bash
# Description: Install and configure FritzBox NAS storage mount via Rclone
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE="${SKIP_UPDATE:-false}"
FORCE=false
FRITZ_IP="192.168.178.1"
SHARE_NAME=""

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Configures an SMB remote for Fritz!Box NAS in Rclone and sets up a user
  systemd service to permanently mount storage at ~/Fritzbox-Storage.

Options:
  --ip <address>      Fritz!Box IP address (default: 192.168.178.1)
  --share <name>      Optional specific share or subfolder to mount (default: root)
  --force             Reconfigure remote and restart systemd service
  --no-update         Skip apt update before installation
  -h, --help          Show this help message and exit
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        --ip)
            if [[ $# -ge 2 ]]; then
                FRITZ_IP="$2"
                shift 2
            else
                echo "[!] Error: --ip requires an argument." >&2
                exit 1
            fi
            ;;
        --ip=*)
            FRITZ_IP="${1#*=}"
            shift
            ;;
        --share)
            if [[ $# -ge 2 ]]; then
                SHARE_NAME="$2"
                shift 2
            else
                echo "[!] Error: --share requires an argument." >&2
                exit 1
            fi
            ;;
        --share=*)
            SHARE_NAME="${1#*=}"
            shift
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

echo "[+] Starting installation/setup for Fritz!Box NAS mount..."

# Ensure Rclone is installed
require_app rclone

# Check if already configured and active
if [[ "$FORCE" != "true" ]]; then
    if rclone listremotes 2>/dev/null | grep -q '^fritzbox:$' && systemctl --user is-active --quiet rclone-fritzbox.service 2>/dev/null; then
        echo "[i] Fritz!Box remote 'fritzbox:' is already configured and rclone-fritzbox.service is active, skipping..."
        exit 0
    fi
fi

# Configure Fritz!Box remote
if rclone listremotes 2>/dev/null | grep -q '^fritzbox:$' && [[ "$FORCE" != "true" ]]; then
    echo "[i] Rclone remote 'fritzbox:' is already configured."
else
    echo ""
    echo "[+] Configuring 'fritzbox' SMB remote..."
    echo "[i] Connecting to Fritz!Box at: ${FRITZ_IP}"
    echo "[i] Ensure your Fritz!Box user has rights to access NAS contents (System -> FRITZ!Box Users)."
    echo ""

    read -rp "Enter Fritz!Box Username: " fritz_user
    if [[ -z "$fritz_user" ]]; then
        echo "[!] Error: Username cannot be empty." >&2
        exit 1
    fi

    read -rsp "Enter Fritz!Box Password: " fritz_pass
    echo ""
    if [[ -z "$fritz_pass" ]]; then
        echo "[!] Error: Password cannot be empty." >&2
        exit 1
    fi

    echo "[+] Encrypting password and creating rclone remote 'fritzbox'..."
    obscured_pass="$(rclone obscure "$fritz_pass")"

    rclone config create fritzbox smb \
        host "$FRITZ_IP" \
        user "$fritz_user" \
        pass "$obscured_pass"

    if ! rclone listremotes 2>/dev/null | grep -q '^fritzbox:$'; then
        echo "[!] Error: Failed to configure 'fritzbox:' remote." >&2
        exit 1
    fi
    echo "[✓] Fritz!Box remote 'fritzbox:' configured successfully!"
fi

# Create mount directory
echo "[+] Creating mount directory at $HOME/Fritzbox-Storage..."
mkdir -p "$HOME/Fritzbox-Storage"

# Copy systemd service file and enable/start it
mkdir -p "$HOME/.config/systemd/user"

SERVICE_DEST="$HOME/.config/systemd/user/rclone-fritzbox.service"
echo "[+] Installing and starting rclone-fritzbox.service..."

if [[ -n "$SHARE_NAME" ]]; then
    # Custom share specified
    sed "s|fritzbox:|fritzbox:${SHARE_NAME}|g" "$SCRIPT_DIR/files/rclone-fritzbox.service" > "$SERVICE_DEST"
else
    cp "$SCRIPT_DIR/files/rclone-fritzbox.service" "$SERVICE_DEST"
fi

systemctl --user daemon-reload
systemctl --user enable --now rclone-fritzbox.service
echo "[✓] rclone-fritzbox.service is enabled and started."

echo "[✓] Fritz!Box NAS mount setup completed successfully!"
