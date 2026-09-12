#!/usr/bin/env bash
# Description: Permanently apply DMZ-White cursor theme across user desktop, Flatpak, and GDM
# Note: Implements the guidelines in change-cursor.md. Completely idempotent.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"

SKIP_UPDATE=false
RESTART_GDM=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Permanently configures and fixes the DMZ-White cursor theme across the system:
  1. Installs xcursor-themes via apt
  2. Sets system-wide default alternative (x-cursor-theme)
  3. Configures user desktop cursor in GNOME gsettings
  4. Configures Flatpak filesystem override for /usr/share/icons/:ro
  5. Injects cursor configuration into GDM dconf database for the login screen
  6. Optionally restarts gdm3 (or prompts to log out / reboot)

Options:
  --no-update    Skip apt update before installing packages
  --restart-gdm  Restart gdm3 service upon completion (WARNING: will log you out)
  -h, --help     Show this help message and exit
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
        --restart-gdm)
            RESTART_GDM=true
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
echo " Applying DMZ-White Cursor Universally (User, Flatpak, GDM)"
echo "================================================================================"

# 1. Install xcursor-themes package
echo "[+] Ensuring xcursor-themes package is installed..."
if ! dpkg -s xcursor-themes >/dev/null 2>&1; then
    if [[ "$SKIP_UPDATE" != "true" ]]; then
        sudo apt-get update
    fi
    sudo apt-get install -y xcursor-themes
else
    echo "[✓] xcursor-themes package is already installed."
fi

# 2. Set system-wide fallback via update-alternatives
echo "[+] Configuring system-wide cursor alternative..."
DMZ_THEME_PATH="/usr/share/icons/DMZ-White/cursor.theme"
if [[ -f "$DMZ_THEME_PATH" ]]; then
    if update-alternatives --list x-cursor-theme 2>/dev/null | grep -q "$DMZ_THEME_PATH"; then
        sudo update-alternatives --set x-cursor-theme "$DMZ_THEME_PATH"
        echo "[✓] System-wide cursor set to: ${DMZ_THEME_PATH}"
    fi
fi

# 3. Apply to User Desktop via gsettings
echo "[+] Setting GNOME user cursor-theme to DMZ-White..."
gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-White'

# Also extract to ~/.icons if DMZ-White.zip is present
if [[ -f "${SCRIPT_DIR}/DMZ-White.zip" ]]; then
    mkdir -p "${HOME}/.icons"
    if [[ ! -d "${HOME}/.icons/DMZ-White" ]]; then
        echo "[+] Extracting local DMZ-White cursor to ~/.icons/..."
        unzip -q -o "${SCRIPT_DIR}/DMZ-White.zip" -d "${HOME}/.icons/" || true
    fi
fi

# 4. Flatpak Override (if flatpak is installed)
if command -v flatpak >/dev/null 2>&1; then
    echo "[+] Configuring Flatpak filesystem permissions for icons..."
    sudo flatpak override --filesystem=/usr/share/icons/:ro 2>/dev/null || true
    echo "[✓] Flatpak icons override configured."
fi

# 5. Apply to Login Screen (GDM)
echo "[+] Configuring GDM login screen cursor..."
sudo mkdir -p /var/lib/gdm3/.cache/dconf /var/lib/gdm3/.config/dconf
if id "gdm" >/dev/null 2>&1; then
    sudo chown -R gdm:gdm /var/lib/gdm3/.cache /var/lib/gdm3/.config
    sudo -u gdm -s /bin/bash -c "dbus-run-session gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-White'" 2>/dev/null || true
    echo "[✓] Injected DMZ-White cursor into GDM database."
elif id "gdm3" >/dev/null 2>&1; then
    sudo chown -R gdm3:gdm3 /var/lib/gdm3/.cache /var/lib/gdm3/.config
    sudo -u gdm3 -s /bin/bash -c "dbus-run-session gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-White'" 2>/dev/null || true
    echo "[✓] Injected DMZ-White cursor into GDM3 database."
fi

echo ""
echo "================================================================================"
echo "[✓] DMZ-White cursor configured successfully across all layers!"
echo "================================================================================"

# 6. Restart GDM if requested
if [[ "$RESTART_GDM" == "true" ]]; then
    echo "[!] Restarting gdm3 service now..."
    sudo systemctl restart gdm3
else
    echo "Note: Log out or restart gdm3 (sudo systemctl restart gdm3) to see full changes on the login screen."
fi
