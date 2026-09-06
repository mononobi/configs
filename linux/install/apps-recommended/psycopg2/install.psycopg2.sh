#!/usr/bin/env bash
# Description: Install and configure psycopg2
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs C development dependencies required for compiling psycopg2 and PostgreSQL drivers.

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

echo "[+] Starting installation/setup for psycopg2..."

sudo apt-get update
sudo apt-get install -y libpq-dev python3-dev build-essential

echo "[✓] psycopg2 setup completed successfully!"
