#!/usr/bin/env bash
# Description: Install and configure all recommended GNOME extensions and enable system extensions
# Note: Implements all guideline files in recommended/. Completely idempotent.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
source "${SCRIPT_DIR}/../../../utils.sh"

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs and enables all recommended GNOME Shell extensions listed in the
  recommended/ guidelines directory:
    - User Themes (Shell Theme Changer)
    - Add to Desktop
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
    - System Extensions (DING, Ubuntu Dock, System Monitor, AppIndicators, Tiling Assistant)

  Completely idempotent and safe to run repeatedly.

Options:
  --no-update   Skip apt update before installing system packages
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

# 1. Require third-party application dependencies
echo "[+] Ensuring application dependencies are installed via require_app..."
if [[ "$SKIP_UPDATE" == "true" ]]; then
    require_app "curl" "apps-recommended" --no-update
    require_app "python" "apps-recommended" --no-update
    require_app "gnome-weather" "apps-recommended" --no-update
    require_app "gnome-system-monitor" "apps-recommended" --no-update
    require_app "unzip" "apps-recommended" --no-update
else
    require_app "curl" "apps-recommended"
    require_app "python" "apps-recommended"
    require_app "gnome-weather" "apps-recommended"
    require_app "gnome-system-monitor" "apps-recommended"
    require_app "unzip" "apps-recommended"
fi

# Ensure extension version validation is disabled so all extensions load cleanly
gsettings set org.gnome.shell disable-extension-version-validation true 2>/dev/null || true

# 2. Extension installer function via extensions.gnome.org API
install_gnome_extension() {
    local uuid="$1"
    local name="${2:-$uuid}"

    echo "[+] Processing: ${name} (${uuid})..."

    local user_ext_dir="${HOME}/.local/share/gnome-shell/extensions/${uuid}"
    local sys_ext_dir="/usr/share/gnome-shell/extensions/${uuid}"

    if [[ -d "$user_ext_dir" || -d "$sys_ext_dir" ]]; then
        echo "    [✓] Already installed. Ensuring enabled..."
        gnome-extensions enable "${uuid}" 2>/dev/null || true
        return 0
    fi

    local shell_ver
    shell_ver="$(gnome-shell --version 2>/dev/null | awk '{print $3}' | cut -d. -f1)"
    shell_ver="${shell_ver:-46}"

    echo "    Querying extensions.gnome.org for GNOME ${shell_ver} bundle..."
    local download_url
    download_url="$(python3 -c "
import urllib.request, json, sys

uuid = sys.argv[1]
shell_ver = sys.argv[2]
url = f'https://extensions.gnome.org/extension-info/?uuid={uuid}&shell_version={shell_ver}'
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req, timeout=10) as resp:
        data = json.loads(resp.read().decode())
        print('https://extensions.gnome.org' + data['download_url'])
except Exception:
    try:
        url_fallback = f'https://extensions.gnome.org/extension-info/?uuid={uuid}'
        req_fallback = urllib.request.Request(url_fallback, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req_fallback, timeout=10) as resp2:
            data2 = json.loads(resp2.read().decode())
            print('https://extensions.gnome.org' + data2['download_url'])
    except Exception:
        pass
" "$uuid" "$shell_ver" 2>/dev/null || true)"

    if [[ -z "$download_url" ]]; then
        echo "    [!] Warning: Could not resolve download URL for ${uuid}" >&2
        return 1
    fi

    local tmp_zip
    tmp_zip="$(mktemp --suffix=.zip)"
    if curl -fsSL "$download_url" -o "$tmp_zip" 2>/dev/null; then
        if command -v gnome-extensions >/dev/null 2>&1; then
            gnome-extensions install -f "$tmp_zip" 2>/dev/null || {
                mkdir -p "$user_ext_dir"
                unzip -q -o "$tmp_zip" -d "$user_ext_dir"
            }
        else
            mkdir -p "$user_ext_dir"
            unzip -q -o "$tmp_zip" -d "$user_ext_dir"
        fi
        rm -f "$tmp_zip"

        if [[ -d "${user_ext_dir}/schemas" ]]; then
            glib-compile-schemas "${user_ext_dir}/schemas" 2>/dev/null || true
        fi

        gnome-extensions enable "${uuid}" 2>/dev/null || true
        echo "    [✓] Successfully installed and enabled: ${name}"
        return 0
    else
        rm -f "$tmp_zip"
        echo "    [!] Error: Failed to download extension zip for ${uuid}" >&2
        return 1
    fi
}

