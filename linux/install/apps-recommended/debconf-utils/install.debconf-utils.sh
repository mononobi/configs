#!/usr/bin/env bash
# Description: Install debconf-utils
# Note: Idempotent and safe to run multiple times.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE=\"${SKIP_UPDATE:-false}\"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs debconf-utils (including debconf-set-selections and debconf-get-selections)
  for non-interactive package pre-seeding.

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

is_installed "debconf-set-selections" --name "debconf-utils" && exit 0

echo "[+] Starting installation/setup for debconf-utils..."

conditional_apt_update
sudo apt-get install -y debconf-utils

echo "[✓] debconf-utils setup completed successfully!"
