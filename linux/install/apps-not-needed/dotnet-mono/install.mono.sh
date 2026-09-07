#!/usr/bin/env bash
# Description: Install and configure Mono Runtime & SDK
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Mono complete cross-platform .NET framework via official Mono repository.

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

echo "[+] Starting installation/setup for Mono Runtime & SDK..."

if [[ "$SKIP_UPDATE" != "true" ]]; then
    sudo apt-get update
fi
sudo apt-get install -y ca-certificates gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.mono-project.com/repo/xamarin.gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/mono-official-archive-keyring.gpg > /dev/null
sudo chmod 644 /etc/apt/keyrings/mono-official-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
sudo apt-get update
sudo apt-get install -y mono-complete mono-devel
mono --version

echo "[✓] Mono Runtime & SDK setup completed successfully!"
