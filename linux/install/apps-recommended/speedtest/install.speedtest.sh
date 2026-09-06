#!/usr/bin/env bash
# Description: Install and configure Ookla Speedtest CLI
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs official Ookla Speedtest CLI using the official Ookla repository or binary.

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

echo "[+] Starting installation/setup for Ookla Speedtest CLI..."

sudo apt-get update
sudo apt-get install -y curl ca-certificates

echo "[+] Setting up official Ookla Speedtest repository..."
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash

echo "[+] Installing speedtest..."
sudo apt-get install -y speedtest

speedtest --version || true

echo "[✓] Ookla Speedtest CLI setup completed successfully!"
