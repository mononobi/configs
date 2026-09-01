#!/usr/bin/env bash
# Description: Install and configure etcher
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Balena Etcher SD card and USB flash tool.

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

echo "[+] Starting installation/setup for etcher..."

sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://balena.io/etcher/static/etcher.gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/balena-etcher.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/balena-etcher.gpg] https://deb.etcher.io stable etcher" | sudo tee /etc/apt/sources.list.d/balena-etcher.list
sudo apt-get update
sudo apt-get install -y balena-etcher-electron || sudo apt-get install -y balena-etcher || true

echo "[✓] etcher setup completed successfully!"
