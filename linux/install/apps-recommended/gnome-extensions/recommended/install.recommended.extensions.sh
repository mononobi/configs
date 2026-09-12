#!/usr/bin/env bash
# Description: Install and configure all recommended GNOME extensions and enable system extensions
# Note: Orchestrates dedicated installer scripts for each recommended extension. Completely idempotent.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
source "${SCRIPT_DIR}/../../../utils.sh"

SKIP_UPDATE=false
INSTALL_ADD_TO_DESKTOP=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs and enables recommended GNOME Shell extensions listed in the
  recommended/ guidelines directory:
    - User Themes (Shell Theme Changer)
    - Bluetooth Quick Connect
    - Color Picker
    - Steal My Focus Window (Disable Window Ready)
    - GSConnect
    - Nothing to Say (Mic Mute/Unmute Toggle)
    - Quick Settings Tweaker
    - Removable Drive Menu
    - Weather O'Clock (requires gnome-weather)
    - Disconnect WiFi
    - WiFi QR Code
    - Add to Desktop (optional via --add-to-desktop)
    - System Extensions (DING, Ubuntu Dock, System Monitor, AppIndicators, Tiling Assistant)

  Completely idempotent and safe to run repeatedly.

Options:
  --add-to-desktop   Install and enable 'Add to Desktop' extension (omitted by default)
  --no-update        Skip apt update before installing system packages
  -h, --help         Show this help message and exit
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
    echo "    GNOME extensions must be installed and configured in your personal user session." >&2
    echo "    Please run as your regular user: ./$(basename "$0")" >&2
    exit 1
fi

echo "================================================================================"
echo " Installing and Configuring Recommended GNOME Extensions"
echo "================================================================================"

pass_args=()
if [[ "$SKIP_UPDATE" == "true" ]]; then
    pass_args+=("--no-update")
fi

run_installer() {
    local script_name="$1"
    local script_path="${SCRIPT_DIR}/${script_name}"
    if [[ -x "$script_path" ]]; then
        echo ""
        "$script_path" "${pass_args[@]}"
    else
        echo "[!] Error: Extension script ${script_name} not found or not executable" >&2
        return 1
    fi
}

# 1. Custom Recommended Extensions
run_installer "install.shell.theme.changer.sh"
run_installer "install.bluetooth.selector.sh"
run_installer "install.color.picker.sh"
run_installer "install.disable.window.ready.sh"
run_installer "install.gsconnect.sh"
run_installer "install.mic.mute.unmute.toggle.sh"
run_installer "install.quick.settings.tweak.sh"
run_installer "install.removable.drive.menu.sh"
run_installer "install.weather.in.panel.sh"
run_installer "install.wifi.disconnect.sh"
run_installer "install.wifi.qr.code.sh"

if [[ "$INSTALL_ADD_TO_DESKTOP" == "true" ]]; then
    run_installer "install.add.to.desktop.sh"
else
    echo ""
    echo "[i] Skipping 'Add to Desktop' extension (enable with --add-to-desktop flag)"
fi

# 2. Enable and Configure System Extensions
run_installer "enable.system.extensions.sh"

echo ""
echo "================================================================================"
echo "[✓] All recommended GNOME extensions processed successfully!"
echo "================================================================================"
