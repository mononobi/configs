#!/usr/bin/env bash
# Description: Install and configure DBeaver CE
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs DBeaver Community Edition SQL client via official DBeaver APT repository.

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

echo "[+] Starting installation/setup for DBeaver CE..."

sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://dbeaver.io/debs/dbeaver.gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/dbeaver.gpg > /dev/null
sudo chmod 644 /etc/apt/keyrings/dbeaver.gpg
echo "deb [signed-by=/etc/apt/keyrings/dbeaver.gpg] https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list
sudo apt-get update
sudo apt-get install -y dbeaver-ce

echo "[✓] DBeaver CE setup completed successfully!"
