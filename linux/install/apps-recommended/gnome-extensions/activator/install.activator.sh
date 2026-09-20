#!/usr/bin/env bash
# Description: Install and configure GNOME Shell Extension Manager and Browser Connector (Activator)
# Note: Implements the guidelines in install.activator.txt. Completely idempotent.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
source "${SCRIPT_DIR}/../../../utils.sh"

SKIP_UPDATE="${SKIP_UPDATE:-false}"

show_help() {
    cat <<EOHELP
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs GNOME Shell Extension Manager (app), official GNOME extensions,
  and the browser connector (gnome-browser-connector).
  Disables extension version compatibility validation so extensions remain functional.

Options:
  --no-update   Skip apt update before installation
  -h, --help    Show this help message and exit
EOHELP
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

is_installed "gnome-shell" && is_installed "extension-manager" && is_installed "gnome-extensions-app" && is_installed "gnome-extensions" && is_installed "gnome-browser-connector" && exit 0

echo "================================================================================"
echo " Starting GNOME Shell Extensions Activator Setup"
echo "================================================================================"

conditional_apt_update

echo "[+] Installing packages: gnome-shell, gnome-shell-extension-manager, gnome-shell-extensions, gnome-browser-connector..."
sudo apt-get install -y gnome-shell gnome-shell-extension-manager gnome-shell-extensions gnome-browser-connector

echo "[✓] GNOME Shell Extensions Activator setup completed successfully!"
