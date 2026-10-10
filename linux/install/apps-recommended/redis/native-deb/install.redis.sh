#!/usr/bin/env bash
# Description: Install and configure redis
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../../utils.sh"
SKIP_UPDATE="${SKIP_UPDATE:-false}"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Redis in-memory data store server via APT.

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
    symlink_to_local_bin "${SCRIPT_DIR}/redis-reload"
}

if is_installed "redis-server" --name "Redis"; then
    setup_symlinks
    exit 0
fi

echo "[+] Starting installation/setup for redis..."

conditional_apt_update
sudo apt-get install -y redis-server
sudo systemctl enable --now redis-server

setup_symlinks

echo "[✓] redis setup completed successfully!"
