#!/usr/bin/env bash
# Description: Install and configure pyqt5-designer
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"
SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Qt Designer and PyQt5 developer tools via APT.

Options:
  --no-update   Skip apt update before installation
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
        --no-update|--skip-update)
            SKIP_UPDATE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

is_installed "designer" "command" "Qt Designer" && exit 0

echo "[+] Starting installation/setup for pyqt5-designer..."

conditional_apt_update
sudo apt-get install -y qttools5-dev-tools pyqt5-dev-tools qttools5-dev

echo "[✓] pyqt5-designer setup completed successfully!"
