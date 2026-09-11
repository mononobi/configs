#!/usr/bin/env bash
# Description: Install and configure ExpressVPN OpenVPN profiles and scripts
# Note: Sets up ~/.expressvpn/{profiles,keys}, installs CLI helper scripts to ~/.local/bin,
#       ensures PATH, and imports profiles automatically with credentials.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
source "${SCRIPT_DIR}/../../../install/utils.sh"

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs ExpressVPN OpenVPN profiles and keys to ~/.expressvpn, installs
  the openvpn-add and openvpn-bulk-add helper commands into ~/.local/bin,
  and imports all profiles automatically into NetworkManager.

  Interactive input is only requested for your VPN username and password.

Options:
  --no-update   Skip apt update when checking dependencies
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

# Prevent running via sudo to preserve user's HOME
if [[ -n "${SUDO_USER:-}" && $EUID -eq 0 ]]; then
    echo "[!] Error: Do not run $(basename "$0") with sudo." >&2
    echo "    VPN profiles and scripts are configured under your user account." >&2
    echo "    Please run as your regular user: ./$(basename "$0")" >&2
    exit 1
fi

echo "================================================================================"
echo " ExpressVPN OpenVPN Setup & Profile Importer"
echo "================================================================================"

# 1. Ensure ~/.local/bin is present and in PATH
echo "[+] Ensuring ~/.local/bin is configured in PATH..."
ensure_local_bin_in_path

# 2. Check OpenVPN dependency via utils.sh
echo "[+] Checking OpenVPN and NetworkManager OpenVPN plugin..."
if ! command -v openvpn >/dev/null 2>&1 || ! dpkg -l network-manager-openvpn-gnome >/dev/null 2>&1; then
    echo "[!] OpenVPN dependency missing. Installing via utils.sh..."
    require_app "openvpn" "apps-recommended"
else
    echo "[✓] OpenVPN packages are installed."
fi

# 3. Create required directories
EXPRESS_DIR="${HOME}/.expressvpn"
PROFILES_DIR="${EXPRESS_DIR}/profiles"
KEYS_DIR="${EXPRESS_DIR}/keys"
BIN_DIR="${HOME}/.local/bin"

echo "[+] Creating ExpressVPN directories..."
mkdir -p "$PROFILES_DIR"
mkdir -p "$KEYS_DIR"

# 4. Copy profiles and keys
FILES_DIR="${SCRIPT_DIR}/files"
echo "[+] Copying profile and key files..."
cp "${FILES_DIR}/profiles/"*.ovpn "$PROFILES_DIR/"
cp "${FILES_DIR}/keys/"* "$KEYS_DIR/"

# 5. Install scripts into ~/.local/bin
SCRIPTS_DIR="${SCRIPT_DIR}/scripts"
echo "[+] Installing CLI helper scripts into ${BIN_DIR}..."
cp "${SCRIPTS_DIR}/openvpn-add" "$BIN_DIR/"
cp "${SCRIPTS_DIR}/openvpn-bulk-add" "$BIN_DIR/"
chmod +x "${BIN_DIR}/openvpn-add" "${BIN_DIR}/openvpn-bulk-add"

# 6. Prompt for VPN Credentials (only interactive input)
echo ""
echo "--------------------------------------------------------------------------------"
echo " Please enter your ExpressVPN credentials"
echo " (From https://portal.expressvpn.com/setup#manual)"
echo "--------------------------------------------------------------------------------"
VPN_USER=""
VPN_PASS=""

while [[ -z "$VPN_USER" ]]; do
    read -p "  👤  Enter VPN Username: " VPN_USER
done

while [[ -z "$VPN_PASS" ]]; do
    read -s -p "  🔑  Enter VPN Password: " VPN_PASS
    echo ""
done

# 7. Execute bulk add with auto-naming
echo ""
echo "[+] Importing profiles into NetworkManager..."
"${BIN_DIR}/openvpn-bulk-add" -a -u "$VPN_USER" -p "$VPN_PASS" -d "$PROFILES_DIR"

echo ""
echo "================================================================================"
echo "[✓] ExpressVPN setup and profile import completed successfully!"
echo "================================================================================"
