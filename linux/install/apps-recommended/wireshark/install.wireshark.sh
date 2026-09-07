#!/usr/bin/env bash
# Description: Install and configure wireshark
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Wireshark network packet analyzer via APT and configures non-root packet capture permissions.

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

echo "[+] Starting installation/setup for wireshark..."

if [[ "$SKIP_UPDATE" != "true" ]]; then
    sudo apt-get update
fi
# Preconfigure wireshark non-superuser capture
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections || true
sudo apt-get install -y wireshark
sudo usermod -aG wireshark "$USER"
echo "[+] Wireshark installed. User $USER added to wireshark group (log out and back in to capture without root)."

echo "[✓] wireshark setup completed successfully!"
