#!/usr/bin/env bash
# Description: Install and configure XDM (Xtreme Download Manager)
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

DOWNLOAD_URL="https://github.com/subhra74/xdm/releases/download/7.2.11/xdm-setup-7.2.11.tar.xz"

SKIP_UPDATE="${SKIP_UPDATE:-false}"
FORCE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Downloads and installs XDM (Xtreme Download Manager 7.2.11).

Options:
  -F, --force        Force reinstallation even if already installed
  --no-update        Skip apt update before installation
  -h, --help         Show this help message and exit
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
        -F|--force)
            FORCE=true
            shift
            ;;
        -u|--url)
            DOWNLOAD_URL="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
    esac
done

is_installed "xdman" --name "XDM" && exit 0

echo "[+] Starting installation/setup for XDM (Xtreme Download Manager)..."

require_app curl tar xz-utils ca-certificates

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "[+] Downloading XDM from $DOWNLOAD_URL..."
curl -fsSL "$DOWNLOAD_URL" -o "$TEMP_DIR/xdm.tar.xz"
tar -xf "$TEMP_DIR/xdm.tar.xz" -C "$TEMP_DIR"

SETUP_SH=$(find "$TEMP_DIR" -type f -name "install.sh" | head -n 1)
if [[ -n "$SETUP_SH" && -f "$SETUP_SH" ]]; then
    chmod +x "$SETUP_SH"
    echo "[+] Running XDM installer..."
    sudo bash "$SETUP_SH"

    # XDM's installer archive contains a 'usr/' folder packaged as UID 1000 and extracts directly
    # to '/', which resets /usr and its extracted subdirectories to UID 1000.
    # Restore root ownership on /usr and its top-level subdirectories, and remove leftover file.
    sudo chown root:root /usr /usr/lib /usr/bin /usr/share 2>/dev/null || true
    sudo rm -f /install-script.sh
else
    echo "[!] Error: 'install.sh' not found in downloaded XDM archive." >&2
    exit 1
fi

# Wrap OpenJ9 Java binary so ALL invocations (manual launch, CLI, autostart on boot, or native messaging)
# redirect the shared class cache to ~/.cache/xdman instead of ~/javasharedresources
JRE_BIN="/opt/xdman/jre/bin"
if [[ -d "$JRE_BIN" ]]; then
    echo "[+] Configuring OpenJ9 Java binary wrapper for cache relocation..."
    if [[ -f "${JRE_BIN}/java" && ! -f "${JRE_BIN}/java.bin" ]]; then
        sudo mv "${JRE_BIN}/java" "${JRE_BIN}/java.bin"
    elif [[ -f "${JRE_BIN}/java" ]] && file "${JRE_BIN}/java" | grep -q "ELF"; then
        sudo mv -f "${JRE_BIN}/java" "${JRE_BIN}/java.bin"
    fi

    sudo tee "${JRE_BIN}/java" > /dev/null << 'EOF'
#!/usr/bin/env bash
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/xdman"
mkdir -p "$CACHE_DIR" 2>/dev/null || true
exec "$(dirname "$0")/java.bin" -Xshareclasses:cacheDir="$CACHE_DIR" "$@"
EOF
    sudo chmod 755 "${JRE_BIN}/java"
    sudo chown root:root "${JRE_BIN}/java"
fi

# Ensure /opt/xdman/xdman forwards arguments and /usr/bin/xdman links to it
if [[ -f "/opt/xdman/xdman" ]]; then
    if ! grep -q '\$@' /opt/xdman/xdman; then
        sudo sed -i 's|/opt/xdman/xdman.jar|/opt/xdman/xdman.jar "$@"|g' /opt/xdman/xdman
    fi
    sudo ln -sf /opt/xdman/xdman /usr/bin/xdman
fi

# Ensure cache directory exists and purge legacy directory
mkdir -p "${HOME}/.cache/xdman"
rm -rf "${HOME}/javasharedresources"

echo "[✓] XDM (Xtreme Download Manager) setup completed successfully!"
