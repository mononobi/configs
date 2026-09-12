#!/usr/bin/env bash
# Description: Fully automated installer and configurator for Orchis theme, Tela icons, DMZ cursor, and GNOME styling
# Note: Implements all steps and recommendations from favorite-current.md and cursor/change-cursor.md.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
source "${SCRIPT_DIR}/../utils.sh"

SYSTEM_TARGET=""
SKIP_UPDATE=false
RESTART_GDM=false
CLEAN_ONLY=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") -s <SYSTEM> [OPTIONS]

Description:
  Automates the complete installation, styling, and configuration of Orchis themes,
  Tela icons, DMZ-White cursor, and GNOME desktop settings according to favorite-current.md.

  Required Option:
    -s, --system <CHOICE>    Target system preset (Numbered or Name):
                               1 | pc       : PC (Non-floating panel, Blue accent, Orchis-Dark, Tela-dark)
                               2 | minipc   : Mini PC (Floating panel, Green accent, Orchis-Green-Dark, Tela-manjaro-dark)
                               3 | laptop   : Laptop (Floating panel, Red accent, Orchis-Grey-Dark, Tela-dracula-dark)

  Additional Options:
    --clean-only             Remove existing Orchis themes and Tela icons and exit
    --restart-gdm            Restart gdm3 service upon completion (WARNING: will log you out)
    --no-update              Skip apt update when installing dependencies
    -h, --help               Show this help message and exit
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -s|--system)
            if [[ -z "${2:-}" || "${2:-}" =~ ^- ]]; then
                echo "[!] Error: -s/--system requires a value (1|2|3 or pc|minipc|laptop)" >&2
                exit 1
            fi
            SYSTEM_TARGET="$2"
            shift 2
            ;;
        --system=*)
            SYSTEM_TARGET="${1#*=}"
            shift
            ;;
        --clean-only)
            CLEAN_ONLY=true
            shift
            ;;
        --restart-gdm)
            RESTART_GDM=true
            shift
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
    echo "    Desktop styling and gsettings must be applied in your user session." >&2
    echo "    The script will invoke sudo internally when root privileges are required." >&2
    echo "    Please run as your regular user: ./$(basename "$0") [OPTIONS]" >&2
    exit 1
fi

clean_installed_themes_and_icons() {
    echo "[+] Cleaning previously installed Orchis themes and Tela icons..."
    rm -rf "${HOME}/.themes/Orchis"*
    sudo rm -rf /usr/share/themes/Orchis*
    rm -rf "${HOME}/.icons/Tela"*
    sudo rm -rf /usr/share/icons/Tela*
    echo "[✓] Cleanup complete."
}

if [[ "$CLEAN_ONLY" == "true" ]]; then
    clean_installed_themes_and_icons
    exit 0
fi

# If system target is not specified via flag, prompt interactively if running in a terminal
if [[ -z "$SYSTEM_TARGET" ]]; then
    if [[ -t 0 ]]; then
        echo "================================================================================"
        echo " System Target Selection (Required)"
        echo "================================================================================"
        echo "Please select your target system configuration:"
        echo "  1) PC       (Non-floating panel, Blue accent, Orchis-Dark, Tela-dark, Abstract Blur)"
        echo "  2) Mini PC  (Floating panel, Green accent, Orchis-Green-Dark, Tela-manjaro-dark, Tony Webster Blur)"
        echo "  3) Laptop   (Floating panel, Red accent, Orchis-Grey-Dark, Tela-dracula-dark, Abstract Blur)"
        echo ""
        read -r -p "Enter choice [1-3 or name]: " user_choice
        SYSTEM_TARGET="$user_choice"
    fi
fi

