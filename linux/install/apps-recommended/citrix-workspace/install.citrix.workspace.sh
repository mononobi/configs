#!/usr/bin/env bash
# Description: Install and configure Citrix Workspace App with automatic compatibility detection
# Note: Implements compatibility layer for newer/unsupported Ubuntu releases (e.g. 26.04+).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE="${SKIP_UPDATE:-false}"
COMPATIBILITY_MODE="auto"
AUTO_DOWNLOAD=true
DEB_PATH=""
DOWNLOADED_FILE=""

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [PATH_TO_DEB]

Description:
  Installs Citrix Workspace App (ICA Client) with automatic download
  and automatic detection for compatibility dependencies on Ubuntu.

Arguments:
  PATH_TO_DEB              Path to the downloaded Citrix .deb package (optional)

Options:
  --deb PATH               Path to the Citrix Workspace .deb package
  --compatibility          Force enable compatibility installation steps
  --no-compatibility       Force disable compatibility installation steps
  --no-download            Do not attempt auto-download; require local .deb file
  --no-update              Skip apt update before installation
  -h, --help               Show this help message and exit

Notes:
  - If no local package is specified, the script automatically downloads the
    'Full Package (Self-Service Support) (x86_64)' from the official Citrix page.
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
        --no-download)
            AUTO_DOWNLOAD=false
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

is_installed "icaclient" --name "Citrix Workspace" && exit 0

echo "================================================================================"
echo " Starting Citrix Workspace App Installation"
echo "================================================================================"

# 0. Ensure required helper applications are satisfied via utils.sh
require_app curl ca-certificates net-tools debconf-utils
require_app python --fast

