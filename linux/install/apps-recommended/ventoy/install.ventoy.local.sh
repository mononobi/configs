#!/usr/bin/env bash
# Description: Install Ventoy multiboot USB creator locally for current user
# Note: Adheres to install.ventoy.local.txt; installs to ~/.local/share/ventoy/ventoy-current and configures desktop integration.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

ARCHIVE_PATH=""
DOWNLOAD_URL=""
FORCE=false
SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [ARCHIVE_OR_URL]

Description:
  Installs Ventoy multiboot USB creator locally in ~/.local/share/ventoy/ventoy-current.
  Copies ventoy.png to ~/.local/share/icons/hicolor/512x512/apps, configures ventoy.desktop with the user's
  absolute path in ~/.local/share/applications, and makes the GUI launcher executable.

Arguments:
  ARCHIVE_OR_URL        Path to a local ventoy-*-linux.tar.gz archive or direct download URL.
                        If omitted, automatically downloads the latest release from GitHub.

Options:
  -u, --url URL         Specify download URL
  -f, --file PATH       Specify local archive path
  -F, --force           Force re-download and reinstall even if already up to date
  --no-update           Skip apt update before installation
  -h, --help            Show this help message and exit

Examples:
  $(basename "$0")                              # Automatically downloads latest release and installs locally
  $(basename "$0") ./ventoy-1.1.17-linux.tar.gz # Installs from a local archive file
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -F|--force)
            FORCE=true
            shift
            ;;
        --no-update|--skip-update)
            SKIP_UPDATE=true
            shift
            ;;
        -u|--url)
            DOWNLOAD_URL="$2"
            shift 2
            ;;
        -f|--file)
            ARCHIVE_PATH="$2"
            shift 2
            ;;
        http*://*)
            DOWNLOAD_URL="$1"
            shift
            ;;
        *.tar.gz)
            ARCHIVE_PATH="$1"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

echo "[+] Starting local installation for Ventoy Bootable USB Tool..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENTOY_BASE="$HOME/.local/share/ventoy"
VENTOY_DIR="$VENTOY_BASE/ventoy-current"

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# 1. Obtain archive (from parameter, local folder, or GitHub)
if [[ -n "$ARCHIVE_PATH" && -f "$ARCHIVE_PATH" ]]; then
    TARBALL="$ARCHIVE_PATH"
elif [[ -n "$DOWNLOAD_URL" ]]; then
    echo "[+] Downloading Ventoy from $DOWNLOAD_URL..."
    curl -fsSL "$DOWNLOAD_URL" -o "$TEMP_DIR/ventoy.tar.gz"
    TARBALL="$TEMP_DIR/ventoy.tar.gz"
