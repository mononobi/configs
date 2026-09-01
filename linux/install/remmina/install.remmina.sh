#!/usr/bin/env bash
# Description: Install and configure remmina
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Remmina remote desktop client and plugins via official Remmina PPA.

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

echo "[+] Starting installation/setup for remmina..."

sudo add-apt-repository -y ppa:remmina-ppa-team/remmina-next
sudo apt-get update
sudo apt-get install -y remmina remmina-plugin-rdp remmina-plugin-secret remmina-plugin-vnc

echo "[✓] remmina setup completed successfully!"
