#!/usr/bin/env bash
# Description: Install and configure appimage
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs AppImage integration helper (appimaged / Gear Lever / libfuse) to automatically manage and create desktop shortcuts for AppImages.

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

echo "[+] Starting installation/setup for appimage..."

# Ensure FUSE support is installed for AppImage compatibility
sudo apt-get update
sudo apt-get install -y libfuse2 || sudo apt-get install -y libfuse2t64 || true

# Install Gear Lever via Flatpak or appimaged for automatic desktop integration
if command -v flatpak >/dev/null 2>&1; then
    echo "[+] Installing Gear Lever via Flatpak for AppImage desktop integration and management..."
    flatpak install -y flathub it.mijorus.gearlever || true
fi

echo "[+] AppImage environment is prepared. Move your .AppImage files to ~/Applications or use Gear Lever to integrate them."

echo "[✓] appimage setup completed successfully!"
