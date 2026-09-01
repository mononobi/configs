#!/usr/bin/env bash
# Description: Install and configure recoll
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Recoll full-text desktop search tool via official Recoll PPA.

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

echo "[+] Starting installation/setup for recoll..."

sudo add-apt-repository -y ppa:recoll-backports/recoll-1.15-on
sudo apt-get update
sudo apt-get install -y recoll

echo "[✓] recoll setup completed successfully!"
