#!/usr/bin/env bash
# Description: Install, enable, and configure System Monitor GNOME Shell extension
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
  Installs, enables, and configures System Monitor
  (UUID: system-monitor@gnome-shell-extensions.gcampax.github.com).
  Displays system status (CPU, memory, network) in the GNOME top panel.

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

echo "[+] Ensuring gnome-system-monitor application dependency is installed..."
if [[ "$SKIP_UPDATE" == "true" ]]; then
    require_app "gnome-system-monitor" "apps-recommended" --no-update
else
    require_app "gnome-system-monitor" "apps-recommended"
fi

install_gnome_extension "system-monitor@gnome-shell-extensions.gcampax.github.com" "System Monitor"

if gsettings list-schemas | grep -q "org.gnome.shell.extensions.system-monitor"; then
    echo "[+] Configuring System Monitor settings..."
    gsettings set org.gnome.shell.extensions.system-monitor show-swap false 2>/dev/null || true
fi
