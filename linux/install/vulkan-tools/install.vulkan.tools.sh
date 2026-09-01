#!/usr/bin/env bash
# Description: Install and configure vulkan-tools
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Vulkan diagnostics and validation utilities (vulkaninfo, vkcube) via APT.

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

echo "[+] Starting installation/setup for vulkan-tools..."

sudo apt-get update
sudo apt-get install -y vulkan-tools vulkan-validationlayers libvulkan1

echo "[✓] vulkan-tools setup completed successfully!"
