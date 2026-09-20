#!/usr/bin/env bash
# Description: Install and configure sublime-text
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"
SKIP_UPDATE="${SKIP_UPDATE:-false}"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Sublime Text code editor using official Sublime HQ APT repository and GPG keyring.

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

is_installed "subl" --name "Sublime Text" && exit 0

echo "[+] Starting installation/setup for sublime-text..."

conditional_apt_update
require_app ca-certificates curl gnupg apt-transport-https
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/sublimehq-pub.gpg > /dev/null
sudo chmod 644 /etc/apt/keyrings/sublimehq-pub.gpg
echo "deb [signed-by=/etc/apt/keyrings/sublimehq-pub.gpg] https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt-get update
sudo apt-get install -y sublime-text

echo "[✓] sublime-text setup completed successfully!"