# Normalize SYSTEM_TARGET
case "${SYSTEM_TARGET,,}" in
    1|pc)
        SYSTEM_TARGET="pc"
        SYSTEM_NAME="PC (Desktop)"
        PANEL_MODE="non-floating"
        BASE_ACCENT="Yaru-blue-dark"
        THEME_NAME="Orchis-Dark"
        ICON_NAME="Tela-dark"
        LOGIN_BG_IMG="abstract-blur.jpg"
        ;;
    2|minipc|"mini-pc"|"mini pc")
        SYSTEM_TARGET="minipc"
        SYSTEM_NAME="Mini PC"
        PANEL_MODE="floating"
        BASE_ACCENT="Yaru-viridian-dark"
        THEME_NAME="Orchis-Green-Dark"
        ICON_NAME="Tela-manjaro-dark"
        LOGIN_BG_IMG="tony-webster-blur.jpg"
        ;;
    3|laptop)
        SYSTEM_TARGET="laptop"
        SYSTEM_NAME="Laptop"
        PANEL_MODE="floating"
        BASE_ACCENT="Yaru-red-dark"
        THEME_NAME="Orchis-Grey-Dark"
        ICON_NAME="Tela-dracula-dark"
        LOGIN_BG_IMG="abstract-blur.jpg"
        ;;
    *)
        echo "[!] Error: Invalid or missing system target: '${SYSTEM_TARGET}'" >&2
        echo "" >&2
        echo "Please provide a valid system target using -s or --system:" >&2
        echo "  1 or pc      : PC" >&2
        echo "  2 or minipc  : Mini PC" >&2
        echo "  3 or laptop  : Laptop" >&2
        exit 1
        ;;
esac

echo "================================================================================"
echo " Starting Linux Theme & Icon Styling"
echo " Target System:   ${SYSTEM_NAME}"
echo " Top Panel Mode:  ${PANEL_MODE}"
echo " Base Accent:     ${BASE_ACCENT}"
echo " Orchis Theme:    ${THEME_NAME}"
echo " Tela Icons:      ${ICON_NAME}"
echo " Login Wallpaper: ${LOGIN_BG_IMG}"
echo "================================================================================"

# Initialize sudo early
echo "[+] Requesting sudo access for system-wide installation..."
sudo -v

# Keep sudo timestamp alive in background
sudo_keepalive_pid=""
cleanup() {
    if [[ -n "$sudo_keepalive_pid" ]]; then
        kill "$sudo_keepalive_pid" 2>/dev/null || true
    fi
}
trap cleanup EXIT INT TERM

while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" 2>/dev/null || exit
done < /dev/null > /dev/null 2>&1 &
sudo_keepalive_pid=$!

# Ensure required applications are installed via require_app
echo "[+] Ensuring application dependencies (git, gnome-extensions) are installed..."
if [[ "$SKIP_UPDATE" == "true" ]]; then
    require_app "git" "apps-recommended" --no-update
    require_app "gnome-extensions" "apps-recommended" --no-update
else
    require_app "git" "apps-recommended"
    require_app "gnome-extensions" "apps-recommended"
fi

# -----------------------------------------------------------------------------
# Clean previous installations
# -----------------------------------------------------------------------------
clean_installed_themes_and_icons

# -----------------------------------------------------------------------------
# Step 1: Set Ubuntu Base Style to Dark and Accent Color
# -----------------------------------------------------------------------------
echo "[+] Step 1: Setting Ubuntu base style to Dark and base accent color (${BASE_ACCENT})..."
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
if [[ -d "/usr/share/themes/${BASE_ACCENT}" ]]; then
    gsettings set org.gnome.desktop.interface gtk-theme "${BASE_ACCENT}"
fi
if [[ -d "/usr/share/icons/${BASE_ACCENT}" ]]; then
    gsettings set org.gnome.desktop.interface icon-theme "${BASE_ACCENT}"
fi

# -----------------------------------------------------------------------------
# Step 2: Create Required Folders
# -----------------------------------------------------------------------------
echo "[+] Step 2: Creating required directories..."
mkdir -p "${HOME}/.icons"
mkdir -p "${HOME}/.themes"
mkdir -p "${HOME}/Workspace/linux-styling/themes"
mkdir -p "${HOME}/Workspace/linux-styling/icons"

# -----------------------------------------------------------------------------
# Step 3: Clone/Update and Install Orchis Theme
# -----------------------------------------------------------------------------
echo "[+] Step 3: Installing Orchis theme (${PANEL_MODE} top panel)..."
ORCHIS_DIR="${HOME}/Workspace/linux-styling/themes/Orchis-theme"
if [[ -d "${ORCHIS_DIR}/.git" ]]; then
    echo "    Updating existing Orchis git repository..."
    git -C "$ORCHIS_DIR" pull --ff-only || true
