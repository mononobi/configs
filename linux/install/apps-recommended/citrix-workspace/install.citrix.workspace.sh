#!/usr/bin/env bash
# Description: Install and configure citrix-workspace
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Citrix Workspace App (ICA Client) deb package and links Mozilla SSL certificates.

Options:
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
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

echo "[+] Starting installation/setup for citrix-workspace..."

sudo apt-get update
sudo apt-get install -y libmotif-common ca-certificates libjpeg62

# If user provided a .deb package path or it exists in current folder:
DEB_FILE="${1:-}"
if [[ -z "$DEB_FILE" ]]; then
    DEB_FILE=$(ls icaclient_*.deb 2>/dev/null | head -n 1 || true)
fi

if [[ -n "$DEB_FILE" && -f "$DEB_FILE" ]]; then
    echo "[+] Installing $DEB_FILE..."
    sudo apt-get install -y "$DEB_FILE"
else
    echo "[!] No icaclient .deb package specified or found in current directory."
    echo "[!] Please download the Citrix Workspace app .deb from Citrix website and run:"
    echo "    sudo apt-get install -y ./icaclient_<version>_amd64.deb"
fi

# Link Mozilla Root Certificates to Citrix keystore
if [[ -d /opt/Citrix/ICAClient/keystore/cacerts ]]; then
    echo "[+] Linking Mozilla SSL certificates to Citrix ICAClient keystore..."
    sudo ln -sf /usr/share/ca-certificates/mozilla/* /opt/Citrix/ICAClient/keystore/cacerts/
    sudo c_rehash /opt/Citrix/ICAClient/keystore/cacerts/ 2>/dev/null || true
fi

echo "[✓] citrix-workspace setup completed successfully!"
