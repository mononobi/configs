#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Antigravity Agent Manager Installer
# -----------------------------------------------------------------------------

# Resolve script directory and source asset paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"
FILES_DIR="${SCRIPT_DIR}/files"
DESKTOP_SRC="${FILES_DIR}/antigravity.desktop"
ICON_SRC="${FILES_DIR}/antigravity.png"

# Target destinations
INSTALL_DIR="${HOME}/.antigravity-manager"
APP_DIR="${HOME}/.local/share/applications"
ICON_DIR="${HOME}/.local/share/icons"
DEST_DESKTOP="${APP_DIR}/antigravity.desktop"

# Dynamic values for .desktop entry based on user's $HOME
DESKTOP_EXEC="sh -c '${INSTALL_DIR}/Antigravity-x64/antigravity --class=antigravity %F; pkill -f antigravity'"
DESKTOP_PATH="${INSTALL_DIR}/Antigravity-x64/"

DRY_RUN=false
FORCE=false
DOWNLOAD_URL=""
CUSTOM_URL=false

SKIP_UPDATE=false

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [DOWNLOAD_URL]

Installs Antigravity Agent Manager (Antigravity v2).
If DOWNLOAD_URL is omitted, the latest stable release is automatically detected.
If already installed at the latest version, skips re-downloading.

Arguments:
  [DOWNLOAD_URL]    Optional direct URL to the Antigravity tarball (.tar.gz).
                    If omitted, auto-detects from the official auto-updater service.

Options:
  -u, --url <URL>   Specify direct download URL for Antigravity .tar.gz
  -F, --force       Force re-download and re-installation even if up to date
  -n, --dry-run     Run without modifying files or system state (no side effects)
  --no-update       Skip apt update before installation
  -h, --help        Display this help message and exit
EOF
}

# Parse command line options and arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -F|--force)
            FORCE=true
            shift
            ;;
        -u|--url)
            DOWNLOAD_URL="$2"
            CUSTOM_URL=true
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --no-update|--skip-update)
            SKIP_UPDATE=true
            shift
            ;;
        -*)
            echo "Error: Unknown option '$1'" >&2
            usage >&2
            exit 1
            ;;
        *)
            if [[ -n "$DOWNLOAD_URL" ]]; then
                echo "Error: Only a single download URL argument is accepted." >&2
                usage >&2
                exit 1
            fi
            DOWNLOAD_URL="$1"
            CUSTOM_URL=true
            shift
            ;;
    esac
done

get_installed_version() {
    local version_file="${INSTALL_DIR}/.version"
    if [[ -f "$version_file" ]]; then
        cat "$version_file" | tr -d '[:space:]'
        return 0
    fi

    local asar_file="${INSTALL_DIR}/Antigravity-x64/resources/app.asar"
    if [[ -f "$asar_file" ]] && command -v python3 >/dev/null 2>&1; then
        python3 -c "
import struct, json, sys
try:
    with open(sys.argv[1], 'rb') as f:
        f.seek(4)
        header_size = struct.unpack('<I', f.read(4))[0]
        f.seek(16)
        header_bytes = f.read(header_size - 8)
        header = json.loads(header_bytes.decode('utf-8'))
        pkg_info = header.get('files', {}).get('package.json', {})
        if 'offset' in pkg_info and 'size' in pkg_info:
            f.seek(16 + header_size - 8 + int(pkg_info['offset']))
            pkg = json.loads(f.read(pkg_info['size']).decode('utf-8'))
            print(pkg.get('version', ''))
except Exception:
    pass
" "$asar_file" 2>/dev/null || true
    fi
}

# Auto-detect latest Antigravity v2 release if not provided manually
LATEST_VERSION=""
if [[ "$CUSTOM_URL" != "true" ]]; then
    echo "[+] Auto-detecting latest Antigravity v2 release..."
    MANIFEST_URL="https://antigravity-hub-auto-updater-974169037036.us-central1.run.app/manifest/latest-x64-linux.yml"
    MANIFEST_DATA=$(curl -fsSL "$MANIFEST_URL" 2>/dev/null || true)
    LATEST_VERSION=$(echo "$MANIFEST_DATA" | grep -Po '^version:\s*\K[0-9.]+' | head -n 1 || true)
    BASE_URL=$(echo "$MANIFEST_DATA" | grep -Po 'https://[^\s]+/linux-x64/' | head -n 1 || true)
    if [[ -n "$BASE_URL" ]]; then
        DOWNLOAD_URL="${BASE_URL}Antigravity.tar.gz"
    fi

    CURRENT_VERSION=$(get_installed_version)
    if [[ "$FORCE" != "true" && -n "$CURRENT_VERSION" && -n "$LATEST_VERSION" && "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
        if [[ -x "${INSTALL_DIR}/Antigravity-x64/antigravity" && -f "$DEST_DESKTOP" ]]; then
            echo "[✓] Antigravity Agent Manager is already installed and up to date (v${CURRENT_VERSION})."
            exit 0
        fi
    fi
fi

# If auto-detection fails and still not set, ask user interactively
if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "[!] Could not auto-detect download URL from official update service."
    read -r -p "[?] Please enter direct download URL for Antigravity (.tar.gz): " DOWNLOAD_URL
fi

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "Error: Missing required download URL." >&2
    usage >&2
    exit 1
fi

run_cmd() {
    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY-RUN] $*"
    else
        echo "==> $*"
        "$@"
    fi
}

set_desktop_attribute() {
    local file="$1"
    local key="$2"
    local value="$3"

    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY-RUN] Set '${key}=${value}' in ${file}"
    else
        echo "==> Setting '${key}=${value}' in ${file}"
        if grep -q "^${key}=" "$file" 2>/dev/null; then
            sed -i "s|^${key}=.*|${key}=${value}|" "$file"
        else
            echo "${key}=${value}" >> "$file"
        fi
    fi
}

