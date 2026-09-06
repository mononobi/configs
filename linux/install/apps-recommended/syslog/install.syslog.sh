#!/usr/bin/env bash
# Description: Install and configure syslog
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs syslog-ng enhanced system logging daemon via APT.

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

echo "[+] Starting installation/setup for syslog..."

sudo apt-get update
sudo apt-get install -y syslog-ng-core
sudo systemctl enable --now syslog-ng

echo "[✓] syslog setup completed successfully!"