else
    # Check if a matching tar.gz exists in script directory
    LOCAL_TAR=$(find "$SCRIPT_DIR" -maxdepth 1 -name "ventoy-*-linux.tar.gz" | head -n 1)
    if [[ -n "$LOCAL_TAR" && -f "$LOCAL_TAR" ]]; then
        echo "[+] Using local archive: $LOCAL_TAR"
        TARBALL="$LOCAL_TAR"
    else
        echo "[+] Fetching latest Ventoy release URL from GitHub..."
        require_app "curl" "apps-recommended"
        require_app "tar" "apps-recommended"
        require_app "ca-certificates" "apps-recommended"

        LATEST_URL=$(curl -fsSL https://api.github.com/repos/ventoy/Ventoy/releases/latest 2>/dev/null | grep -Po '"browser_download_url":\s*"\K[^"]*linux\.tar\.gz' | head -n 1 || true)
        if [[ -z "$LATEST_URL" ]]; then
            echo "[!] Could not automatically find latest download URL from GitHub."
            read -r -p "[?] Please enter the direct download URL for Ventoy (linux.tar.gz): " LATEST_URL
        fi

        if [[ -z "$LATEST_URL" ]]; then
            echo "[!] Error: No download URL provided."
            exit 1
        fi

        LATEST_VERSION=$(echo "$LATEST_URL" | grep -Po 'ventoy-\K[0-9.]+(?=-linux\.tar\.gz)' || true)
        CURRENT_VERSION=""
        if [[ -f "$VENTOY_DIR/ventoy/version" ]]; then
            CURRENT_VERSION=$(tr -d '[:space:]' < "$VENTOY_DIR/ventoy/version" 2>/dev/null || true)
        fi

        if [[ "$FORCE" != "true" && -n "$CURRENT_VERSION" && -n "$LATEST_VERSION" && "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
            if [[ -x "$VENTOY_DIR/VentoyGUI.x86_64" && -f "$HOME/.local/share/applications/ventoy.desktop" ]]; then
                echo "[✓] Ventoy is already installed and up to date (v${CURRENT_VERSION})."
                ensure_local_bin_in_path
                ln -sf "$VENTOY_DIR/VentoyGUI.x86_64" "$HOME/.local/bin/ventoy-gui"
                ln -sf "$VENTOY_DIR/VentoyWeb.sh" "$HOME/.local/bin/ventoy-web"
                exit 0
            fi
        fi

        echo "[+] Downloading Ventoy from $LATEST_URL..."
        curl -fsSL "$LATEST_URL" -o "$TEMP_DIR/ventoy.tar.gz"
        TARBALL="$TEMP_DIR/ventoy.tar.gz"
    fi
fi

# 2. Extract into ~/.local/share/ventoy/ventoy-current
echo "[+] Preparing directory at $VENTOY_DIR..."
mkdir -p "$VENTOY_BASE"

EXTRACT_TEMP="$TEMP_DIR/extracted"
mkdir -p "$EXTRACT_TEMP"
echo "[+] Extracting archive..."
tar -xzf "$TARBALL" -C "$EXTRACT_TEMP"

# Locate extracted directory (handles both ./ventoy-X.Y.Z and ventoy-X.Y.Z)
EXTRACTED_DIR=$(find "$EXTRACT_TEMP" -mindepth 1 -maxdepth 2 -type d -name "ventoy-*" | head -n 1)

if [[ -n "$EXTRACTED_DIR" && -f "$EXTRACTED_DIR/VentoyGUI.x86_64" ]]; then
    SOURCE_DIR="$EXTRACTED_DIR"
elif [[ -f "$EXTRACT_TEMP/VentoyGUI.x86_64" ]]; then
    SOURCE_DIR="$EXTRACT_TEMP"
else
    echo "[!] Error: VentoyGUI.x86_64 not found in extracted archive." >&2
    exit 1
fi

mkdir -p "$VENTOY_DIR"
cp -a "$SOURCE_DIR/." "$VENTOY_DIR/"

# 3. Make executables runnable
chmod 755 "$VENTOY_DIR/VentoyGUI."* 2>/dev/null || true
chmod 755 "$VENTOY_DIR/VentoyWeb.sh" 2>/dev/null || true
chmod 755 "$VENTOY_DIR/Ventoy2Disk.sh" 2>/dev/null || true
chmod 755 "$VENTOY_DIR/CreatePersistentImg.sh" 2>/dev/null || true
chmod 755 "$VENTOY_DIR/ExtendPersistentImg.sh" 2>/dev/null || true
chmod 755 "$VENTOY_DIR/VentoyPlugson.sh" 2>/dev/null || true
chmod 755 "$VENTOY_DIR/VentoyVlnk.sh" 2>/dev/null || true
chmod 755 "$VENTOY_DIR/tool/"*"/Ventoy2Disk."* 2>/dev/null || true
chmod 755 "$VENTOY_DIR/tool/"*"/xzcat" 2>/dev/null || true

# 4. Copy icon to ~/.local/share/icons/hicolor/512x512/apps
mkdir -p "$HOME/.local/share/icons"
if [[ -f "$SCRIPT_DIR/files/ventoy.png" ]]; then
    echo "[+] Copying icon to $HOME/.local/share/icons/hicolor/512x512/apps/ventoy.png..."
    cp "$SCRIPT_DIR/files/ventoy.png" "$HOME/.local/share/icons/ventoy.png"
    mkdir -p "$HOME/.local/share/icons/hicolor/512x512/apps"
    cp "$SCRIPT_DIR/files/ventoy.png" "$HOME/.local/share/icons/hicolor/512x512/apps/ventoy.png"
    gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
fi

# 5. Copy and customize .desktop file in ~/.local/share/applications
mkdir -p "$HOME/.local/share/applications"
if [[ -f "$SCRIPT_DIR/files/ventoy.desktop" ]]; then
    echo "[+] Configuring $HOME/.local/share/applications/ventoy.desktop with absolute path..."
    sed -e "s|/home/USER_NAME|${HOME}|g" \
        -e "s|^Exec=.*|Exec=${VENTOY_DIR}/VentoyGUI.x86_64|g" \
        -e "s|^Path=.*|Path=${VENTOY_DIR}|g" \
        "$SCRIPT_DIR/files/ventoy.desktop" > "$HOME/.local/share/applications/ventoy.desktop"

    if ! grep -q "^Path=" "$HOME/.local/share/applications/ventoy.desktop"; then
        sed -i "/^Exec=/a Path=${VENTOY_DIR}" "$HOME/.local/share/applications/ventoy.desktop"
    fi
    chmod 644 "$HOME/.local/share/applications/ventoy.desktop"
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

# 6. Create user bin symlink for CLI/terminal convenience
ensure_local_bin_in_path
ln -sf "$VENTOY_DIR/VentoyGUI.x86_64" "$HOME/.local/bin/ventoy-gui"
ln -sf "$VENTOY_DIR/VentoyWeb.sh" "$HOME/.local/bin/ventoy-web"

echo "[✓] Ventoy successfully installed to: $VENTOY_DIR"
echo "[✓] Desktop launcher created at: $HOME/.local/share/applications/ventoy.desktop"
echo "[✓] Icon placed at: $HOME/.local/share/icons/hicolor/512x512/apps/ventoy.png"
