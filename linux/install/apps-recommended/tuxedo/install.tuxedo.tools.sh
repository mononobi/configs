#!/usr/bin/env bash
# Description: Install and configure TUXEDO Control Center & Drivers
# Note: Official repository setup and drivers for TUXEDO hardware.

set -euo pipefail


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"
SKIP_UPDATE="${SKIP_UPDATE:-false}"

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

is_installed "tuxedo-control-center" --name "Tuxedo Control Center" && exit 0

echo "[+] Starting installation/setup for TUXEDO Control Center & Drivers..."

conditional_apt_update
require_app ca-certificates curl gnupg lsb-release

sudo install -m 0755 -d /usr/share/keyrings
curl -fsSL https://deb.tuxedocomputers.com/0x54840598.pub.asc | gpg --dearmor | sudo tee /usr/share/keyrings/tuxedo-archive-keyring.gpg > /dev/null
sudo chmod 644 /usr/share/keyrings/tuxedo-archive-keyring.gpg

# Bootstrap official DEB822 repository configuration.
# When tuxedo-tomte installs tuxedo-repository, it replaces this file with its official symlink.
CODENAME=$(lsb_release -cs)
cat <<EOF | sudo tee /etc/apt/sources.list.d/tuxedo-computers.sources > /dev/null
Types: deb
URIs: https://deb.tuxedocomputers.com/ubuntu
Suites: ${CODENAME}
Components: main
Enabled: yes
Signed-By: /usr/share/keyrings/tuxedo-archive-keyring.gpg
EOF

sudo apt-get update
sudo apt-get install -y tuxedo-tomte tuxedo-control-center

echo "[✓] TUXEDO Control Center & Drivers setup completed successfully!"
