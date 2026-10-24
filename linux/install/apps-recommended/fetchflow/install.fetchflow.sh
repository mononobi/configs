#!/usr/bin/env bash
# Description: Install and configure FetchFlow download accelerator
# Note: Modern .NET 8 + GTK3 replacement for legacy XDM with full Wayland & HiDPI support.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

RELEASES_URL="https://github.com/Mayanktaker/fetchflow/releases"

SKIP_UPDATE="${SKIP_UPDATE:-false}"
FORCE=false
CUSTOM_VERSION=""

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs FetchFlow (modern C# / .NET 8 + GTK3 download manager with native Wayland/HiDPI support).
  Resolves the latest release dynamically from GitHub or accepts an explicit version override.

Options:
  -v, --version <ver> Specify an explicit FetchFlow version to install (e.g., 9.1.16.0)
  -F, --force         Force reinstallation even if already installed
  --no-update         Skip apt update before installation
  -h, --help          Show this help message and exit
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
        -F|--force)
            FORCE=true
            shift
            ;;
        -v|--version)
            CUSTOM_VERSION="${2:-}"
            if [[ -z "$CUSTOM_VERSION" ]]; then
                echo "[!] Error: --version requires a version argument." >&2
                exit 1
            fi
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
    esac
done

get_installed_version() {
    dpkg-query -W -f='${Version}\n' fetchflow 2>/dev/null | tr -d '[:space:]' || true
}

CURRENT_VERSION=$(get_installed_version)
if [[ -n "$CURRENT_VERSION" ]]; then
    echo "[i] Currently installed version: v${CURRENT_VERSION}"
fi

echo "[+] Starting installation/setup for FetchFlow..."

require_app curl ca-certificates

# Determine target version to install
TARGET_VERSION="$CUSTOM_VERSION"
if [[ -z "$TARGET_VERSION" ]]; then
    echo "[+] Resolving latest FetchFlow release version from GitHub..."

    # Strategy 1: GitHub REST API
    LATEST_API_TAG=$(curl -fsSL "https://api.github.com/repos/Mayanktaker/fetchflow/releases/latest" 2>/dev/null \
        | grep -o '"tag_name": *"[^"]*"' | head -n 1 | sed -E 's/.*"v?([^"]+)".*/\1/' || true)

    if [[ -n "$LATEST_API_TAG" && "$LATEST_API_TAG" =~ ^[0-9]+(\.[0-9]+)+$ ]]; then
        TARGET_VERSION="$LATEST_API_TAG"
    fi

    # Strategy 2: GitHub release redirect (fallback if API is rate-limited)
    if [[ -z "$TARGET_VERSION" ]]; then
        LATEST_HTTP_TAG=$(curl -fsSL -o /dev/null -w "%{url_effective}" "$RELEASES_URL/latest" 2>/dev/null \
            | awk -F'/' '{print $NF}' || true)
        LATEST_CLEAN_TAG="${LATEST_HTTP_TAG#v}"
        if [[ -n "$LATEST_CLEAN_TAG" && "$LATEST_CLEAN_TAG" =~ ^[0-9]+(\.[0-9]+)+$ ]]; then
            TARGET_VERSION="$LATEST_CLEAN_TAG"
        fi
    fi
fi

if [[ -z "$TARGET_VERSION" ]]; then
    echo "[-] Error: Failed to automatically resolve latest FetchFlow version from GitHub." >&2
    echo "    Please specify an explicit version with: $(basename "$0") --version <version>" >&2
    exit 1
fi

if [[ "$FORCE" != "true" && -n "$CURRENT_VERSION" && -n "$TARGET_VERSION" && "$CURRENT_VERSION" == "$TARGET_VERSION" ]]; then
    if [[ -x "/opt/fetchflow/fetchflow" || -x "/usr/bin/fetchflow" ]]; then
        echo "[✓] FetchFlow is already at latest version (v${CURRENT_VERSION}), skipping."
        exit 0
    fi
fi

if [[ -n "$CURRENT_VERSION" && "$CURRENT_VERSION" != "$TARGET_VERSION" ]]; then
    echo "[+] Upgrading FetchFlow: v${CURRENT_VERSION} -> v${TARGET_VERSION}..."
else
    echo "[+] Target version to install: v${TARGET_VERSION}"
fi

conditional_apt_update

DEB_URL="https://github.com/Mayanktaker/fetchflow/releases/download/v${TARGET_VERSION}/fetchflow_${TARGET_VERSION}_amd64.deb"
TEMP_DEB=$(mktemp --suffix=.deb)
trap 'rm -f "$TEMP_DEB"' EXIT

echo "[+] Downloading FetchFlow v${TARGET_VERSION} (.deb package)..."
if ! curl -fsSL "$DEB_URL" -o "$TEMP_DEB"; then
    echo "[!] Error: Failed to download FetchFlow package from: $DEB_URL" >&2
    exit 1
fi

# Ensure read access so APT sandbox user '_apt' can access the package
chmod 644 "$TEMP_DEB"

WAS_RUNNING=false
if pgrep -x fetchflow >/dev/null 2>&1; then
    WAS_RUNNING=true
    echo "[+] Closing active FetchFlow instance before updating..."
    pkill -x fetchflow 2>/dev/null || true
    sleep 1
    if pgrep -x fetchflow >/dev/null 2>&1; then
        pkill -9 -x fetchflow 2>/dev/null || true
    fi
fi

echo "[+] Installing FetchFlow via apt..."
sudo apt-get install -y "$TEMP_DEB"

if [[ "$WAS_RUNNING" == "true" ]]; then
    echo "[+] Restarting FetchFlow in the background..."
    (setsid /usr/bin/fetchflow --background >/dev/null 2>&1 &)
fi

echo "[✓] FetchFlow setup completed successfully!"
