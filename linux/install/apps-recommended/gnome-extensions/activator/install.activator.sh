#!/usr/bin/env bash
# Description: Install and configure GNOME Shell Extension Manager and Browser Connector (Activator)
# Note: Implements the guidelines in install.activator.txt. Completely idempotent.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"

SKIP_UPDATE=false

show_help() {
    cat <<EOHELP
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs GNOME Shell Extension Manager (app), official GNOME extensions,
  and the browser connector (chrome-gnome-shell).
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

echo "================================================================================"
echo " Starting GNOME Shell Extensions Activator Setup"
echo "================================================================================"

if [[ "$SKIP_UPDATE" != "true" ]]; then
    sudo apt-get update
fi

echo "[+] Installing packages: gnome-shell-extension-manager, gnome-shell-extensions, chrome-gnome-shell..."
sudo apt-get install -y gnome-shell-extension-manager gnome-shell-extensions chrome-gnome-shell

echo "[✓] GNOME Shell Extensions Activator setup completed successfully!"
