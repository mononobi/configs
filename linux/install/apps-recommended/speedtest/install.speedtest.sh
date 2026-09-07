#!/usr/bin/env bash
# Description: Install and configure Ookla Speedtest CLI
# Note: Modernized for Ubuntu with direct official binary installation.

set -euo pipefail

DOWNLOAD_URL=""
SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [DOWNLOAD_URL]

Description:
  Installs official Ookla Speedtest CLI binary by downloading the official release archive
  and installing the binary into ~/.local/bin.

Arguments:
  DOWNLOAD_URL          Optional direct download URL for Ookla Speedtest (.tgz)

Options:
  -u, --url <URL>       Specify direct download URL for Ookla Speedtest (.tgz)
  --no-update           Skip apt update before installation
  -h, --help            Show this help message and exit

Examples:
  $(basename "$0")
  $(basename "$0") https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-x86_64.tgz
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
        -*)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
        *)
            if [[ -z "$DOWNLOAD_URL" ]]; then
                DOWNLOAD_URL="$1"
            else
                echo "Unexpected extra argument: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

echo "[+] Starting installation/setup for Ookla Speedtest CLI..."

if ! command -v curl >/dev/null 2>&1 || ! command -v tar >/dev/null 2>&1; then
    if [[ "$SKIP_UPDATE" != "true" ]]; then
        sudo apt-get update
    fi
    sudo apt-get install -y curl tar ca-certificates
fi

TARGET_DIR="${HOME}/.local/bin"
TARGET_BIN="${TARGET_DIR}/speedtest"

if [[ -f "$TARGET_BIN" ]]; then
    EXISTING_VER=$("$TARGET_BIN" --version 2>/dev/null | grep -Po 'Speedtest by Ookla \K[0-9.]+' || true)
    echo "[i] Existing Speedtest installation detected at ${TARGET_BIN}${EXISTING_VER:+ (v$EXISTING_VER)}."
    echo "    Downloading and validating new release before replacing..."
fi

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Detect system architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)          ARCH_TAG="x86_64" ;;
    aarch64|arm64)   ARCH_TAG="aarch64" ;;
    armv7l|armhf)    ARCH_TAG="armhf" ;;
    armv6l|armel)    ARCH_TAG="armel" ;;
    i386|i686)       ARCH_TAG="i386" ;;
    *)               ARCH_TAG="x86_64" ;;
esac

# Auto-detect latest download URL if not provided
if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "[+] Fetching latest Ookla Speedtest CLI download URL for architecture: ${ARCH_TAG}..."
    DOWNLOAD_URL=$(curl -fsSL https://www.speedtest.net/apps/cli 2>/dev/null | grep -Po "https://install\.speedtest\.net/app/cli/ookla-speedtest-[0-9.]+-linux-${ARCH_TAG}\.tgz" | head -n 1 || true)
fi

# Fall back to interactive prompt if auto-detection failed
if [[ -z "$DOWNLOAD_URL" ]]; then
    if [[ -t 0 ]]; then
        echo "[!] Could not resolve Ookla Speedtest download URL automatically from https://www.speedtest.net/apps/cli."
        read -r -p "[?] Please enter the direct download URL for Ookla Speedtest (.tgz): " DOWNLOAD_URL
    fi
fi

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "[!] Error: Could not automatically resolve Ookla Speedtest download URL." >&2
    echo "    Please run the script interactively or specify the URL directly:" >&2
    echo "      $(basename "$0") -u <URL>" >&2
    if [[ -f "$TARGET_BIN" ]]; then
        echo "[i] Existing installation at '$TARGET_BIN' was left untouched." >&2
    fi
    exit 1
fi

echo "[+] Downloading Ookla Speedtest from $DOWNLOAD_URL..."
if ! curl -fsSL "$DOWNLOAD_URL" -o "$TEMP_DIR/speedtest.tgz"; then
    echo "[!] Error: Failed to download archive from $DOWNLOAD_URL" >&2
    if [[ -f "$TARGET_BIN" ]]; then
        echo "[i] Existing installation at '$TARGET_BIN' was left untouched." >&2
    fi
    exit 1
fi

echo "[+] Extracting archive..."
tar -xzf "$TEMP_DIR/speedtest.tgz" -C "$TEMP_DIR"

SPEEDTEST_BIN=$(find "$TEMP_DIR" -maxdepth 1 -type f -name "speedtest" | head -n 1)
if [[ -z "$SPEEDTEST_BIN" || ! -f "$SPEEDTEST_BIN" ]]; then
    echo "[!] Error: 'speedtest' binary not found in downloaded archive." >&2
    if [[ -f "$TARGET_BIN" ]]; then
        echo "[i] Existing installation at '$TARGET_BIN' was left untouched." >&2
    fi
    exit 1
fi

chmod +x "$SPEEDTEST_BIN"

# Validate newly downloaded binary runs before touching existing installation
if ! "$SPEEDTEST_BIN" --version >/dev/null 2>&1; then
    echo "[!] Error: Downloaded speedtest binary failed execution check." >&2
    if [[ -f "$TARGET_BIN" ]]; then
        echo "[i] Existing installation at '$TARGET_BIN' was left untouched." >&2
    fi
    exit 1
fi

mkdir -p "$TARGET_DIR"

# If an older version already exists, remove it now that the replacement is validated
if [[ -f "$TARGET_BIN" ]]; then
    echo "[+] Replacing existing binary at $TARGET_BIN..."
    rm -f "$TARGET_BIN"
fi

install -m 0755 "$SPEEDTEST_BIN" "$TARGET_BIN"
echo "[+] Installed speedtest binary to ${TARGET_BIN}"

echo "[+] Verification:"
"$TARGET_DIR/speedtest" --version || true

echo "[✓] Ookla Speedtest CLI setup completed successfully!"
