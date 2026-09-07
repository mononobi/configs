#!/usr/bin/env bash
# Description: Install Ventoy multiboot USB creator locally for current user
# Note: Adheres to install.ventoy.local.txt; installs to ~/.local/share/ventoy/ventoy-current and configures desktop integration.

set -euo pipefail

ARCHIVE_PATH=""
DOWNLOAD_URL=""

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [ARCHIVE_OR_URL]

Description:
  Installs Ventoy multiboot USB creator locally in ~/.local/share/ventoy/ventoy-current.
  Copies ventoy.png to ~/.local/share/icons, configures ventoy.desktop with the user's
  absolute path in ~/.local/share/applications, and makes the GUI launcher executable.

Arguments:
  ARCHIVE_OR_URL        Path to a local ventoy-*-linux.tar.gz archive or direct download URL.
                        If omitted, automatically downloads the latest release from GitHub.

Options:
  -u, --url URL         Specify download URL
  -f, --file PATH       Specify local archive path
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
        if [[ "$SKIP_UPDATE" != "true" ]]; then
            sudo apt-get update
        fi
        sudo apt-get install -y curl tar ca-certificates

        LATEST_URL=$(curl -fsSL https://api.github.com/repos/ventoy/Ventoy/releases/latest 2>/dev/null | grep -Po '"browser_download_url":\s*"\K[^"]*linux\.tar\.gz' | head -n 1 || true)
        if [[ -z "$LATEST_URL" ]]; then
            echo "[!] Could not automatically find latest download URL from GitHub."
            read -r -p "[?] Please enter the direct download URL for Ventoy (linux.tar.gz): " LATEST_URL
        fi

        if [[ -z "$LATEST_URL" ]]; then
            echo "[!] Error: No download URL provided."
            exit 1
        fi
        echo "[+] Downloading Ventoy from $LATEST_URL..."
        curl -fsSL "$LATEST_URL" -o "$TEMP_DIR/ventoy.tar.gz"
        TARBALL="$TEMP_DIR/ventoy.tar.gz"
    fi
fi

# 2. Extract into ~/.local/share/ventoy/ventoy-current
echo "[+] Preparing directory at $VENTOY_DIR..."
mkdir -p "$VENTOY_DIR"

echo "[+] Extracting archive into $VENTOY_DIR..."
tar -xzf "$TARBALL" -C "$VENTOY_DIR" --strip-components=1

# 3. Make executables runnable
if [[ -f "$VENTOY_DIR/VentoyGUI.x86_64" ]]; then
    chmod 755 "$VENTOY_DIR/VentoyGUI.x86_64"
fi
if [[ -f "$VENTOY_DIR/VentoyWeb.sh" ]]; then
    chmod 755 "$VENTOY_DIR/VentoyWeb.sh"
fi
if [[ -f "$VENTOY_DIR/Ventoy2Disk.sh" ]]; then
    chmod 755 "$VENTOY_DIR/Ventoy2Disk.sh"
fi

# 4. Copy icon to ~/.local/share/icons
mkdir -p "$HOME/.local/share/icons"
if [[ -f "$SCRIPT_DIR/files/ventoy.png" ]]; then
    echo "[+] Copying icon to $HOME/.local/share/icons/ventoy.png..."
    cp "$SCRIPT_DIR/files/ventoy.png" "$HOME/.local/share/icons/ventoy.png"
fi

# 5. Copy and customize .desktop file in ~/.local/share/applications
mkdir -p "$HOME/.local/share/applications"
if [[ -f "$SCRIPT_DIR/files/ventoy.desktop" ]]; then
    echo "[+] Configuring $HOME/.local/share/applications/ventoy.desktop with absolute path..."
    # Replace USER_NAME or existing Exec path with exact current user path
    sed "s|^Exec=.*|Exec=${VENTOY_DIR}/VentoyGUI.x86_64|g" "$SCRIPT_DIR/files/ventoy.desktop" > "$HOME/.local/share/applications/ventoy.desktop"
    chmod 644 "$HOME/.local/share/applications/ventoy.desktop"
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

# 6. Create user bin symlink for CLI/terminal convenience if ~/.local/bin exists or can be used
mkdir -p "$HOME/.local/bin"
ln -sf "$VENTOY_DIR/VentoyGUI.x86_64" "$HOME/.local/bin/ventoy-gui"
ln -sf "$VENTOY_DIR/VentoyWeb.sh" "$HOME/.local/bin/ventoy-web"

echo "[✓] Ventoy successfully installed to: $VENTOY_DIR"
echo "[✓] Desktop launcher created at: $HOME/.local/share/applications/ventoy.desktop"
echo "[✓] Icon placed at: $HOME/.local/share/icons/ventoy.png"
