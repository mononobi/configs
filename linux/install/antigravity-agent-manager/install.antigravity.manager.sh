#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Antigravity Agent Manager Installer
# -----------------------------------------------------------------------------

# Resolve script directory and source asset paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILES_DIR="${SCRIPT_DIR}/files"
DESKTOP_SRC="${FILES_DIR}/antigravity-manager.desktop"
ICON_SRC="${FILES_DIR}/antigravity.png"

# Target destinations
INSTALL_DIR="${HOME}/.antigravity-manager"
APP_DIR="${HOME}/.local/share/applications"
ICON_DIR="${HOME}/.local/share/icons"
DEST_DESKTOP="${APP_DIR}/antigravity-manager.desktop"

# Dynamic values for .desktop entry based on user's $HOME
DESKTOP_EXEC="sh -c '${INSTALL_DIR}/Antigravity-x64/antigravity --class=AntigravityManager %F; pkill -f AntigravityManager'"
DESKTOP_PATH="${INSTALL_DIR}/Antigravity-x64/"

DRY_RUN=false
DOWNLOAD_URL=""

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] <DOWNLOAD_URL>

Installs Antigravity Agent Manager from a provided download URL.

Arguments:
  <DOWNLOAD_URL>    URL to download the Antigravity tarball (.tar.gz)

Options:
  -n, --dry-run     Run without modifying files or system state (no side effects)
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
        -h|--help)
            usage
            exit 0
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
            shift
            ;;
    esac
done

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

if [[ "$DRY_RUN" == true ]]; then
    echo "=== Dry-run completed successfully (no side effects) ==="
else
    echo "=== Antigravity Agent Manager installation completed successfully! ==="
fi
