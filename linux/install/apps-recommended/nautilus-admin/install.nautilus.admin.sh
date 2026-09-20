#!/usr/bin/env bash
# Description: Install and configure nautilus-admin
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"
SKIP_UPDATE="${SKIP_UPDATE:-false}"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs nautilus-admin extension for opening files and directories as Administrator.

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

is_installed "nautilus-admin" --name "Nautilus Admin" && exit 0

echo "[+] Starting installation/setup for nautilus-admin..."

conditional_apt_update
sudo apt-get install -y nautilus-admin
nautilus -q 2>/dev/null || true

echo "[✓] nautilus-admin setup completed successfully!"
