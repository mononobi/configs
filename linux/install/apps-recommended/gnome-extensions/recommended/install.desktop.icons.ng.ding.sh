#!/usr/bin/env bash
# Description: Install, enable, and configure Desktop Icons NG (DING) GNOME Shell extension
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
  Installs, enables, and configures Desktop Icons NG (DING) (UUID: ding@rastersoft.com).
  Adds icons to the desktop with customizable sizing and alignment.

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

install_gnome_extension "ding@rastersoft.com" "Desktop Icons NG (DING)"

if gsettings list-schemas | grep -q "org.gnome.shell.extensions.ding"; then
    echo "[+] Configuring Desktop Icons NG (DING) settings..."
    gsettings set org.gnome.shell.extensions.ding icon-size 'small' 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.ding show-home false 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.ding show-trash true 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.ding show-volumes false 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.ding show-network-volumes false 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.ding start-corner 'top-left' 2>/dev/null || true
fi
