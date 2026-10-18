#!/usr/bin/env bash
# Description: Install and configure Bitwarden
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE="${SKIP_UPDATE:-false}"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Bitwarden Desktop client via Flatpak, initializes ~/.bitwarden
  configuration template, and links lock, unlock, and copy helpers into ~/.local/bin.

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

setup_symlinks() {
    symlink_to_local_bin "$SCRIPT_DIR/bitwarden-unlock"
    symlink_to_local_bin "$SCRIPT_DIR/bitwarden-lock"
    symlink_to_local_bin "$SCRIPT_DIR/bitwarden-copy"
}

setup_bitwarden_info() {
    local target_dir="${HOME}/.bitwarden"
    local target_file="${target_dir}/bitwarden-info"
    local gpg_file="${target_dir}/bitwarden-info.gpg"

    if [[ -f "$target_file" || -f "$gpg_file" ]]; then
        echo "[i] Bitwarden info or encrypted vault already exists in ${target_dir}, skipping template copy."
        return 0
    fi

    if [[ ! -d "$target_dir" ]]; then
        mkdir -p "$target_dir"
    fi

    if [[ ! -w "$target_dir" ]]; then
        sudo cp "${SCRIPT_DIR}/bitwarden-info" "$target_file"
        sudo chown "$(id -u):$(id -g)" "$target_file"
        sudo chmod 600 "$target_file"
    else
        cp "${SCRIPT_DIR}/bitwarden-info" "$target_file"
        chmod 600 "$target_file"
    fi
    echo "[+] Copied bitwarden-info template to ${target_file}"
}

if is_installed "com.bitwarden.desktop" --type flatpak --name "Bitwarden"; then
    setup_bitwarden_info
    setup_symlinks
    exit 0
fi

echo "[+] Starting installation/setup for Bitwarden..."

# 1. Install Bitwarden Desktop via Flatpak
require_app "flatpak"

echo "[+] Installing Bitwarden Desktop from Flathub..."
flatpak install -y flathub com.bitwarden.desktop

# 2. Setup bitwarden-info template if not present
setup_bitwarden_info

# 3. Setup bitwarden-lock and bitwarden-unlock helper scripts
setup_symlinks

echo "[✓] Bitwarden setup completed successfully!"
