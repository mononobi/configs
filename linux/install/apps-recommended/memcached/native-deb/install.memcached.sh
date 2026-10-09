#!/usr/bin/env bash
# Description: Install and configure memcached
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../../utils.sh"
SKIP_UPDATE="${SKIP_UPDATE:-false}"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Memcached in-memory caching server and command line tools.

Options:
  --no-update   Skip apt update before installation
  -f, --force   Force reinstallation even if already installed
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
        -f|--force)
            FORCE=true
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
    if [[ -f "${SCRIPT_DIR}/memcached-reload" ]]; then
        ensure_local_bin_in_path
        chmod +x "${SCRIPT_DIR}/memcached-reload"
        ln -sf "${SCRIPT_DIR}/memcached-reload" "${HOME}/.local/bin/memcached-reload"
        echo "[+] Linked memcached-reload helper into ${HOME}/.local/bin/memcached-reload"
    fi
}

if is_installed "memcached" --name "Memcached"; then
    setup_symlinks
    exit 0
fi

echo "[+] Starting installation/setup for memcached..."

conditional_apt_update
sudo apt-get install -y memcached libmemcached-tools
sudo systemctl enable --now memcached

setup_symlinks

echo "[✓] memcached setup completed successfully!"
