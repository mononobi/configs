#!/usr/bin/env bash
# Description: Install and configure Virtual MIDI Piano Keyboard (VMPK)
# Note: Modernized for Ubuntu via APT.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Virtual MIDI Piano Keyboard (VMPK) via APT.

Options:
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
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

echo "[+] Starting installation for VMPK (Virtual MIDI Piano Keyboard)..."

sudo apt-get update
sudo apt-get install -y vmpk

echo "[✓] VMPK installation completed successfully!"
