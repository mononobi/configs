#!/usr/bin/env bash
# Description: Install and configure Pipenv
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Pipenv virtual environment and package manager via pipx (recommended) or pip.

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

echo "[+] Starting installation/setup for Pipenv..."

if [[ "$SKIP_UPDATE" != "true" ]]; then
    sudo apt-get update
fi
sudo apt-get install -y virtualenv pipx

echo "[+] Installing pipenv via pipx..."
pipx install pipenv
pipx ensurepath

echo "[✓] Pipenv setup completed successfully!"
