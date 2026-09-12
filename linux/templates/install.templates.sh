#!/usr/bin/env bash
# Description: Install file templates into user's Templates folder for right-click context menu
# Note: Copies template categories from files/ into ~/Templates. Completely idempotent.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
source "${SCRIPT_DIR}/../install/utils.sh"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Copies document and text template folders from the files/ directory into
  the user's Templates folder (~/Templates) to populate the desktop file manager
  right-click context menu ("New Document").

  Completely idempotent and safe to run repeatedly.

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
    echo "    Templates are installed per-user in your personal ~/Templates directory." >&2
    echo "    Please run as your regular user: ./$(basename "$0")" >&2
    exit 1
fi

echo "================================================================================"
echo " Installing Desktop File Templates"
echo "================================================================================"

FILES_DIR="${SCRIPT_DIR}/files"
if [[ ! -d "$FILES_DIR" ]]; then
    echo "[!] Error: files directory not found at ${FILES_DIR}" >&2
    exit 1
fi

# Detect user's Templates folder via xdg-user-dir if available
TEMPLATES_DIR=""
if command -v xdg-user-dir >/dev/null 2>&1; then
    TEMPLATES_DIR="$(xdg-user-dir TEMPLATES 2>/dev/null || true)"
fi
TEMPLATES_DIR="${TEMPLATES_DIR:-${HOME}/Templates}"

echo "[+] Target Templates directory: ${TEMPLATES_DIR}"
mkdir -p "$TEMPLATES_DIR"

shopt -s nullglob
template_items=("${FILES_DIR}"/*)
shopt -u nullglob

if [[ ${#template_items[@]} -eq 0 ]]; then
    echo "[!] No template files or folders found in ${FILES_DIR}"
    exit 0
fi

echo "[+] Copying template categories into ${TEMPLATES_DIR}..."
copied_count=0

for src in "${template_items[@]}"; do
    item_name="$(basename "$src")"
    cp -rf "$src" "$TEMPLATES_DIR/"
    chmod -R u+rwX,go+rX "${TEMPLATES_DIR}/${item_name}"
    echo "  [✓] Installed: ${item_name}"
    copied_count=$((copied_count + 1))
done

echo ""
echo "================================================================================"
echo "[✓] Successfully installed ${copied_count} template category/categories into ${TEMPLATES_DIR}!"
echo "================================================================================"
