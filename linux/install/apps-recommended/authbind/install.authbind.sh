#!/usr/bin/env bash
# Description: Install and configure authbind
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Authbind to allow non-root users to bind to privileged network ports (< 1024).

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

echo "[+] Starting installation/setup for authbind..."

if [[ "$SKIP_UPDATE" != "true" ]]; then
    sudo apt-get update
fi
sudo apt-get install -y authbind

# Setup permissions for standard HTTP/HTTPS ports (80 & 443)
sudo touch /etc/authbind/byport/80 /etc/authbind/byport/443
sudo chmod 500 /etc/authbind/byport/80 /etc/authbind/byport/443
sudo chown "$USER" /etc/authbind/byport/80 /etc/authbind/byport/443
echo "[+] Configured authbind permissions for ports 80 and 443 for user $USER"

echo "[✓] authbind setup completed successfully!"
