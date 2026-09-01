#!/usr/bin/env bash
# Description: Install and configure ebcli
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs AWS Elastic Beanstalk Command Line Interface (awsebcli) via pip/pipx.

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

echo "[+] Starting installation/setup for ebcli..."

sudo apt-get update
sudo apt-get install -y python3-pip pipx python3-venv
pipx install awsebcli || pip3 install --user awsebcli

echo "[✓] ebcli setup completed successfully!"
