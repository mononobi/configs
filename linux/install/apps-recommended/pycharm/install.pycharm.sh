#!/usr/bin/env bash
# Description: Install and configure JetBrains Toolbox (PyCharm)
# Note: Modernized for Ubuntu with best practices (no snap dependency).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

DOWNLOAD_URL=""

SKIP_UPDATE=false

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
  --no-update           Skip apt update before installation
  -h, --help            Show this help message and exit

Examples:
  $(basename "$0")
  $(basename "$0") -u https://download.jetbrains.com/toolbox/jetbrains-toolbox-3.7.2.87231.tar.gz
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

if [[ "$SKIP_UPDATE" != "true" ]]; then
    sudo apt-get update
fi
sudo apt-get install -y curl tar ca-certificates

# Configure inotify file watch limit for the IDE per guideline
echo "[+] Configuring inotify file watch limit for JetBrains IDEs..."
echo "fs.inotify.max_user_watches = 2097152" | sudo tee /etc/sysctl.d/idea.conf > /dev/null
sudo sysctl -p /etc/sysctl.d/idea.conf > /dev/null

# Detect system architecture for JetBrains API
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)          ARCH_KEY="linux" ;;
    aarch64|arm64)   ARCH_KEY="linuxARM64" ;;
    *)               ARCH_KEY="linux" ;;
esac

# If URL is not provided, try to fetch automatically
if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "[+] Fetching latest JetBrains Toolbox download link from JetBrains API (${ARCH_KEY})..."
    DOWNLOAD_URL=$(curl -fsSL "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release" 2>/dev/null | grep -Po '"'"${ARCH_KEY}"'":\{"link":"\K[^"]*' || true)
fi

# Fall back to interactive prompt if auto-detection failed
if [[ -z "$DOWNLOAD_URL" ]]; then
    if [[ -t 0 ]]; then
        echo "[!] Could not automatically find download URL from JetBrains API."
        read -r -p "[?] Please enter JetBrains Toolbox .tar.gz URL: " DOWNLOAD_URL
    fi
fi

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "[!] Error: No download URL provided." >&2
    exit 1
fi

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "[+] Downloading JetBrains Toolbox from: $DOWNLOAD_URL..."
curl -fsSL "$DOWNLOAD_URL" -o "$TEMP_DIR/toolbox.tar.gz"

echo "[+] Extracting archive..."
tar -xzf "$TEMP_DIR/toolbox.tar.gz" -C "$TEMP_DIR"

# Find jetbrains-toolbox executable anywhere in the extracted directory
TOOLBOX_BIN=$(find "$TEMP_DIR" -type f -name "jetbrains-toolbox" | head -n 1)

if [[ -z "$TOOLBOX_BIN" || ! -f "$TOOLBOX_BIN" ]]; then
    echo "[!] Error: jetbrains-toolbox executable not found in downloaded archive." >&2
    exit 1
fi

chmod +x "$TOOLBOX_BIN"

# Validate that the downloaded binary can execute
if ! "$TOOLBOX_BIN" --version >/dev/null 2>&1; then
    echo "[!] Error: Downloaded jetbrains-toolbox binary failed execution check." >&2
    exit 1
fi

TOOLBOX_DIR="$(dirname "$TOOLBOX_BIN")"
INSTALL_DIR="${HOME}/.local/share/JetBrains/Toolbox/bin"

echo "[+] Installing JetBrains Toolbox to ${INSTALL_DIR}..."
mkdir -p "$INSTALL_DIR"
cp -a --remove-destination "$TOOLBOX_DIR/." "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/jetbrains-toolbox"

# Ensure ~/.local/bin exists and is permanently added to PATH
ensure_local_bin_in_path

# Create CLI symlink in ~/.local/bin
ln -sf "$INSTALL_DIR/jetbrains-toolbox" "${HOME}/.local/bin/jetbrains-toolbox"
echo "[+] Created CLI symlink at ${HOME}/.local/bin/jetbrains-toolbox"

# Desktop integration
if [[ -f "$INSTALL_DIR/jetbrains-toolbox.desktop" ]]; then
    mkdir -p "${HOME}/.local/share/applications"
    sed "s|^Exec=.*|Exec=${INSTALL_DIR}/jetbrains-toolbox %u|" "$INSTALL_DIR/jetbrains-toolbox.desktop" > "${HOME}/.local/share/applications/jetbrains-toolbox.desktop"
    chmod 644 "${HOME}/.local/share/applications/jetbrains-toolbox.desktop"
fi

if [[ -f "$INSTALL_DIR/toolbox.svg" ]]; then
    mkdir -p "${HOME}/.local/share/icons/hicolor/scalable/apps"
    cp -f "$INSTALL_DIR/toolbox.svg" "${HOME}/.local/share/icons/hicolor/scalable/apps/jetbrains-toolbox.svg"
fi

# Launch in background if not already running
if ! pgrep -f "jetbrains-toolbox" >/dev/null 2>&1; then
    echo "[+] Launching JetBrains Toolbox in background to initialize..."
    nohup "$INSTALL_DIR/jetbrains-toolbox" >/dev/null 2>&1 &
else
    echo "[i] JetBrains Toolbox is already running."
fi

echo "[+] Verification:"
"${HOME}/.local/bin/jetbrains-toolbox" --version || true

echo "[✓] PyCharm / JetBrains Toolbox setup completed successfully!"
