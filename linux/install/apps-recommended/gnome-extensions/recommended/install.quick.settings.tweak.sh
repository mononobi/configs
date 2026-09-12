#!/usr/bin/env bash
# Description: Install and enable Quick Settings Tweaker GNOME Shell extension
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
  Installs and enables Quick Settings Tweaker (UUID: quick-settings-tweaks@qwreey),
  reorganizing notifications, volume widgets, and toggles in the Quick Settings menu.

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
    echo "    GNOME extensions must be installed in your personal user session." >&2
    echo "    Please run as your regular user: ./$(basename "$0")" >&2
    exit 1
fi

install_gnome_extension "quick-settings-tweaks@qwreey" "Quick Settings Tweaker"

# Apply recommended settings if schema is available
if gsettings list-schemas | grep -q "org.gnome.shell.extensions.quick-settings-tweaks"; then
    echo "[+] Configuring Quick Settings Tweaker settings..."
    gsettings set org.gnome.shell.extensions.quick-settings-tweaks media-control-enabled true 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.quick-settings-tweaks notifications-enabled true 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.quick-settings-tweaks weather-enabled false 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.quick-settings-tweaks volume-mixer-enabled false 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.quick-settings-tweaks dnd-quick-toggle-enabled true 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.quick-settings-tweaks unsafe-quick-toggle-enabled false 2>/dev/null || true
fi
