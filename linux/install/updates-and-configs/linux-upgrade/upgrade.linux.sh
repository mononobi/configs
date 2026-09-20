#!/usr/bin/env bash
# Description: Install and configure linux-upgrade
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Performs a full Linux distribution upgrade using apt-get dist-upgrade and cleanup.

Options:
  --no-update   Skip apt update before dist-upgrade
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

echo "[+] Starting installation/setup for linux-upgrade..."

echo "[+] Running APT distribution upgrade..."
conditional_apt_update
sudo apt-get dist-upgrade -y
sudo apt-get autoremove -y
sudo apt-get clean

echo "[✓] linux-upgrade setup completed successfully!"
