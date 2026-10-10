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
    symlink_to_local_bin "${SCRIPT_DIR}/memcached-reload"
}

if is_installed "memcached" --name "Memcached"; then
    setup_symlinks
    exit 0
fi

echo "[+] Starting installation/setup for memcached..."

conditional_apt_update
sudo apt-get install -y memcached libmemcached-tools

# Ensure memcached listens on all interfaces (access restricted to LAN & containers by UFW)
if [[ -f /etc/memcached.conf ]]; then
    sudo sed -i 's/^\s*-l\s\+127\.0\.0\.1/# -l 127.0.0.1/' /etc/memcached.conf
    sudo sed -i 's/^\s*-l\s\+::1/# -l ::1/' /etc/memcached.conf
fi

sudo systemctl enable --now memcached
sudo systemctl restart memcached

configure_ufw_lan_private_port 11211 "Memcached"
setup_symlinks

echo "[✓] memcached setup completed successfully!"
