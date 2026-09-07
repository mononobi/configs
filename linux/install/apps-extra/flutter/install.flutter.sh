#!/usr/bin/env bash
# Description: Install and configure Flutter SDK & Dependencies
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Flutter SDK prerequisites (clang, cmake, ninja, GTK) and sets up Flutter SDK directory.

Options:
  --no-update   Skip apt update before installation
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
        --no-update|--skip-update)
            SKIP_UPDATE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

echo "[+] Starting installation/setup for Flutter SDK & Dependencies..."

if [[ "$SKIP_UPDATE" != "true" ]]; then
    sudo apt-get update
fi
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev libstdc++-12-dev

INSTALL_DIR="$HOME/.flutter-sdk/flutter"
if [[ ! -d "$INSTALL_DIR" ]]; then
    mkdir -p "$HOME/.flutter-sdk"
    echo "[+] Cloning Flutter SDK stable branch to $INSTALL_DIR..."
    git clone https://github.com/flutter/flutter.git -b stable "$INSTALL_DIR"
else
    echo "[+] Flutter already exists in $INSTALL_DIR. Upgrading..."
    git -C "$INSTALL_DIR" pull || true
fi

# Set PATH in ~/.bashrc if not present
if ! grep -q '\.flutter-sdk/flutter/bin' "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$PATH:$HOME/.flutter-sdk/flutter/bin"' >> "$HOME/.bashrc"
    echo "[+] Added Flutter to PATH in ~/.bashrc"
fi

export PATH="$PATH:$HOME/.flutter-sdk/flutter/bin"
flutter precache || true
flutter doctor -v || true

echo "[✓] Flutter SDK & Dependencies setup completed successfully!"
