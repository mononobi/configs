#!/usr/bin/env bash
# Description: Install Neofetch system info tool
# Note: Neofetch is archived/discontinued. Fastfetch is the modern successor.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Neofetch CLI system information tool via APT.
  Note: Neofetch is officially archived; consider using fastfetch.

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

echo "[+] Starting installation for Neofetch..."

sudo apt-get update
sudo apt-get install -y neofetch

echo "[✓] Neofetch installation completed successfully!"
