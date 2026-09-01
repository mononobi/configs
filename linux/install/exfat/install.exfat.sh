#!/usr/bin/env bash
# Description: Install and configure exfat
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs exFAT filesystem utilities (exfatprogs / exfat-fuse) for reading/writing exFAT drives.

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

echo "[+] Starting installation/setup for exfat..."

sudo apt-get update
# On modern Ubuntu (20.04+), exfatprogs is the modern official tool
sudo apt-get install -y exfatprogs || sudo apt-get install -y exfat-fuse exfat-utils

echo "[✓] exfat setup completed successfully!"
