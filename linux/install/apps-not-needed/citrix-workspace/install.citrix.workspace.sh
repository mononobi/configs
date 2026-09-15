#!/usr/bin/env bash
# Description: Install and configure Citrix Workspace App with automatic compatibility detection
# Note: Implements compatibility layer for newer/unsupported Ubuntu releases (e.g. 26.04+).

set -euo pipefail

SKIP_UPDATE=false
COMPATIBILITY_MODE="auto"
DEB_PATH=""

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [PATH_TO_DEB]

Description:
  Installs Citrix Workspace App (ICA Client) with automatic detection
  for compatibility dependencies on newer or uncertified Ubuntu releases.

Arguments:
  PATH_TO_DEB              Path to the downloaded Citrix .deb package

Options:
  --deb PATH               Path to the Citrix Workspace .deb package
  --compatibility          Force enable compatibility installation steps
  --no-compatibility       Force disable compatibility installation steps
  --no-update              Skip apt update before installation
  -h, --help               Show this help message and exit

Notes:
  - You can download the Debian package from:
    https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html
  - Choose 'Full Package (Self-Service Support)'.
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
        --compatibility)
            COMPATIBILITY_MODE="true"
            shift
            ;;
        --no-compatibility)
            COMPATIBILITY_MODE="false"
            shift
            ;;
        --deb)
            if [[ -n "${2:-}" ]]; then
                DEB_PATH="$2"
                shift 2
            else
                echo "[-] Error: --deb requires a file path."
                exit 1
            fi
            ;;
        *)
            if [[ -z "$DEB_PATH" && "$1" == *.deb ]]; then
                DEB_PATH="$1"
                shift
            else
                echo "[-] Unknown argument: $1"
                echo "Use -h or --help for usage information."
                exit 1
            fi
            ;;
    esac
done

echo "================================================================================"
echo " Starting Citrix Workspace App Installation"
echo "================================================================================"

# 1. Locate the Citrix Workspace .deb package first (to inspect its dependencies)
if [[ -z "$DEB_PATH" ]]; then
    # Auto-search in current directory and ~/Downloads
    DEB_CANDIDATE=$(find . ~/Downloads -maxdepth 2 -type f -name "icaclient*.deb" 2>/dev/null | head -n 1 || true)
    if [[ -n "$DEB_CANDIDATE" && -f "$DEB_CANDIDATE" ]]; then
        DEB_PATH="$DEB_CANDIDATE"
        echo "[+] Found Citrix installer package: $DEB_PATH"
    fi
fi

# 2. Detect if compatibility mode is needed dynamically
detect_compatibility() {
    # Check A: Inspect actual .deb dependencies against local APT repository
    if [[ -n "${DEB_PATH:-}" && -f "$DEB_PATH" ]]; then
        local deps
        deps=$(dpkg-deb -f "$DEB_PATH" Depends 2>/dev/null || true)
        
        # If the package requires libicu74, check if APT can supply it
        if echo "$deps" | grep -q "libicu74"; then
            if ! dpkg-query -W -f='${Status}' libicu74 2>/dev/null | grep -q "ok installed"; then
                if ! apt-cache show libicu74 >/dev/null 2>&1; then
                    return 0
                fi
            fi
        fi
    fi

    # Check B: Check if ABI dependencies (e.g. libicu74) exist in APT repos
    # On supported Ubuntu versions (e.g. 24.04), libicu74 is present in the archive.
    # On unsupported future versions (e.g. 26.04), libicu74 is absent from APT.
    if ! dpkg-query -W -f='${Status}' libicu74 2>/dev/null | grep -q "ok installed"; then
        if ! apt-cache show libicu74 >/dev/null 2>&1; then
            return 0
        fi
    fi

    # Check C: Check if WebKitGTK 4.0 runtime is missing while only 4.1 is available
    if ! ldconfig -p 2>/dev/null | grep -q "libwebkit2gtk-4.0\.so\.37"; then
        if ! apt-cache show libwebkit2gtk-4.0-37 >/dev/null 2>&1; then
            if ldconfig -p 2>/dev/null | grep -q "libwebkit2gtk-4.1\.so" || apt-cache show libwebkit2gtk-4.1-0 >/dev/null 2>&1; then
                return 0
            fi
        fi
    fi

    return 1
}

IS_COMPAT_NEEDED=false
if [[ "$COMPATIBILITY_MODE" == "true" ]]; then
    IS_COMPAT_NEEDED=true
    echo "[+] Compatibility mode: FORCED (enabled via flag)"
elif [[ "$COMPATIBILITY_MODE" == "false" ]]; then
    IS_COMPAT_NEEDED=false
    echo "[+] Compatibility mode: DISABLED (via flag)"
else
    if detect_compatibility; then
        IS_COMPAT_NEEDED=true
        echo "[+] Compatibility mode: AUTO-DETECTED (System repository is missing legacy ABIs; compatibility layer required)"
    else
        IS_COMPAT_NEEDED=false
        echo "[+] Compatibility mode: NOT NEEDED (Required dependencies are natively satisfiable)"
    fi
fi