# 3. Install/Enable all recommended extensions
echo ""
echo "--- Installing Recommended Custom Extensions ---"
install_gnome_extension "user-theme@gnome-shell-extensions.gcampax.github.com" "User Themes (Shell Theme Changer)"
install_gnome_extension "add-to-desktop@tommimon.github.com" "Add to Desktop"
install_gnome_extension "bluetooth-quick-connect@bjarosze.gmail.com" "Bluetooth Quick Connect"
install_gnome_extension "color-picker@tuberry" "Color Picker"
install_gnome_extension "steal-my-focus-window@steal-my-focus-window" "Steal My Focus Window (Disable Window Ready)"
install_gnome_extension "gsconnect@andyholmes.github.io" "GSConnect"
install_gnome_extension "nothing-to-say@extensions.gnome.wouter.bolsterl.ee" "Nothing to Say (Mic Mute Toggle)"
install_gnome_extension "quick-settings-tweaks@qwreey" "Quick Settings Tweaker"
install_gnome_extension "drive-menu@gnome-shell-extensions.gcampax.github.com" "Removable Drive Menu"
install_gnome_extension "weatheroclock@CleoMenezesJr.github.io" "Weather O'Clock"
install_gnome_extension "disconnect-wifi@kgshank.net" "Disconnect WiFi"
install_gnome_extension "wifiqrcode@glerro.pm.me" "WiFi QR Code"

# 4. Enable and Configure System Extensions (enable.system.extensions.txt)
echo ""
echo "--- Enabling and Configuring System Extensions ---"
for sys_ext in \
    "ding@rastersoft.com" \
    "system-monitor@gnome-shell-extensions.gcampax.github.com" \
    "ubuntu-dock@ubuntu.com" \
    "ubuntu-appindicators@ubuntu.com" \
    "tiling-assistant@ubuntu.com"; do
    echo "[+] Enabling system extension: ${sys_ext}..."
    gnome-extensions enable "$sys_ext" 2>/dev/null || true
done

# Configure Desktop Icons NG (DING)
echo "[+] Applying Desktop Icons NG (DING) settings..."
if gsettings list-schemas | grep -q "org.gnome.shell.extensions.ding"; then
    gsettings set org.gnome.shell.extensions.ding icon-size 'small'
    gsettings set org.gnome.shell.extensions.ding show-home false
    gsettings set org.gnome.shell.extensions.ding show-trash true
    gsettings set org.gnome.shell.extensions.ding show-volumes false
    gsettings set org.gnome.shell.extensions.ding show-network-volumes false
    gsettings set org.gnome.shell.extensions.ding start-corner 'top-left'
fi

# Configure Ubuntu Dock
echo "[+] Applying Ubuntu Dock settings..."
if gsettings list-schemas | grep -q "org.gnome.shell.extensions.dash-to-dock"; then
    gsettings set org.gnome.shell.extensions.dash-to-dock multi-monitor true
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 40
    gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
    gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'focus-or-previews'
fi

# Configure Bluetooth Quick Connect preferences
echo "[+] Applying Bluetooth Quick Connect settings..."
dconf write /org/gnome/shell/extensions/bluetooth-quick-connect/keep-menu-on-toggle true 2>/dev/null || true
dconf write /org/gnome/shell/extensions/bluetooth-quick-connect/show-battery-value-on true 2>/dev/null || true
dconf write /org/gnome/shell/extensions/bluetooth-quick-connect/show-battery-icon-on true 2>/dev/null || true

# Configure System Monitor extension (Uncheck Swap)
echo "[+] Applying System Monitor settings..."
dconf write /org/gnome/shell/extensions/system-monitor/show-swap false 2>/dev/null || true

echo ""
echo "================================================================================"
echo "[✓] All recommended GNOME extensions installed and configured successfully!"
echo "================================================================================"
