#!/usr/bin/env bash
# Description: Copy user's monitor configuration to GDM user for login screen persistence
# Note: Implements Section 4 of linux/wayland/toggle.wayland.md. Completely idempotent.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Copies the current user's monitor configuration (~/.config/monitors.xml)
  to the GDM display manager configuration directory (~gdm/.config/monitors.xml)
  and sets ownership to gdm:gdm, ensuring display arrangement, primary monitor,
  and resolution settings persist on the GDM login screen.

  Implements Section 4 of linux/wayland/toggle.wayland.md.
  Completely idempotent and safe to run multiple times.

Options:
  --no-update   Ignored (no APT dependencies required)
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
echo " Copy Monitor Configuration for GDM User"
echo "================================================================================"

# 1. Determine real calling user and their home directory
if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
    REAL_USER="$SUDO_USER"
    USER_HOME="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
else
    REAL_USER="${USER:-$(id -un)}"
    USER_HOME="${HOME:-$(getent passwd "$REAL_USER" | cut -d: -f6)}"
fi

USER_MONITORS="${USER_HOME}/.config/monitors.xml"
echo "[+] User: ${REAL_USER}"
echo "[+] Source monitor configuration: ${USER_MONITORS}"

if [[ ! -f "$USER_MONITORS" ]]; then
    echo "[!] Error: Monitor configuration file not found at: ${USER_MONITORS}" >&2
    echo "    Please configure your displays in Settings -> Displays, click Apply," >&2
    echo "    and run this script again." >&2
    exit 1
fi

# 2. Locate GDM user and home directory
GDM_USER="gdm"
if ! id "$GDM_USER" >/dev/null 2>&1; then
    if id "gdm3" >/dev/null 2>&1; then
        GDM_USER="gdm3"
    else
        echo "[!] Error: Neither 'gdm' nor 'gdm3' user found on this system." >&2
        exit 1
    fi
fi

GDM_HOME="$(getent passwd "$GDM_USER" | cut -d: -f6)"
if [[ -z "$GDM_HOME" || ! -d "$GDM_HOME" ]]; then
    echo "[!] Error: GDM home directory not found for user '${GDM_USER}'." >&2
    exit 1
fi

GDM_CONFIG_DIR="${GDM_HOME}/.config"
GDM_MONITORS="${GDM_CONFIG_DIR}/monitors.xml"
echo "[+] GDM user: ${GDM_USER} (${GDM_HOME})"
echo "[+] Destination monitor configuration: ${GDM_MONITORS}"

# 3. Use sudo if not already root
if [[ $EUID -ne 0 ]]; then
    SUDO="sudo"
else
    SUDO=""
fi

# 4. Copy monitor configuration and set ownership
echo "[+] Ensuring GDM config directory exists..."
$SUDO mkdir -p "${GDM_CONFIG_DIR}"
$SUDO chmod 755 "${GDM_CONFIG_DIR}"
$SUDO chown "${GDM_USER}:${GDM_USER}" "${GDM_CONFIG_DIR}"

echo "[+] Copying monitors.xml to GDM configuration..."
$SUDO cp -f "$USER_MONITORS" "$GDM_MONITORS"
$SUDO chown "${GDM_USER}:${GDM_USER}" "$GDM_MONITORS"
$SUDO chmod 644 "$GDM_MONITORS"

echo ""
echo "================================================================================"
echo "[✓] Successfully copied monitor configuration to GDM user (${GDM_MONITORS})!"
echo "    Display layout will now persist on the GDM login screen."
echo "================================================================================"