# 2. Update APT cache if requested
if [[ "$SKIP_UPDATE" != "true" ]]; then
    echo "[+] Updating APT package index..."
    sudo apt-get update
fi

# 3. Step: Compatibility Installation (if needed, MUST happen before install)
if [[ "$IS_COMPAT_NEEDED" == "true" ]]; then
    echo "[+] Performing Compatibility Installation..."

    echo "    Installing required compatibility libraries from APT..."
    sudo apt-get install -y \
        libsoup2.4-1 \
        libwebkit2gtk-4.1-0 \
        ca-certificates \
        libsecret-1-0 \
        libsecret-common \
        libsecret-tools \
        libopengl0 \
        libmanette-0.2-0

    # Check if libicu74 is already installed
    NEED_ICU=false
    if ! dpkg-query -W -f='${Status}' libicu74 2>/dev/null | grep -q "ok installed"; then
        NEED_ICU=true
    fi

    # Check if compatible libxml2 is installed
    NEED_XML2=false
    if ! dpkg-query -W -f='${Status}' libxml2 2>/dev/null | grep -q "ok installed"; then
        NEED_XML2=true
    fi

    if [[ "$NEED_ICU" == "true" || "$NEED_XML2" == "true" ]]; then
        echo "    Downloading and installing required standalone dependencies..."
        TEMP_DIR=$(mktemp -d)
        pushd "$TEMP_DIR" >/dev/null

        DOWNLOAD_DEBS=()
        if [[ "$NEED_ICU" == "true" ]]; then
            echo "    -> Fetching libicu74..."
            wget -q --show-progress "http://archive.ubuntu.com/ubuntu/pool/main/i/icu/libicu74_74.2-1ubuntu3.1_amd64.deb"
            DOWNLOAD_DEBS+=("libicu74_74.2-1ubuntu3.1_amd64.deb")
        fi

        if [[ "$NEED_XML2" == "true" ]]; then
            echo "    -> Fetching libxml2..."
            wget -q --show-progress "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxml2/libxml2_2.9.14+dfsg-1.3ubuntu3.8_amd64.deb"
            DOWNLOAD_DEBS+=("libxml2_2.9.14+dfsg-1.3ubuntu3.8_amd64.deb")
        fi

        if [[ ${#DOWNLOAD_DEBS[@]} -gt 0 ]]; then
            sudo dpkg -i "${DOWNLOAD_DEBS[@]}" || sudo apt-get install -f -y
        fi

        popd >/dev/null
        rm -rf "$TEMP_DIR"
    fi
    echo "[✓] Pre-install compatibility dependencies completed."
fi

# 4. Verify the Citrix Workspace .deb package is available

if [[ -z "$DEB_PATH" || ! -f "$DEB_PATH" ]]; then
    echo ""
    echo "[-] Error: Citrix Workspace installer (.deb package) not found."
    echo "[!] Please download 'Full Package (Self-Service Support)' from:"
    echo "    https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html"
    echo ""
    echo "[!] Then re-run this script with the package path:"
    echo "    $0 /path/to/icaclient_*.deb"
    exit 1
fi

# 5. Pre-create the core user account to prevent logging service error
echo "[+] Pre-creating Citrix logging service user account (ctxcwa)..."
sudo groupadd -r ctxcwa 2>/dev/null || true
sudo useradd -r -g ctxcwa -d /var/run/ctxcwa -s /usr/sbin/nologin ctxcwa 2>/dev/null || true

# 6. Install the Citrix Workspace package
echo "[+] Installing Citrix Workspace package: $DEB_PATH..."
if ! sudo dpkg -i "$DEB_PATH"; then
    echo "[!] Resolving any missing dependencies via APT..."
    sudo apt-get install -f -y
fi

# 7. Post-Install Compatibility Step (Symlinks for WebKitGTK 4.0 -> 4.1)
if [[ "$IS_COMPAT_NEEDED" == "true" ]]; then
    echo "[+] Creating WebKitGTK 4.0 compatibility symlinks..."
    sudo mkdir -p /opt/Citrix/ICAClient/gtk2/lib
    if [[ -f /usr/lib/x86_64-linux-gnu/libwebkit2gtk-4.1.so.0 ]]; then
        sudo ln -sf /usr/lib/x86_64-linux-gnu/libwebkit2gtk-4.1.so.0 /opt/Citrix/ICAClient/gtk2/lib/libwebkit2gtk-4.0.so.37
    fi
    if [[ -f /usr/lib/x86_64-linux-gnu/libjavascriptcoregtk-4.1.so.0 ]]; then
        sudo ln -sf /usr/lib/x86_64-linux-gnu/libjavascriptcoregtk-4.1.so.0 /opt/Citrix/ICAClient/gtk2/lib/libjavascriptcoregtk-4.0.so.18
    fi
    echo "[✓] Compatibility symlinks configured in /opt/Citrix/ICAClient/gtk2/lib/"
fi

echo "================================================================================"
echo "[✓] Citrix Workspace installation completed successfully!"
echo "================================================================================"
echo "Verification commands:"
echo "  - Dependency check: /opt/Citrix/ICAClient/util/workspacecheck.sh"
echo "  - Launch app:       /opt/Citrix/ICAClient/selfservice"
