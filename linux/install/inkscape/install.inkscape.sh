#!/usr/bin/env bash
# Description: Install and configure inkscape
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Inkscape vector graphics editor via the official Inkscape PPA.

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

echo "[+] Starting installation/setup for inkscape..."

sudo add-apt-repository -y ppa:inkscape.dev/stable
sudo apt-get update
sudo apt-get install -y inkscape

echo "[✓] inkscape setup completed successfully!"
