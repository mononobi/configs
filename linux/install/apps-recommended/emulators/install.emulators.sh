#!/usr/bin/env bash
# Description: Install all emulators and controller support

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"
SKIP_UPDATE="${SKIP_UPDATE:-false}"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs all recommended emulators (PS1, PS2, PS3, PSP, Retro) and controller support.

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

echo "[+] Starting installation for all Emulators and Controller Support..."

require_app "emulators/controller-support" \
            "emulators/ps1" \
            "emulators/ps2" \
            "emulators/ps3" \
            "emulators/psp" \
            "emulators/retro"

echo "[✓] All emulators and controller support installed successfully!"
