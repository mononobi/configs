#!/usr/bin/env bash
# Description: Install and configure lsb-release
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs the Linux Standard Base (LSB) release reporting utility (lsb_release) via APT.

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

is_installed "lsb-release" "apt" && exit 0

echo "[+] Starting installation/setup for lsb-release..."

conditional_apt_update
sudo apt-get install -y lsb-release

echo "[✓] lsb-release setup completed successfully!"
