#!/usr/bin/env bash
# Description: Install PS3 emulator

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../../utils.sh"
SKIP_UPDATE="${SKIP_UPDATE:-false}"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs PS3 emulator (RPCS3).

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

is_installed "net.rpcs3.RPCS3" --type flatpak --name "RPCS3" && exit 0

echo "[+] Starting installation for PS3 (RPCS3)..."

require_app flatpak

flatpak install -y flathub net.rpcs3.RPCS3

echo "------------------------------------------------------------"
echo "NOTE: you should download PS3 firmware from Sony, and then install it inside the app."
echo "get the firmware from this link:"
echo "https://www.playstation.com/en-us/support/hardware/ps3/system-software/"
echo ""
echo "after app installation has been finished, install the downloaded firmware"
echo "from 'File -> Install Firmware' menu."
echo ""
echo "each game should be in the following folder structure to work:"
echo "Game Title -> Region ID -> PS3_GAME, PS3_UPDATE, PS3_DISC.SFB"
echo "for example:"
echo "WRC 5 -> BLES02242 -> PS3_GAME, PS3_UPDATE, PS3_DISC.SFB"
echo ""
echo "inside the region id folder, there should be these subdirectories:"
echo "PS3_GAME"
echo "PS3_UPDATE (optional)"
echo ""
echo "inside the region id folder, there should be this file:"
echo "PS3_DISC.SFB"
echo ""
echo "when you want to add games into emulator app, you should select game title"
echo "folders in-which region id folder is located."
echo "------------------------------------------------------------"

echo "[✓] PS3 setup completed successfully!"
