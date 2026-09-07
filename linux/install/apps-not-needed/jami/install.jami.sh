#!/usr/bin/env bash
# Description: Install and configure jami
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Jami secure communication suite via official Jami repository and keyring.

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

echo "[+] Starting installation/setup for jami..."

if [[ "$SKIP_UPDATE" != "true" ]]; then
    sudo apt-get update
fi
sudo apt-get install -y gnupg dirmngr ca-certificates curl lsb-release --no-install-recommends
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://dl.jami.net/jami-archive-keyring.gpg | sudo tee /etc/apt/keyrings/jami-archive-keyring.gpg > /dev/null
sudo chmod 644 /etc/apt/keyrings/jami-archive-keyring.gpg

CODENAME=$(lsb_release -cs)
echo "deb [signed-by=/etc/apt/keyrings/jami-archive-keyring.gpg] https://dl.jami.net/nightly/ubuntu_${CODENAME}/ jami main" | sudo tee /etc/apt/sources.list.d/jami.list

sudo apt-get update
sudo apt-get install -y jami

echo "[✓] jami setup completed successfully!"
