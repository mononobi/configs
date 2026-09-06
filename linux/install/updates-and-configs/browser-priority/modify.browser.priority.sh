#!/usr/bin/env bash
# Description: Install and configure browser-priority
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Configures system default browser alternatives using update-alternatives for x-www-browser and gnome-www-browser.

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

echo "[+] Starting installation/setup for browser-priority..."

echo "[+] Current x-www-browser configuration:"
sudo update-alternatives --display x-www-browser || true

echo ""
echo "[+] To interactively change default browser, running update-alternatives:"
sudo update-alternatives --config x-www-browser
sudo update-alternatives --config gnome-www-browser 2>/dev/null || true

echo "[✓] browser-priority setup completed successfully!"
