#!/usr/bin/env bash
# Description: Install and configure poetry
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Python Poetry packaging and dependency manager using the official installer.

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

echo "[+] Starting installation/setup for poetry..."

sudo apt-get update
sudo apt-get install -y curl python3 python3-venv

echo "[+] Running official Poetry installer..."
curl -sSL https://install.python-poetry.org | python3 -

# Configure PATH if not already present
export PATH="$HOME/.local/bin:$PATH"
echo '[+] Add export PATH="$HOME/.local/bin:$PATH" to your shell config if needed.'
poetry --version || true

echo "[✓] poetry setup completed successfully!"
