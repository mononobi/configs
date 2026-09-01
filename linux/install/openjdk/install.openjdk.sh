#!/usr/bin/env bash
# Description: Install and configure openjdk
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs OpenJDK Java Development Kit via APT (defaults to LTS JDK 21 / 17).

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

echo "[+] Starting installation/setup for openjdk..."

sudo apt-get update
# Install default OpenJDK or LTS version
sudo apt-get install -y default-jdk || sudo apt-get install -y openjdk-21-jdk || sudo apt-get install -y openjdk-17-jdk
java -version

echo "[✓] openjdk setup completed successfully!"
