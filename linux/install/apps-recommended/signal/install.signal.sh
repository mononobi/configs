#!/usr/bin/env bash
# Description: Install and configure signal
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Signal Desktop messenger using official Signal APT repository and GPG keyring.

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

echo "[+] Starting installation/setup for signal..."

if ! dpkg-query -W -f='${Status}' ca-certificates 2>/dev/null | grep -q "ok installed"; then
    require_app "ca-certificates" "apps-recommended"
fi
if ! command -v curl >/dev/null 2>&1; then
    require_app "curl" "apps-recommended"
fi
if ! command -v gpg >/dev/null 2>&1; then
    require_app "gnupg" "apps-recommended"
fi

if [[ "$SKIP_UPDATE" != "true" ]]; then
    sudo apt-get update
fi
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/signal-desktop-keyring.gpg > /dev/null
sudo chmod 644 /etc/apt/keyrings/signal-desktop-keyring.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main" | sudo tee /etc/apt/sources.list.d/signal-xenial.list
sudo apt-get update
sudo apt-get install -y signal-desktop

echo "[✓] signal setup completed successfully!"
