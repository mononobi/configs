#!/usr/bin/env bash
# Description: Install and configure pip-setuptools
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Upgrades Python 3 pip, setuptools, and wheel packages.

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

echo "[+] Starting installation/setup for pip-setuptools..."

python3 -m pip install --upgrade pip setuptools wheel 2>/dev/null || python3 -m pip install --upgrade pip setuptools wheel --break-system-packages

echo "[✓] pip-setuptools setup completed successfully!"
