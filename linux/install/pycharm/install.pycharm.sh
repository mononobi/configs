#!/usr/bin/env bash
# Description: Install and configure JetBrains Toolbox (PyCharm)
# Note: Modernized for Ubuntu with best practices (no snap dependency).

set -euo pipefail

DOWNLOAD_URL=""

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [DOWNLOAD_URL]

Description:
  Installs JetBrains Toolbox App (recommended method to manage, install, and update PyCharm and JetBrains IDEs).
  Automatically retrieves the latest release URL if not provided.

Arguments:
  DOWNLOAD_URL          Optional direct URL to JetBrains Toolbox .tar.gz archive

Options:
  -u, --url URL         Specify direct download URL for JetBrains Toolbox (.tar.gz)
  -h, --help            Show this help message and exit

Examples:
  $(basename "$0")
  $(basename "$0") -u https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.5.2.35332.tar.gz
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -u|--url)
            DOWNLOAD_URL="$2"
            shift 2
            ;;
        http*)
            DOWNLOAD_URL="$1"
            shift
            ;;
        *)
            echo "Unknown option or argument: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

echo "[+] Starting installation/setup for PyCharm (JetBrains Toolbox)..."

sudo apt-get update
sudo apt-get install -y curl tar ca-certificates
sudo apt-get install -y libfuse2 || sudo apt-get install -y libfuse2t64 || true

# If URL is not provided, try to fetch automatically
if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "[+] Fetching latest JetBrains Toolbox download link from JetBrains API..."
    DOWNLOAD_URL=$(curl -fsSL "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release" | grep -Po ""linux":\{"link":"\K[^"]*" || true)
fi

# If still not found, prompt if interactive
if [[ -z "$DOWNLOAD_URL" ]]; then
    if [[ -t 0 ]]; then
        read -r -p "[?] Could not automatically find download URL. Please enter JetBrains Toolbox .tar.gz URL: " DOWNLOAD_URL
    fi
fi

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "[!] Error: JetBrains Toolbox download URL could not be resolved."
    echo "[!] Please obtain the .tar.gz URL from https://www.jetbrains.com/toolbox-app/ and run:"
    echo "    $(basename "$0") --url <URL>"
    exit 1
fi

TEMP_DIR=$(mktemp -d)
trap "rm -rf "$TEMP_DIR"" EXIT

echo "[+] Downloading JetBrains Toolbox from: $DOWNLOAD_URL..."
curl -fsSL "$DOWNLOAD_URL" -o "$TEMP_DIR/toolbox.tar.gz"

echo "[+] Extracting archive..."
tar -xzf "$TEMP_DIR/toolbox.tar.gz" -C "$TEMP_DIR"

TOOLBOX_BIN=$(find "$TEMP_DIR" -maxdepth 2 -type f -name "jetbrains-toolbox" | head -n 1)

if [[ -z "$TOOLBOX_BIN" ]]; then
    echo "[!] Error: jetbrains-toolbox executable not found in downloaded archive."
    exit 1
fi

mkdir -p "$HOME/.local/bin"
install -m 755 "$TOOLBOX_BIN" "$HOME/.local/bin/jetbrains-toolbox"

echo "[+] JetBrains Toolbox successfully installed to $HOME/.local/bin/jetbrains-toolbox"
echo "[+] Launching JetBrains Toolbox in background to initialize..."
nohup "$HOME/.local/bin/jetbrains-toolbox" >/dev/null 2>&1 &

echo "[✓] PyCharm / JetBrains Toolbox setup completed successfully!"
