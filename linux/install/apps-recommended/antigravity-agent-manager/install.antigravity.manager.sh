#!/usr/bin/env bash
# Description: Install and configure Antigravity Agent Manager (Antigravity v2)
# Note: Idempotent and safe to run multiple times.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

FILES_DIR="${SCRIPT_DIR}/files"
DESKTOP_SRC="${FILES_DIR}/antigravity.desktop"
ICON_SRC="${FILES_DIR}/antigravity.png"

INSTALL_DIR="${HOME}/.antigravity-manager"
APP_DIR="${HOME}/.local/share/applications"
ICON_DIR="${HOME}/.local/share/icons/hicolor/512x512/apps"
DEST_DESKTOP="${APP_DIR}/antigravity.desktop"
DEST_ICON="${ICON_DIR}/antigravity.png"

FORCE=false
DOWNLOAD_URL=""
CUSTOM_URL=false
SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [DOWNLOAD_URL]

Description:
  Installs Antigravity Agent Manager (Antigravity v2).
  If DOWNLOAD_URL is omitted, the latest stable release is automatically detected.
  If already installed at the latest version, skips re-downloading.

Arguments:
  DOWNLOAD_URL          Optional direct URL to the Antigravity tarball (.tar.gz).
                        Default: auto-detects from the official auto-updater service.

Options:
  -u, --url <URL>       Specify direct download URL for Antigravity .tar.gz
  -F, --force           Force re-download and re-installation even if up to date
  --no-update           Skip apt update before installation
  -h, --help            Show this help message and exit
EOF
}

# Parse command line options and arguments
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
            CUSTOM_URL=true
            shift 2
            ;;
        -*)
            echo "Unknown option: $1" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
        *)
            if [[ -n "$DOWNLOAD_URL" ]]; then
                echo "Error: Only a single download URL argument is accepted." >&2
                exit 1
            fi
            DOWNLOAD_URL="$1"
            CUSTOM_URL=true
            shift
            ;;
    esac
done

# Require shared dependencies
require_app curl python tar

get_installed_version() {
    local version_file="${INSTALL_DIR}/.version"
    if [[ -f "$version_file" ]]; then
        cat "$version_file" | tr -d '[:space:]'
        return 0
    fi

    local asar_file="${INSTALL_DIR}/Antigravity-x64/resources/app.asar"
    if [[ -f "$asar_file" ]]; then
        python3 -c "
import struct, json, sys
try:
    with open(sys.argv[1], 'rb') as f:
        f.seek(4)
        header_size = struct.unpack('<I', f.read(4))[0]
        f.seek(16)
        header_bytes = f.read(header_size - 8)
        header = json.loads(header_bytes.decode('utf-8'))
        pkg_info = header.get('files', {}).get('package.json', {})
        if 'offset' in pkg_info and 'size' in pkg_info:
            f.seek(16 + header_size - 8 + int(pkg_info['offset']))
            pkg = json.loads(f.read(pkg_info['size']).decode('utf-8'))
            print(pkg.get('version', ''))
except Exception:
    pass
" "$asar_file" 2>/dev/null || true
    fi
}

# Auto-detect latest Antigravity v2 release if not provided manually
LATEST_VERSION=""
if [[ "$CUSTOM_URL" != "true" ]]; then
    echo "[+] Auto-detecting latest Antigravity v2 release..."
    MANIFEST_URL="https://antigravity-hub-auto-updater-974169037036.us-central1.run.app/manifest/latest-x64-linux.yml"
    MANIFEST_DATA=$(curl -fsSL "$MANIFEST_URL" 2>/dev/null || true)
    LATEST_VERSION=$(echo "$MANIFEST_DATA" | grep -Po '^version:\s*\K[0-9.]+' | head -n 1 || true)
    BASE_URL=$(echo "$MANIFEST_DATA" | grep -Po 'https://[^\s]+/linux-x64/' | head -n 1 || true)
    if [[ -n "$BASE_URL" ]]; then
        DOWNLOAD_URL="${BASE_URL}Antigravity.tar.gz"
    fi

    CURRENT_VERSION=$(get_installed_version)
    if [[ "$FORCE" != "true" && -n "$CURRENT_VERSION" && -n "$LATEST_VERSION" && "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
        if [[ -x "${INSTALL_DIR}/Antigravity-x64/antigravity" && -f "$DEST_DESKTOP" ]]; then
            echo "[i] Antigravity Agent Manager is already installed and up to date (v${CURRENT_VERSION}), skipping..."
            exit 0
        fi
    fi
fi

# If auto-detection fails and still not set, ask user interactively
if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "[!] Could not auto-detect download URL from official update service."
    read -r -p "[?] Please enter direct download URL for Antigravity (.tar.gz): " DOWNLOAD_URL
fi

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "[!] Error: Missing required download URL." >&2
    exit 1
fi

echo "[+] Starting installation/setup for Antigravity Agent Manager..."

# Step 1: Download tarball
TEMP_DIR="$(mktemp -d)"
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT
TEMP_TARBALL="${TEMP_DIR}/Antigravity.tar.gz"

echo "[+] Downloading Antigravity package..."
curl -fSL "$DOWNLOAD_URL" -o "$TEMP_TARBALL"

# Step 2: Create installation directory
echo "[+] Extracting archive to ${INSTALL_DIR}..."
mkdir -p "$INSTALL_DIR"
tar -xzf "$TEMP_TARBALL" -C "$INSTALL_DIR"

# Step 3: Set required permissions and ownership on chrome-sandbox
CHROME_SANDBOX="${INSTALL_DIR}/Antigravity-x64/chrome-sandbox"
echo "[+] Configuring chrome-sandbox permissions..."
sudo chown root:root "$CHROME_SANDBOX"
sudo chmod 4755 "$CHROME_SANDBOX"

# Step 4: Configure desktop launcher and application icon
echo "[+] Configuring desktop application launcher and icon..."
mkdir -p "$APP_DIR" "$ICON_DIR"
cp "$ICON_SRC" "$DEST_ICON"

sed -e "s|/home/USER_NAME|${HOME}|g" "$DESKTOP_SRC" > "$DEST_DESKTOP"
chmod +x "$DEST_DESKTOP"

# Step 5: Record installed version and refresh desktop databases
if [[ -n "$LATEST_VERSION" ]]; then
    echo "$LATEST_VERSION" > "${INSTALL_DIR}/.version"
else
    INSTALLED_VER=$(get_installed_version)
    [[ -n "$INSTALLED_VER" ]] && echo "$INSTALLED_VER" > "${INSTALL_DIR}/.version"
fi

update-desktop-database "$APP_DIR" 2>/dev/null || true
gtk-update-icon-cache -f -t "${HOME}/.local/share/icons/hicolor" 2>/dev/null || true

echo "[✓] Antigravity Agent Manager successfully installed!"
