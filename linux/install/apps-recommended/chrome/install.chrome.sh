#!/usr/bin/env bash
# Description: Install and configure chrome
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Google Chrome Browser using the official Google Chrome APT repository and GPG keyring.

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

is_installed "google-chrome" "command" "Google Chrome" && exit 0

echo "[+] Starting installation/setup for chrome..."

require_app "wget" "apps-recommended"
require_app "ca-certificates" "apps-recommended"
require_app "curl" "apps-recommended"
require_app "gnupg" "apps-recommended"

sudo install -m 0755 -d /etc/apt/keyrings
wget -qO - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/google-chrome.gpg > /dev/null
sudo chmod 644 /etc/apt/keyrings/google-chrome.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null
sudo apt-get update
sudo apt-get install -y google-chrome-stable

echo "[✓] chrome setup completed successfully!"