echo "=== Antigravity Agent Manager Installer ==="
if [[ "$DRY_RUN" == true ]]; then
    echo "[DRY-RUN MODE: No changes will be made]"
fi
echo "Download URL : ${DOWNLOAD_URL}"
echo "Install Dir  : ${INSTALL_DIR}"
echo "Desktop Src  : ${DESKTOP_SRC}"
echo "Desktop Dest : ${DEST_DESKTOP}"
echo "Icon Src     : ${ICON_SRC}"
echo "==========================================="

# Validate source assets exist
if [[ ! -f "$DESKTOP_SRC" ]]; then
    echo "Error: Desktop file not found at '${DESKTOP_SRC}'" >&2
    exit 1
fi

if [[ ! -f "$ICON_SRC" ]]; then
    echo "Error: Icon file not found at '${ICON_SRC}'" >&2
    exit 1
fi

# Detect download tool (curl / wget)
DOWNLOAD_CMD=""
if command -v curl &>/dev/null; then
    DOWNLOAD_CMD="curl"
elif command -v wget &>/dev/null; then
    DOWNLOAD_CMD="wget"
else
    echo "Error: Neither 'curl' nor 'wget' was found on this system." >&2
    exit 1
fi

# Step 1: Download tarball
if [[ "$DRY_RUN" == true ]]; then
    TEMP_TARBALL="/tmp/Antigravity.tar.gz"
    if [[ "$DOWNLOAD_CMD" == "curl" ]]; then
        run_cmd curl -fSL "$DOWNLOAD_URL" -o "$TEMP_TARBALL"
    else
        run_cmd wget -O "$TEMP_TARBALL" "$DOWNLOAD_URL"
    fi
else
    TEMP_DIR="$(mktemp -d)"
    cleanup() {
        rm -rf "$TEMP_DIR"
    }
    trap cleanup EXIT
    TEMP_TARBALL="${TEMP_DIR}/Antigravity.tar.gz"

    echo "==> Downloading Antigravity tarball..."
    if [[ "$DOWNLOAD_CMD" == "curl" ]]; then
        curl -fSL "$DOWNLOAD_URL" -o "$TEMP_TARBALL"
    else
        wget -O "$TEMP_TARBALL" "$DOWNLOAD_URL"
    fi
fi

# Step 2: Create installation directory
run_cmd mkdir -p "$INSTALL_DIR"

# Step 3: Extract archive into installation directory
run_cmd tar -xzf "$TEMP_TARBALL" -C "$INSTALL_DIR"

# Step 4: Set required permissions and ownership on chrome-sandbox
CHROME_SANDBOX="${INSTALL_DIR}/Antigravity-x64/chrome-sandbox"
run_cmd sudo chown root:root "$CHROME_SANDBOX"
run_cmd sudo chmod 4755 "$CHROME_SANDBOX"

# Step 5: Copy application shortcut (.desktop) to destination
run_cmd mkdir -p "$APP_DIR"
run_cmd cp "$DESKTOP_SRC" "$DEST_DESKTOP"

# Step 6: Dynamically set Exec and Path attributes in destination .desktop file
set_desktop_attribute "$DEST_DESKTOP" "Exec" "$DESKTOP_EXEC"
set_desktop_attribute "$DEST_DESKTOP" "Path" "$DESKTOP_PATH"

# Step 7: Copy application icon (.png)
run_cmd mkdir -p "$ICON_DIR"
run_cmd cp "$ICON_SRC" "${ICON_DIR}/"

# Step 8: Record installed version and refresh desktop databases
if [[ "$DRY_RUN" != true ]]; then
    if [[ -n "$LATEST_VERSION" ]]; then
        echo "$LATEST_VERSION" > "${INSTALL_DIR}/.version"
    else
        INSTALLED_VER=$(get_installed_version)
        [[ -n "$INSTALLED_VER" ]] && echo "$INSTALLED_VER" > "${INSTALL_DIR}/.version"
    fi
    update-desktop-database "$APP_DIR" 2>/dev/null || true
    gtk-update-icon-cache -f -t "$ICON_DIR" 2>/dev/null || true
fi

if [[ "$DRY_RUN" == true ]]; then
    echo "=== Dry-run completed successfully (no side effects) ==="
else
    echo "=== Antigravity Agent Manager installation completed successfully! ==="
fi
