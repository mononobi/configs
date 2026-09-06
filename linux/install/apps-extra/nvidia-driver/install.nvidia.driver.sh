#!/usr/bin/env bash
# Description: Install and configure nvidia-driver
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs NVIDIA proprietary graphics drivers using ubuntu-drivers tool.

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

echo "[+] Starting installation/setup for nvidia-driver..."

sudo add-apt-repository -y ppa:graphics-drivers/ppa
sudo apt-get update
sudo ubuntu-drivers autoinstall
echo "[+] NVIDIA drivers installed. Please reboot your system to apply changes."

echo "[✓] nvidia-driver setup completed successfully!"
