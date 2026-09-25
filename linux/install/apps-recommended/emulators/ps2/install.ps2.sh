#!/usr/bin/env bash
# Description: Install PS2 emulator

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../../utils.sh"
SKIP_UPDATE="${SKIP_UPDATE:-false}"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs PS2 emulator (PCSX2).

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

is_installed "net.pcsx2.PCSX2" --type flatpak --name "PCSX2" && exit 0

echo "[+] Starting installation for PS2 (PCSX2)..."

require_app flatpak

flatpak install -y flathub net.pcsx2.PCSX2

BIOS_ZIP="${SCRIPT_DIR}/../files/ps2.bios.zip"
echo "------------------------------------------------------------"
echo "NOTE: after installing, copy and extract PS2 BIOS files into application's bios directory."
echo "'Settings -> BIOS -> BIOS Directory'"
echo "BIOS files located at: ${BIOS_ZIP}"
echo "------------------------------------------------------------"

echo "[✓] PS2 setup completed successfully!"
