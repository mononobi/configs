#!/usr/bin/env bash
# Description: Install and configure pyqt5-designer
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Qt Designer and PyQt5 developer tools via APT.

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

echo "[+] Starting installation/setup for pyqt5-designer..."

sudo apt-get update
sudo apt-get install -y qttools5-dev-tools pyqt5-dev-tools qttools5-dev

echo "[✓] pyqt5-designer setup completed successfully!"
