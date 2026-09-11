#!/usr/bin/env bash
# Description: Install custom command-line utilities into ~/.local/bin
# Note: Copies physical files (resolving symlinks) from files/ into ~/.local/bin and ensures PATH is configured.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Copies custom utility command scripts from the files/ directory into
  ~/.local/bin (dereferencing symlinks to install real files) and ensures
  ~/.local/bin is permanently configured in your PATH via utils.sh.

Options:
  --no-update   Ignored (no APT packages needed)
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
            # No APT packages needed for local commands
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
    echo "    Commands should be installed into your user's ~/.local/bin." >&2
    echo "    Please run as your regular user: ./$(basename "$0")" >&2
    exit 1
fi

echo "================================================================================"
echo " Installing Custom Command Utilities"
echo "================================================================================"

# 1. Ensure ~/.local/bin is created and in PATH
echo "[+] Ensuring ~/.local/bin is present and configured in PATH..."
ensure_local_bin_in_path

DEST_DIR="${HOME}/.local/bin"
FILES_DIR="${SCRIPT_DIR}/files"

if [[ ! -d "$FILES_DIR" ]]; then
    echo "[!] Error: files directory not found at ${FILES_DIR}" >&2
    exit 1
fi

shopt -s nullglob
file_entries=("${FILES_DIR}"/*)
shopt -u nullglob

if [[ ${#file_entries[@]} -eq 0 ]]; then
    echo "[!] No command files found in ${FILES_DIR}"
    exit 0
fi

echo "[+] Copying command files into ${DEST_DIR}..."
installed_count=0

for src in "${file_entries[@]}"; do
    cmd_name="$(basename "$src")"
    dest="${DEST_DIR}/${cmd_name}"

    # Resolve real file if symlink
    if [[ -L "$src" ]]; then
        real_file="$(readlink -f "$src")"
        if [[ ! -f "$real_file" ]]; then
            echo "[!] Warning: Symlink target for '${cmd_name}' not found (${real_file}), skipping." >&2
            continue
        fi
        cp "$real_file" "$dest"
    elif [[ -f "$src" ]]; then
        cp "$src" "$dest"
    else
        continue
    fi

    chmod +x "$dest"
    echo "  [✓] Installed: ${cmd_name}"
    installed_count=$((installed_count + 1))
done

echo ""
echo "================================================================================"
echo "[✓] Successfully installed ${installed_count} command(s) into ${DEST_DIR}!"
echo "================================================================================"
