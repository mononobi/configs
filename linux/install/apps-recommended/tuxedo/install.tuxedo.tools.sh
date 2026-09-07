#!/usr/bin/env bash
# Description: Install and configure TUXEDO Control Center & Drivers
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs TUXEDO Computers hardware control center, keyboard backlight, and driver utilities via official TUXEDO repository.

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

echo "[+] Starting installation/setup for TUXEDO Control Center & Drivers..."

if [[ "$SKIP_UPDATE" != "true" ]]; then
    sudo apt-get update
fi
sudo apt-get install -y ca-certificates curl gnupg lsb-release

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://deb.tuxedocomputers.com/0x54840598.pub.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/tuxedocomputers.gpg > /dev/null
sudo chmod 644 /etc/apt/keyrings/tuxedocomputers.gpg

CODENAME=$(lsb_release -cs)
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/tuxedocomputers.gpg] https://deb.tuxedocomputers.com/ubuntu ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/tuxedo-computers.list

sudo apt-get update
sudo apt-get install -y tuxedo-tomte tuxedo-control-center

echo "[✓] TUXEDO Control Center & Drivers setup completed successfully!"
