#!/usr/bin/env bash
# Description: Install xdg-user-dirs utility
# Note: Idempotent and safe to run multiple times.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE=\"${SKIP_UPDATE:-false}\"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs xdg-user-dirs utility (xdg-user-dir) for managing well-known user directories via APT.

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

is_installed "xdg-user-dir" --name "xdg-user-dirs" && exit 0

echo "[+] Starting installation/setup for xdg-user-dirs..."

conditional_apt_update
sudo apt-get install -y xdg-user-dirs

echo "[✓] xdg-user-dirs setup completed successfully!"
