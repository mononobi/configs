#!/usr/bin/env bash
# Description: Configure UFW firewall rules for local / private network
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
  Configures UFW (Uncomplicated Firewall) rules for local/private network:
    - Default incoming: deny
    - Default outgoing: allow
    - Incoming from local network (LAN): allow (192.168.0.0/16)
    - Incoming from private network (Docker, tun, etc.): allow (172.16.0.0/12)
    - Incoming from private network (tun, etc.): allow (10.0.0.0/8)

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
echo " Configuring UFW Rules for Local / Private Network"
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

# allow incoming connections from local network (LAN):
echo "[+] Allowing incoming connections from local network (192.168.0.0/16)..."
sudo ufw allow from 192.168.0.0/16

# allow incoming connections from private network (ex. docker, tun and ...):
# note that only ips from 172.16.0.0 to 172.31.255.255 are private and because of
# that we should set subnet to /12 to only include this range of ips.
echo "[+] Allowing incoming connections from private network (172.16.0.0/12)..."
sudo ufw allow from 172.16.0.0/12

# allow incoming connections from private network (ex. tun and ...)
echo "[+] Allowing incoming connections from private network (10.0.0.0/8)..."
sudo ufw allow from 10.0.0.0/8

# Ensure firewall is enabled
echo "[+] Enabling UFW..."
sudo ufw --force enable

echo ""
echo "================================================================================"
echo " UFW Status"
echo "================================================================================"
sudo ufw status verbose

echo ""
echo "[✓] UFW local rules configured successfully!"
