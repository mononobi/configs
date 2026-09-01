#!/usr/bin/env bash
# Description: Install and configure signal
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Signal Desktop messenger using official Signal APT repository and GPG keyring.

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

echo "[+] Starting installation/setup for signal..."

sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/signal-desktop-keyring.gpg > /dev/null
sudo chmod 644 /etc/apt/keyrings/signal-desktop-keyring.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main" | sudo tee /etc/apt/sources.list.d/signal-xenial.list
sudo apt-get update
sudo apt-get install -y signal-desktop

echo "[✓] signal setup completed successfully!"
