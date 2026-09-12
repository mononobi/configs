#!/usr/bin/env bash
# Description: Install custom fonts into ~/.fonts
# Note: Extracts fonts from fonts.zip into ~/.fonts and updates the font cache. Completely idempotent.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
source "${SCRIPT_DIR}/../install/utils.sh"

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Extracts custom fonts from fonts.zip into ~/.fonts and refreshes
  the user font cache. Safe and idempotent to run multiple times.

Options:
  --no-update   Skip apt update when installing dependencies
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
            echo "[!] Unknown option: $1" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
    esac
done

# Prevent running via sudo to preserve user's HOME
if [[ -n "${SUDO_USER:-}" && $EUID -eq 0 ]]; then
    echo "[!] Error: Do not run $(basename "$0") with sudo." >&2
    echo "    Fonts are installed per-user in ~/.fonts." >&2
    echo "    Please run as your regular user: ./$(basename "$0")" >&2
    exit 1
fi

echo "================================================================================"
echo " Installing Custom User Fonts"
echo "================================================================================"

# 1. Ensure required CLI tools (unzip and fontconfig)
if ! command -v unzip >/dev/null 2>&1; then
    echo "[+] Installing unzip dependency..."
    if [[ "$SKIP_UPDATE" != "true" ]]; then
        sudo apt-get update
    fi
    sudo apt-get install -y unzip
fi

if ! command -v fc-cache >/dev/null 2>&1; then
    echo "[+] Installing fontconfig dependency..."
    if [[ "$SKIP_UPDATE" != "true" ]]; then
        sudo apt-get update
    fi
    sudo apt-get install -y fontconfig
fi

# 2. Check source archive
ZIP_FILE="${SCRIPT_DIR}/fonts.zip"
if [[ ! -f "$ZIP_FILE" ]]; then
    echo "[!] Error: fonts archive not found at ${ZIP_FILE}" >&2
    exit 1
fi

# 3. Target directory
TARGET_DIR="${HOME}/.fonts"
echo "[+] Target font directory: ${TARGET_DIR}"
mkdir -p "$TARGET_DIR"

# 4. Extract fonts idempotently (junk paths to flatten directly into ~/.fonts)
echo "[+] Extracting fonts from ${ZIP_FILE}..."
unzip -j -o -q "$ZIP_FILE" -d "$TARGET_DIR"

# 5. Set proper file permissions
chmod 644 "${TARGET_DIR}"/*.* 2>/dev/null || true

# 6. Refresh font cache
echo "[+] Updating font cache..."
fc-cache -f "$TARGET_DIR"

font_count=$(find "$TARGET_DIR" -maxdepth 1 -type f \( -iname "*.ttf" -o -iname "*.otf" \) | wc -l)

echo ""
echo "================================================================================"
echo "[✓] Successfully installed and refreshed ${font_count} fonts in ${TARGET_DIR}!"
echo "================================================================================"
