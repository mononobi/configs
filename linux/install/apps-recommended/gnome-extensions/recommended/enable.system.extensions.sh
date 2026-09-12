#!/usr/bin/env bash
# Description: Enable and configure built-in GNOME system extensions
# Note: Completely idempotent. Can be run standalone or invoked from batch runners.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
source "${SCRIPT_DIR}/../../../utils.sh"

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Enables and configures built-in Ubuntu system extensions:
    - Ubuntu Dock
    - Ubuntu AppIndicators
    - Ubuntu Tiling Assistant

Options:
  --no-update   Skip apt update when verifying dependencies
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
            echo "[!] Unknown option: $1" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
    esac
done

# Prevent running via sudo
if [[ -n "${SUDO_USER:-}" && $EUID -eq 0 ]]; then
    echo "[!] Error: Do not run $(basename "$0") with sudo." >&2
    echo "    GNOME extensions must be configured in your personal user session." >&2
    echo "    Please run as your regular user: ./$(basename "$0")" >&2
    exit 1
fi

echo "================================================================================"
echo " Enabling and Configuring System Extensions"
echo "================================================================================"

for sys_ext in \
    "ubuntu-dock@ubuntu.com" \
    "ubuntu-appindicators@ubuntu.com" \
    "tiling-assistant@ubuntu.com"; do
    echo "[+] Enabling system extension: ${sys_ext}..."
    gnome-extensions enable "$sys_ext" 2>/dev/null || true
done

# Configure Ubuntu Dock
echo "[+] Applying Ubuntu Dock settings..."
if gsettings list-schemas | grep -q "org.gnome.shell.extensions.dash-to-dock"; then
    gsettings set org.gnome.shell.extensions.dash-to-dock multi-monitor true 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM' 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 40 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'focus-or-previews' 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.dash-to-dock shift-click-action 'launch' 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.dash-to-dock middle-click-action 'minimize' 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.dash-to-dock shift-middle-click-action 'minimize' 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.dash-to-dock disable-overview-on-startup true 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED' 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.65 2>/dev/null || true
fi

echo "[✓] System extensions configured successfully!"
