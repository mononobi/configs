#!/usr/bin/env bash
# Description: Install custom desktop application icons into ~/.local/share/icons
# Note: Copies icon files from files/ into ~/.local/share/icons. Completely idempotent.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
source "${SCRIPT_DIR}/../install/utils.sh"

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Copies custom desktop application icons from the files/ directory into
  ~/.local/share/icons. Completely idempotent and safe to run repeatedly.

Options:
  --no-update   Ignored (no APT dependencies required)
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
    echo "    Icons are installed per-user in ~/.local/share/icons." >&2
    echo "    Please run as your regular user: ./$(basename "$0")" >&2
    exit 1
fi

echo "================================================================================"
echo " Installing Custom Application Icons"
echo "================================================================================"

FILES_DIR="${SCRIPT_DIR}/files"
if [[ ! -d "$FILES_DIR" ]]; then
    echo "[!] Error: files directory not found at ${FILES_DIR}" >&2
    exit 1
fi

shopt -s nullglob
icon_files=("${FILES_DIR}"/*)
shopt -u nullglob

if [[ ${#icon_files[@]} -eq 0 ]]; then
    echo "[!] No icon files found in ${FILES_DIR}"
    exit 0
fi

TARGET_DIR="${HOME}/.local/share/icons"
echo "[+] Target icons directory: ${TARGET_DIR}"
mkdir -p "$TARGET_DIR"

echo "[+] Copying icon files into ${TARGET_DIR}..."
copied_count=0

for src in "${icon_files[@]}"; do
    fname="$(basename "$src")"
    cp -f -r "$src" "$TARGET_DIR/"
    if [[ -f "${TARGET_DIR}/${fname}" ]]; then
        chmod 644 "${TARGET_DIR}/${fname}"
    fi
    echo "  [✓] Installed: ${fname}"
    copied_count=$((copied_count + 1))
done

# Optional: Refresh GTK icon cache if hicolor exists
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    if [[ -d "${TARGET_DIR}/hicolor" ]]; then
        gtk-update-icon-cache -q -f -t "${TARGET_DIR}/hicolor" 2>/dev/null || true
    fi
fi

echo ""
echo "================================================================================"
echo "[✓] Successfully installed ${copied_count} icon(s) into ${TARGET_DIR}!"
echo "================================================================================"