else
    echo "    Cloning Orchis-theme repository..."
    git clone https://github.com/vinceliuice/Orchis-theme.git "$ORCHIS_DIR"
fi

cd "$ORCHIS_DIR"
if [[ "$PANEL_MODE" == "non-floating" ]]; then
    ./install.sh -t all --tweaks submenu --tweaks compact
else
    ./install.sh -t all --tweaks submenu
fi

# -----------------------------------------------------------------------------
# Step 4: Clone/Update and Install Tela Icon Theme
# -----------------------------------------------------------------------------
echo "[+] Step 4: Installing Tela icon theme..."
TELA_DIR="${HOME}/Workspace/linux-styling/icons/Tela-icon-theme"
if [[ -d "${TELA_DIR}/.git" ]]; then
    echo "    Updating existing Tela-icon-theme git repository..."
    git -C "$TELA_DIR" pull --ff-only || true
else
    echo "    Cloning Tela-icon-theme repository..."
    git clone https://github.com/vinceliuice/Tela-icon-theme.git "$TELA_DIR"
fi

cd "$TELA_DIR"
./install.sh -a -d "${HOME}/.icons"

# -----------------------------------------------------------------------------
# Step 5: Copy Themes and Icons to /usr/share/ for Login Screen Availability
# -----------------------------------------------------------------------------
echo "[+] Step 5: Copying themes and icons to system directory (/usr/share/)..."
sudo cp -rf "${HOME}/.themes/Orchis"* /usr/share/themes/
sudo cp -rf "${HOME}/.icons/Tela"* /usr/share/icons/

# -----------------------------------------------------------------------------
# Run Universal DMZ-White Cursor Fix
# -----------------------------------------------------------------------------
echo "[+] Fixing cursor universally across desktop, Flatpak, and GDM..."
if [[ -x "${SCRIPT_DIR}/cursor/change.cursor.sh" ]]; then
    "${SCRIPT_DIR}/cursor/change.cursor.sh" ${SKIP_UPDATE:+--no-update}
fi

# -----------------------------------------------------------------------------
# Step 6: Apply User Desktop Styling via gsettings (Tweaks equivalents)
# -----------------------------------------------------------------------------
echo "[+] Step 6: Applying user desktop themes and icons..."
gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-White'
gsettings set org.gnome.desktop.interface icon-theme "${ICON_NAME}"
gsettings set org.gnome.desktop.interface gtk-theme "${THEME_NAME}"
gnome-extensions enable "user-theme@gnome-shell-extensions.gcampax.github.com" 2>/dev/null || true
if gsettings list-schemas | grep -q "org.gnome.shell.extensions.user-theme"; then
    gsettings set org.gnome.shell.extensions.user-theme name "${THEME_NAME}"
fi

# -----------------------------------------------------------------------------
# Step 7: Apply GDM Login Screen Styling
# -----------------------------------------------------------------------------
echo "[+] Step 7: Applying GDM login screen themes and icons..."
GDM_USER="gdm"
if ! id "$GDM_USER" >/dev/null 2>&1 && id "gdm3" >/dev/null 2>&1; then
    GDM_USER="gdm3"
fi

if id "$GDM_USER" >/dev/null 2>&1; then
    sudo -u "$GDM_USER" -s /bin/bash -c "dbus-run-session gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-White'" 2>/dev/null || true
    sudo -u "$GDM_USER" -s /bin/bash -c "dbus-run-session gsettings set org.gnome.desktop.interface icon-theme '${ICON_NAME}'" 2>/dev/null || true
    sudo -u "$GDM_USER" -s /bin/bash -c "dbus-run-session gsettings set org.gnome.desktop.interface gtk-theme '${THEME_NAME}'" 2>/dev/null || true
    sudo -u "$GDM_USER" -s /bin/bash -c "dbus-run-session gsettings set org.gnome.shell.extensions.user-theme name '${THEME_NAME}'" 2>/dev/null || true
fi

