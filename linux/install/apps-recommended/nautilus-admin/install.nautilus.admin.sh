#!/usr/bin/env bash
# Description: Install and configure nautilus-admin
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs nautilus-admin extension for opening files and directories as Administrator.

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

echo "[+] Starting installation/setup for nautilus-admin..."

sudo apt-get update
sudo apt-get install -y nautilus-admin
nautilus -q 2>/dev/null || true

echo "[✓] nautilus-admin setup completed successfully!"
