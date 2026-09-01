#!/usr/bin/env bash
# Description: Install Fastfetch system info tool
# Note: Fastfetch is the modern, high-performance C-based successor to Neofetch.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Fastfetch CLI system information tool via APT.

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

echo "[+] Starting installation for Fastfetch..."

sudo apt-get update
if apt-cache show fastfetch >/dev/null 2>&1; then
    sudo apt-get install -y fastfetch
else
    echo "[+] Fastfetch not in base repositories (Ubuntu <= 22.04). Adding official PPA..."
    sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
    sudo apt-get update
    sudo apt-get install -y fastfetch
fi

echo "[✓] Fastfetch installation completed successfully!"
