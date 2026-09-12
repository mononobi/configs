#!/usr/bin/env bash
# Description: Install and enable Quick Settings Tweaker GNOME Shell extension from GitHub releases
# Note: Installs the modern community fork (quick-settings-tweaks@offx1). Verifies metadata.json inside the downloaded zip before installing to target.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
source "${SCRIPT_DIR}/../../../utils.sh"

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs and enables Quick Settings Tweaks from the modern GitHub releases fork
  (https://github.com/jstockdale/quick-settings-tweaks, UUID: quick-settings-tweaks@offx1).
  Reorganizes notifications, volume widgets, and toggles in the Quick Settings menu.

  Inspects metadata.json inside the downloaded archive to verify version compatibility
  before installing to the target destination.

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

# Prevent running via sudo
if [[ -n "${SUDO_USER:-}" && $EUID -eq 0 ]]; then
    echo "[!] Error: Do not run $(basename "$0") with sudo." >&2
    echo "    GNOME extensions must be installed in your personal user session." >&2
    echo "    Please run as your regular user: ./$(basename "$0")" >&2
    exit 1
fi

UUID="quick-settings-tweaks@offx1"
NAME="Quick Settings Tweaker (GitHub Fork)"
USER_EXT_DIR="${HOME}/.local/share/gnome-shell/extensions/${UUID}"
SYS_EXT_DIR="/usr/share/gnome-shell/extensions/${UUID}"

echo "[+] Processing GNOME extension: ${NAME} (${UUID})..."

# Ensure dependencies (curl, python, unzip) if not already in PATH
update_flag=()
[[ "$SKIP_UPDATE" == "true" ]] && update_flag=("--no-update")

if ! command -v curl >/dev/null 2>&1; then
    require_app "curl" "apps-recommended" "${update_flag[@]}"
fi
if ! command -v python3 >/dev/null 2>&1; then
    require_app "python" "apps-recommended" "${update_flag[@]}"
fi
if ! command -v unzip >/dev/null 2>&1; then
    require_app "unzip" "apps-recommended" "${update_flag[@]}"
fi

shell_ver="$(gnome-shell --version 2>/dev/null | awk '{print $3}' | cut -d. -f1)"
shell_ver="${shell_ver:-46}"

echo "    Resolving latest GitHub release asset for jstockdale/quick-settings-tweaks..."
DOWNLOAD_URL="$(python3 -c "
import urllib.request, json, sys

api_url = 'https://api.github.com/repos/jstockdale/quick-settings-tweaks/releases/latest'
req = urllib.request.Request(api_url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req, timeout=10) as resp:
        data = json.loads(resp.read().decode())
        for asset in data.get('assets', []):
            if asset.get('name', '').endswith('.zip'):
                print(asset.get('browser_download_url', ''))
                sys.exit(0)
except Exception:
    pass

print('https://github.com/jstockdale/quick-settings-tweaks/releases/download/v2.2-offx1.1/quick-settings-tweaks%40offx1.shell-extension.zip')
")"

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "    [!] Error: Failed to determine download URL for ${UUID}" >&2
    exit 1
fi

echo "    Downloading extension bundle from GitHub..."
TMP_ZIP="$(mktemp --suffix=.zip)"
if ! curl -fsSL "$DOWNLOAD_URL" -o "$TMP_ZIP"; then
    rm -f "$TMP_ZIP"
    echo "    [!] Error: Failed to download release bundle from GitHub" >&2
    exit 1
fi

configure_settings() {
    local schema_dir=""
    for d in \
        "${USER_EXT_DIR}/schemas" \
        "${HOME}/.local/share/gnome-shell/extensions/quick-settings-tweaks@qwreey/schemas" \
        "${HOME}/.local/share/glib-2.0/schemas" \
        "/usr/share/glib-2.0/schemas"; do
        if [[ -f "${d}/org.gnome.shell.extensions.quick-settings-tweaks.gschema.xml" ]]; then
            schema_dir="$d"
            break
        fi
    done

    local gset=(gsettings)
    if [[ -n "$schema_dir" ]]; then
        glib-compile-schemas "$schema_dir" 2>/dev/null || true
        gset+=(--schemadir "$schema_dir")
    fi

    if ! "${gset[@]}" list-keys org.gnome.shell.extensions.quick-settings-tweaks >/dev/null 2>&1; then
        return 0
    fi

    echo "[+] Configuring Quick Settings Tweaker settings according to guide..."

    # 1. Media Widget -> On, all check-boxes -> On
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks media-enabled true 2>/dev/null || true
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks media-contorl-show-next-button true 2>/dev/null || true
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks media-contorl-show-prev-button true 2>/dev/null || true
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks media-contorl-show-pause-button true 2>/dev/null || true
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks media-show-header true 2>/dev/null || true
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks media-compact true 2>/dev/null || true
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks media-round-clip-enabled true 2>/dev/null || true
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks media-round-clip-padding-adjustment-enabled true 2>/dev/null || true
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks media-progress-enabled true 2>/dev/null || true
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks media-remove-shadow true 2>/dev/null || true
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks media-gradient-enabled true 2>/dev/null || true

    # 2. Notifications Widget -> On, Native controls -> Off, all other check-boxes -> On, Max height: 438
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks notifications-enabled true 2>/dev/null || true
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks notifications-use-native-controls false 2>/dev/null || true
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks notifications-show-header true 2>/dev/null || true
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks notifications-compact true 2>/dev/null || true
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks notifications-autohide true 2>/dev/null || true
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks notifications-remove-shadow true 2>/dev/null || true
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks notifications-show-scrollbar true 2>/dev/null || true
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks notifications-max-height 438 2>/dev/null || true

    # 3. Weather Widget -> Off
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks weather-enabled false 2>/dev/null || true

    # 4. Volume Mixer Widget -> Off
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks volume-mixer-enabled false 2>/dev/null || true

    # 5. Toggles: DND Quick Toggle -> On, Unsafe Mode Quick Toggle -> Off
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks dnd-quick-toggle-enabled true 2>/dev/null || true
    "${gset[@]}" set org.gnome.shell.extensions.quick-settings-tweaks unsafe-quick-toggle-enabled false 2>/dev/null || true
}

# 1. Compare version of downloaded archive against installed copy
if ! compare_extension_version "$TMP_ZIP" "$UUID" "$NAME"; then
    configure_settings
    exit 0
fi

# 2. Check GNOME Shell version compatibility from metadata.json inside the downloaded zip before extracting to target dest
if ! check_extension_archive_compatibility "$TMP_ZIP" "$NAME" "$UUID"; then
    rm -f "$TMP_ZIP"
    exit 0
fi

# Version matches: Remove original upstream extension to prevent conflicts
ORIGINAL_UUID="quick-settings-tweaks@qwreey"
ORIGINAL_USER_DIR="${HOME}/.local/share/gnome-shell/extensions/${ORIGINAL_UUID}"
if [[ -d "$ORIGINAL_USER_DIR" ]] || gnome-extensions list 2>/dev/null | grep -q "$ORIGINAL_UUID"; then
    echo "[+] Removing original upstream extension (${ORIGINAL_UUID}) to prevent conflicts..."
    gnome-extensions disable "$ORIGINAL_UUID" 2>/dev/null || true
    gnome-extensions uninstall "$ORIGINAL_UUID" 2>/dev/null || true
    rm -rf "$ORIGINAL_USER_DIR"
fi

echo "    Metadata verified for GNOME ${shell_ver}. Installing to target destination..."
if command -v gnome-extensions >/dev/null 2>&1; then
    gnome-extensions install -f "$TMP_ZIP" 2>/dev/null || {
        mkdir -p "$USER_EXT_DIR"
        unzip -q -o "$TMP_ZIP" -d "$USER_EXT_DIR"
    }
else
    mkdir -p "$USER_EXT_DIR"
    unzip -q -o "$TMP_ZIP" -d "$USER_EXT_DIR"
fi
rm -f "$TMP_ZIP"

if [[ -d "${USER_EXT_DIR}/schemas" ]]; then
    glib-compile-schemas "${USER_EXT_DIR}/schemas" 2>/dev/null || true
fi

gnome-extensions enable "${UUID}" 2>/dev/null || true
echo "    [✓] Successfully installed and enabled: ${NAME}"

configure_settings
