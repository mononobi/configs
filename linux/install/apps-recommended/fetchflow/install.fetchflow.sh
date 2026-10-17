#!/usr/bin/env bash
# Description: Install and configure FetchFlow download accelerator
# Note: Modern .NET 8 + GTK3 replacement for legacy XDM with full Wayland & HiDPI support.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

RELEASES_URL="https://github.com/Mayanktaker/fetchflow/releases"
SCRIPT_URL="https://github.com/Mayanktaker/fetchflow/releases/latest/download/install-fetchflow.sh"

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

is_installed "fetchflow" --name "FetchFlow" && exit 0

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

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "[+] Downloading official FetchFlow installer script..."
if ! curl -fsSL "$SCRIPT_URL" -o "$TEMP_DIR/install-fetchflow.sh"; then
    echo "[!] Error: Failed to download FetchFlow installer script from $SCRIPT_URL" >&2
    exit 1
fi
chmod +x "$TEMP_DIR/install-fetchflow.sh"

INSTALLER_ARGS=("-y")
if [[ -n "$TARGET_VERSION" ]]; then
    echo "[+] Target version resolved: v${TARGET_VERSION}"
    INSTALLER_ARGS+=(--version "$TARGET_VERSION")
else
    echo "[i] Could not dynamically resolve latest version. Falling back to default version embedded in installer script."
fi

echo "[+] Running FetchFlow installer..."
sudo bash "$TEMP_DIR/install-fetchflow.sh" "${INSTALLER_ARGS[@]}"

echo "[✓] FetchFlow setup completed successfully!"
