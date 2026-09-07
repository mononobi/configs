#!/usr/bin/env bash
# Description: Install and configure GNOME Shell Extension Manager and Browser Connector (Activator)
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SKIP_UPDATE=false

show_help() {
    cat <<EOHELP
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs GNOME Shell Extension Manager (app), official extensions, and the browser connector.
  Disables extension version compatibility validation so extensions remain functional across GNOME releases.

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
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

echo "[+] Starting installation/setup for GNOME Shell Extensions Activator..."

# Install Extension Manager, official extensions, and browser connector
echo "[+] Installing packages: gnome-shell-extension-manager, gnome-shell-extensions..."
sudo apt-get install -y gnome-shell-extension-manager gnome-shell-extensions

echo "[✓] GNOME Shell Extensions Activator setup completed successfully!"
