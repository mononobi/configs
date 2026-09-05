#!/usr/bin/env bash
# Description: Install and configure Pipenv
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Pipenv virtual environment and package manager via pipx (recommended) or pip.

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

echo "[+] Starting installation/setup for Pipenv..."

sudo apt-get update
sudo apt-get install -y python3-pip python3-venv pipx

echo "[+] Installing pipenv via pipx..."
pipx install pipenv || pip3 install --user pipenv

pipenv --version || true

echo "[✓] Pipenv setup completed successfully!"
