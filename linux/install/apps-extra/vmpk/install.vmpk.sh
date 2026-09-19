#!/usr/bin/env bash
# Description: Install and configure Virtual MIDI Piano Keyboard (VMPK)
# Note: Modernized for Ubuntu via APT.

set -euo pipefail


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"
SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Virtual MIDI Piano Keyboard (VMPK) via APT.

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

is_installed "vmpk" "command" "Virtual MIDI Piano Keyboard" && exit 0

echo "[+] Starting installation for VMPK (Virtual MIDI Piano Keyboard)..."

conditional_apt_update
sudo apt-get install -y vmpk

echo "[✓] VMPK installation completed successfully!"
