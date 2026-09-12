#!/usr/bin/env bash
# Description: Install GNOME Shell Extensions activator/manager and all recommended extensions
# Note: Orchestrates both activator/install.activator.sh and recommended/install.recommended.extensions.sh. Completely idempotent.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE=false
INSTALL_ADD_TO_DESKTOP=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs both the GNOME Shell Extensions Activator (Extension Manager,
  gnome-shell-extensions, browser connector, and version check bypass)
  and installs/configures recommended extensions from the recommended/ directory.

  Completely idempotent and safe to run repeatedly.

Options:
  --add-to-desktop  Install and enable 'Add to Desktop' extension (omitted by default)
  --no-update       Skip apt update before installation
  -h, --help        Show this help message and exit
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
        --add-to-desktop|--with-add-to-desktop|--include-add-to-desktop)
            INSTALL_ADD_TO_DESKTOP=true
            shift
            ;;
        *)
            echo "[!] Unknown option: $1" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
    esac
done

# Prevent running via sudo to preserve user's HOME and gsettings
if [[ -n "${SUDO_USER:-}" && $EUID -eq 0 ]]; then
    echo "[!] Error: Do not run $(basename "$0") with sudo." >&2
    echo "    GNOME extensions must be installed in your personal user session." >&2
    echo "    Please run as your regular user: ./$(basename "$0")" >&2
    exit 1
fi

echo "================================================================================"
echo " Starting Full GNOME Shell Extensions Setup"
echo "================================================================================"

# 1. Run Activator Setup
echo "[+] Step 1: Installing GNOME Shell Extensions Activator..."
if [[ -x "${SCRIPT_DIR}/activator/install.activator.sh" ]]; then
    "${SCRIPT_DIR}/activator/install.activator.sh" ${SKIP_UPDATE:+--no-update}
else
    echo "[!] Error: Activator script not found at ${SCRIPT_DIR}/activator/install.activator.sh" >&2
    exit 1
fi

# 2. Run Recommended Extensions Setup
echo ""
echo "[+] Step 2: Installing and configuring recommended GNOME extensions..."
if [[ -x "${SCRIPT_DIR}/recommended/install.recommended.extensions.sh" ]]; then
    rec_args=()
    if [[ "$SKIP_UPDATE" == "true" ]]; then
        rec_args+=("--no-update")
    fi
    if [[ "$INSTALL_ADD_TO_DESKTOP" == "true" ]]; then
        rec_args+=("--add-to-desktop")
    fi
    "${SCRIPT_DIR}/recommended/install.recommended.extensions.sh" "${rec_args[@]}"
else
    echo "[!] Error: Recommended extensions script not found at ${SCRIPT_DIR}/recommended/install.recommended.extensions.sh" >&2
    exit 1
fi

echo ""
echo "================================================================================"
echo "[✓] Full GNOME Shell Extensions setup completed successfully!"
echo "================================================================================"
