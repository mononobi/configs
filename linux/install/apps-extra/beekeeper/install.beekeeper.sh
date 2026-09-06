#!/usr/bin/env bash
# Description: Install and configure beekeeper
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Beekeeper Studio SQL editor using the official Beekeeper APT repository.

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

echo "[+] Starting installation/setup for beekeeper..."

sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://deb.beekeeperstudio.io/beekeeper.key | gpg --dearmor | sudo tee /etc/apt/keyrings/beekeeper.gpg > /dev/null
sudo chmod 644 /etc/apt/keyrings/beekeeper.gpg
echo "deb [signed-by=/etc/apt/keyrings/beekeeper.gpg] https://deb.beekeeperstudio.io, stable main" | sudo tee /etc/apt/sources.list.d/beekeeper-studio-app.list
sudo apt-get update
sudo apt-get install -y beekeeper-studio

echo "[✓] beekeeper setup completed successfully!"
