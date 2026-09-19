#!/usr/bin/env bash
# Description: Install and configure anydesk
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"
SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs AnyDesk remote desktop application using the official AnyDesk APT repository and GPG keyring.

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

is_installed "anydesk" "command" "AnyDesk" && exit 0

echo "[+] Starting installation/setup for anydesk..."

if [[ "$SKIP_UPDATE" != "true" ]]; then
    sudo apt-get update
fi
require_app "ca-certificates" "apps-recommended"
require_app "curl" "apps-recommended"
require_app "gnupg" "apps-recommended"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY | gpg --dearmor | sudo tee /etc/apt/keyrings/anydesk.gpg > /dev/null
sudo chmod 644 /etc/apt/keyrings/anydesk.gpg
echo "deb [signed-by=/etc/apt/keyrings/anydesk.gpg] http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list
sudo apt-get update
sudo apt-get install -y anydesk

echo "[✓] anydesk setup completed successfully!"