# 1. Resolve or download the Citrix Workspace .deb package
fetch_citrix_deb() {
    local page_url="https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html"
    echo "[+] Attempting to auto-download latest Citrix Workspace package from:"
    echo "    $page_url"

    local html
    html=$(curl -sL -A "Mozilla/5.0 (X11; Linux x86_64)" "$page_url" 2>/dev/null || true)
    if [[ -z "$html" ]]; then
        echo "[!] Warning: Failed to retrieve Citrix downloads page."
        return 1
    fi

    local download_url=""
    download_url=$(python3 -c '
import sys, re
html = sys.stdin.read()
pattern = r"<h4>\s*Full Package \(Self-Service Support\)[^<]*\(x86_64\)\s*</h4>.*?rel=\"([^\"]+)\""
match = re.search(pattern, html, re.DOTALL | re.IGNORECASE)
if match:
    rel = match.group(1).strip()
    if rel.startswith("//"):
        rel = "https:" + rel
    print(rel)
    sys.exit(0)
sys.exit(1)
' <<< "$html" 2>/dev/null || true)

    if [[ -z "$download_url" ]]; then
        echo "[!] Warning: Could not locate 'Full Package (Self-Service Support) (x86_64)' download link on Citrix page."
        return 1
    fi

    echo "[+] Found package download link:"
    echo "    ${download_url%%\?*}"

    local target_dir="${HOME}/Downloads"
    mkdir -p "$target_dir"
    local target_file="${target_dir}/icaclient_latest_amd64.deb"

    echo "[+] Downloading package to $target_file..."
    if curl -fL --progress-bar -A "Mozilla/5.0 (X11; Linux x86_64)" -o "$target_file" "$download_url"; then
        if [[ -s "$target_file" ]]; then
            DEB_PATH="$target_file"
            DOWNLOADED_FILE="$target_file"
            echo "[✓] Successfully downloaded: $DEB_PATH"
            return 0
        fi
    fi

    echo "[!] Warning: Download failed or produced an empty file."
    rm -f "$target_file"
    return 1
}

# Resolve Citrix Workspace package
if [[ -n "$DEB_PATH" && -f "$DEB_PATH" ]]; then
    echo "[+] Using specified Citrix package: $DEB_PATH"
else
    # Check if a package already exists locally in current dir or ~/Downloads
    DEB_CANDIDATE=$(find . ~/Downloads -maxdepth 2 -type f -name "icaclient*.deb" 2>/dev/null | head -n 1 || true)

    if [[ "$AUTO_DOWNLOAD" == "true" ]]; then
        if ! fetch_citrix_deb; then
            echo "[!] Auto-download failed; falling back to local file check."
            if [[ -n "$DEB_CANDIDATE" && -f "$DEB_CANDIDATE" ]]; then
                DEB_PATH="$DEB_CANDIDATE"
                DOWNLOADED_FILE="$DEB_CANDIDATE"
                echo "[+] Found existing local package: $DEB_PATH"
            fi
        fi
    else
        if [[ -n "$DEB_CANDIDATE" && -f "$DEB_CANDIDATE" ]]; then
            DEB_PATH="$DEB_CANDIDATE"
            DOWNLOADED_FILE="$DEB_CANDIDATE"
            echo "[+] Found existing local package: $DEB_PATH"
        fi
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
            if ! is_installed --check "libicu74"; then
                if ! apt-cache show libicu74 >/dev/null 2>&1; then
                    return 0
                fi
            fi
        fi
    fi

    # Check B: Check if ABI dependencies (e.g. libicu74) exist in APT repos
    # On supported Ubuntu versions (e.g. 24.04), libicu74 is present in the archive.
    # On unsupported future versions (e.g. 26.04), libicu74 is absent from APT.
    if ! is_installed --check "libicu74"; then
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
conditional_apt_update

# 3. Step: Compatibility Installation (if needed, MUST happen before install)
if [[ "$IS_COMPAT_NEEDED" == "true" ]]; then
    echo "[+] Performing Compatibility Installation..."

    # Select GTK2 package (libgtk2.0-0t64 on Ubuntu 24.04+, libgtk2.0-0 on earlier releases)
    GTK2_PKG="libgtk2.0-0"
    if apt-cache show libgtk2.0-0t64 >/dev/null 2>&1; then
        GTK2_PKG="libgtk2.0-0t64"
    fi

    echo "    Installing required compatibility libraries from APT..."
    sudo apt-get install -y \
        libsoup-2.4-1 \
        libwebkit2gtk-4.1-0 \
        libsecret-1-0 \
        libsecret-common \
        libsecret-tools \
        libopengl0 \
        libmanette-0.2-0 \
        "$GTK2_PKG"

    # Check if libicu74 is already installed
    NEED_ICU=false
    if ! is_installed --check "libicu74"; then
        NEED_ICU=true
    fi

    # Check if compatible libxml2 is installed
    NEED_XML2=false
    if ! is_installed --check "libxml2"; then
        NEED_XML2=true
    fi

    if [[ "$NEED_ICU" == "true" || "$NEED_XML2" == "true" ]]; then
        echo "    Downloading and installing required standalone dependencies..."
        TEMP_DIR=$(mktemp -d)
        pushd "$TEMP_DIR" >/dev/null

        DOWNLOAD_DEBS=()
        if [[ "$NEED_ICU" == "true" ]]; then
            echo "    -> Fetching libicu74..."
            curl -fLO --progress-bar "http://archive.ubuntu.com/ubuntu/pool/main/i/icu/libicu74_74.2-1ubuntu3.1_amd64.deb"
            DOWNLOAD_DEBS+=("libicu74_74.2-1ubuntu3.1_amd64.deb")
        fi

        if [[ "$NEED_XML2" == "true" ]]; then
            echo "    -> Fetching libxml2..."
            curl -fLO --progress-bar "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxml2/libxml2_2.9.14+dfsg-1.3ubuntu3.8_amd64.deb"
            DOWNLOAD_DEBS+=("libxml2_2.9.14+dfsg-1.3ubuntu3.8_amd64.deb")
        fi

        if [[ ${#DOWNLOAD_DEBS[@]} -gt 0 ]]; then
            sudo dpkg -i "${DOWNLOAD_DEBS[@]}" || sudo apt-get install -f -y
        fi

        popd >/dev/null
        rm -rf "$TEMP_DIR"
    fi
    echo "[✓] Pre-install compatibility dependencies completed."
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

# 6. Pre-configure debconf selections to answer "No" to prompts
echo "[+] Pre-configuring installer prompts (App Protection: No, deviceTRUST: No, EPA: No)..."
sudo debconf-set-selections <<'EOF'
icaclient app_protection/install_app_protection select no
icaclient devicetrust/install_devicetrust select no
icaclient epa/install_epa select no
EOF

# 7. Install the Citrix Workspace package non-interactively
echo "[+] Installing Citrix Workspace package: $DEB_PATH..."
if ! sudo DEBIAN_FRONTEND=noninteractive dpkg -i "$DEB_PATH"; then
    echo "[!] Resolving any missing dependencies via APT..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -f -y
fi

# 8. Clean up downloaded installer package upon successful installation
if is_installed --check "icaclient"; then
    if [[ -n "${DOWNLOADED_FILE:-}" && -f "$DOWNLOADED_FILE" ]]; then
        echo "[+] Cleaning up downloaded installer package: $DOWNLOADED_FILE..."
        rm -f "$DOWNLOADED_FILE"
    fi
fi

echo "================================================================================"
echo "[✓] Citrix Workspace installation completed successfully!"
echo "================================================================================"
echo "Verification commands:"
echo "  - Dependency check: /opt/Citrix/ICAClient/util/workspacecheck.sh"
echo "  - Launch app:       /opt/Citrix/ICAClient/selfservice"
