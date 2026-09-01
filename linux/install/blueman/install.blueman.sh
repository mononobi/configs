#!/usr/bin/env bash
# Description: Install and configure blueman
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Blueman Bluetooth manager via APT.

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

echo "[+] Starting installation/setup for blueman..."

sudo apt-get update
sudo apt-get install -y blueman
# PulseAudio bluetooth module is only needed on older PulseAudio systems
if ! command -v pipewire >/dev/null 2>&1; then
    sudo apt-get install -y pulseaudio-module-bluetooth || true
fi

echo "[✓] blueman setup completed successfully!"
