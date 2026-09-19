#!/usr/bin/env bash
# Description: Install gtk-update-icon-cache utility
# Note: Idempotent and safe to run multiple times.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs gtk-update-icon-cache utility for generating and updating icon theme cache files via APT.

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
            echo "Unknown option: $1" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
    esac
done

is_installed "gtk-update-icon-cache" && exit 0

echo "[+] Starting installation/setup for gtk-update-icon-cache..."

conditional_apt_update
sudo apt-get install -y gtk-update-icon-cache

echo "[✓] gtk-update-icon-cache setup completed successfully!"
