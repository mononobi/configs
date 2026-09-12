#!/usr/bin/env bash
# Description: Configure UFW firewall rules for server
# Note: Completely idempotent. Can be run standalone or invoked from batch runners.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Configures UFW (Uncomplicated Firewall) rules for a server:
    - Default incoming: deny
    - Default outgoing: allow
    - SSH (port 22 / OpenSSH): allow
    - HTTP (port 80): allow
    - HTTPS (port 443): allow
    - OpenVPN TCP (port 443/tcp): allow
    - OpenVPN UDP (port 1194/udp): allow

  Completely idempotent and safe to run multiple times.

Options:
  --no-update   Skip apt update when verifying dependencies
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
            echo "[!] Unknown option: $1" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
    esac
done

echo "================================================================================"
echo " Configuring UFW Rules for Server"
echo "================================================================================"

# Ensure ufw is installed
if ! command -v ufw >/dev/null 2>&1; then
    echo "[+] ufw is not installed. Resolving ufw dependency..."
    update_flag=()
    [[ "$SKIP_UPDATE" == "true" ]] && update_flag=("--no-update")
    require_app "ufw" "apps-recommended" "${update_flag[@]}"
fi

# deny all incoming connections which don't match any specific rule:
echo "[+] Setting default incoming policy to deny..."
sudo ufw default deny incoming

# allow all outgoing connections which don't match any specific rule:
echo "[+] Setting default outgoing policy to allow..."
sudo ufw default allow outgoing

# allow incoming ssh connection to server (both are the same):
echo "[+] Allowing SSH (OpenSSH / port 22)..."
sudo ufw allow OpenSSH
sudo ufw allow 22

# allow incoming connections to http port (both are the same):
echo "[+] Allowing HTTP (port 80)..."
sudo ufw allow http
sudo ufw allow 80

# allow incoming connections to https port (both are the same):
echo "[+] Allowing HTTPS (port 443)..."
sudo ufw allow https
sudo ufw allow 443

# allow incoming connections to openvpn default tcp port:
echo "[+] Allowing OpenVPN TCP (port 443/tcp)..."
sudo ufw allow 443/tcp

# allow incoming connections to openvpn default udp port:
echo "[+] Allowing OpenVPN UDP (port 1194/udp)..."
sudo ufw allow 1194/udp

# Ensure firewall is enabled
echo "[+] Enabling UFW..."
sudo ufw --force enable

echo ""
echo "================================================================================"
echo " UFW Status"
echo "================================================================================"
sudo ufw status verbose

echo ""
echo "[✓] UFW server rules configured successfully!"