# -----------------------------------------------------------------------------
# Configure Login Screen Background Image
# -----------------------------------------------------------------------------
BG_SOURCE="${SCRIPT_DIR}/login-background/images/${LOGIN_BG_IMG}"
if [[ -f "$BG_SOURCE" ]]; then
    echo "[+] Installing GDM login background image (${LOGIN_BG_IMG})..."
    sudo mkdir -p /usr/share/backgrounds
    sudo cp -f "$BG_SOURCE" "/usr/share/backgrounds/${LOGIN_BG_IMG}"
    sudo chmod 644 "/usr/share/backgrounds/${LOGIN_BG_IMG}"

    if gsettings list-schemas | grep -q "io.github.realmazharhussain.GdmSettings.appearance"; then
        gsettings set io.github.realmazharhussain.GdmSettings.appearance background-type 'image'
        gsettings set io.github.realmazharhussain.GdmSettings.appearance background-image "/usr/share/backgrounds/${LOGIN_BG_IMG}"
        gsettings set io.github.realmazharhussain.GdmSettings.appearance bg-adjustment 'zoom'
        gsettings set io.github.realmazharhussain.GdmSettings.appearance shell-theme "${THEME_NAME}"
        gsettings set io.github.realmazharhussain.GdmSettings.appearance icon-theme "${ICON_NAME}"
        gsettings set io.github.realmazharhussain.GdmSettings.appearance cursor-theme 'DMZ-White'
        echo "[✓] Configured GdmSettings appearance schema."
    fi
fi

# -----------------------------------------------------------------------------
# Configure File Explorer Icon Size (Medium = 3 out of 5)
# -----------------------------------------------------------------------------
echo "[+] Configuring Nautilus File Explorer icon zoom level to medium (3 of 5)..."
if gsettings list-schemas | grep -q "org.gnome.nautilus.icon-view"; then
    gsettings set org.gnome.nautilus.icon-view default-zoom-level 'medium'
fi

# -----------------------------------------------------------------------------
# Configure Suggested Display & Desktop Settings
# -----------------------------------------------------------------------------
echo "[+] Configuring Desktop Icons (Ding extension)..."
if gsettings list-schemas | grep -q "org.gnome.shell.extensions.ding"; then
    gsettings set org.gnome.shell.extensions.ding icon-size 'small'
    gsettings set org.gnome.shell.extensions.ding start-corner 'top-left'
    gsettings set org.gnome.shell.extensions.ding show-home false
    gsettings set org.gnome.shell.extensions.ding show-trash false
    gsettings set org.gnome.shell.extensions.ding show-volumes false
fi

echo "[+] Configuring Ubuntu Dock (dash-to-dock extension)..."
if gsettings list-schemas | grep -q "org.gnome.shell.extensions.dash-to-dock"; then
    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 40
    gsettings set org.gnome.shell.extensions.dash-to-dock multi-monitor true
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
    gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
    gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
fi

echo "[+] Configuring Window Behavior and Fonts..."
gsettings set org.gnome.mutter center-new-windows true
gsettings set org.gnome.desktop.interface text-scaling-factor 1.0

echo ""
echo "================================================================================"
echo " Setup Completed Successfully!"
echo "================================================================================"
echo "  System Profile:    ${SYSTEM_NAME}"
echo "  Panel Style:       ${PANEL_MODE}"
echo "  Shell Theme:       ${THEME_NAME}"
echo "  Legacy App Theme:  ${THEME_NAME}"
echo "  Icon Theme:        ${ICON_NAME}"
echo "  Cursor:            DMZ-White"
echo "  Login Wallpaper:   /usr/share/backgrounds/${LOGIN_BG_IMG}"
echo "  Files Icon Size:   Medium (3 of 5)"
echo "  Dock Position:     Bottom (Panel Mode, 40px)"
echo "  Desktop Icons:     Small, Top-Left (Home/Trash/Volumes hidden)"
echo "================================================================================"
echo ""
echo "IMPORTANT: As noted in the guide, never open Settings -> Appearance in Ubuntu,"
echo "           as it will reset custom shell and icon themes to defaults."
echo ""

if [[ "$RESTART_GDM" == "true" ]]; then
    echo "[!] Restarting gdm3 service now..."
    sudo systemctl restart gdm3
else
    echo "To finalize login screen and session changes, log out and back in,"
    echo "or restart the display manager: sudo systemctl restart gdm3"
fi
