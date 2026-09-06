#!/usr/bin/env bash
# Description: Install and configure 7z
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs 7-Zip archive utilities (p7zip-full and p7zip-rar) via APT.

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

echo "[+] Starting installation/setup for 7z..."

sudo apt-get update
sudo apt-get install -y p7zip-full p7zip-rar

echo "[✓] 7z setup completed successfully!"
