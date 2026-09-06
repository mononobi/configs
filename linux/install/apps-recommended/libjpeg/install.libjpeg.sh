#!/usr/bin/env bash
# Description: Install and configure libjpeg
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs JPEG compression development libraries (libjpeg-turbo8-dev and libjpeg8-dev).

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

echo "[+] Starting installation/setup for libjpeg..."

sudo apt-get update
sudo apt-get install -y libjpeg-turbo8-dev libjpeg8-dev libjpeg-dev

echo "[✓] libjpeg setup completed successfully!"
