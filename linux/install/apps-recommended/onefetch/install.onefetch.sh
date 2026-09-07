#!/usr/bin/env bash
# Description: Install and configure onefetch Git information tool
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

DOWNLOAD_URL=""

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Onefetch Git repository information tool by downloading the official release binary.

Options:
  -u, --url <URL>    Specify direct download URL for onefetch .tar.gz
  --no-update        Skip apt update before installation
  -h, --help         Show this help message and exit
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
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

echo "[+] Starting installation/setup for onefetch..."

if [[ "$SKIP_UPDATE" != "true" ]]; then
    sudo apt-get update
fi
sudo apt-get install -y curl tar ca-certificates

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "[+] Fetching latest onefetch release from GitHub..."
    DOWNLOAD_URL=$(curl -fsSL https://api.github.com/repos/o2sh/onefetch/releases/latest 2>/dev/null | grep -Po '"browser_download_url":\s*"\K[^"]*linux-x86_64\.tar\.gz' | head -n 1 || true)

    if [[ -z "$DOWNLOAD_URL" ]]; then
        DOWNLOAD_URL=$(curl -fsSL https://api.github.com/repos/o2sh/onefetch/releases/latest 2>/dev/null | grep -Po '"browser_download_url":\s*"\K[^"]*linux[^"]*\.tar\.gz' | head -n 1 || true)
    fi
fi

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "[!] Could not resolve onefetch release download URL automatically from GitHub."
    read -r -p "[?] Please enter the download URL for onefetch (.tar.gz): " DOWNLOAD_URL
fi

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "[!] Error: No download URL provided."
    exit 1
fi

echo "[+] Downloading $DOWNLOAD_URL..."
curl -fsSL "$DOWNLOAD_URL" -o "$TEMP_DIR/onefetch.tar.gz"
tar -xzf "$TEMP_DIR/onefetch.tar.gz" -C "$TEMP_DIR"
ONEFETCH_BIN=$(find "$TEMP_DIR" -type f -name "onefetch" | head -n 1)

if [[ -z "$ONEFETCH_BIN" ]]; then
    echo "[!] Error: 'onefetch' binary not found in downloaded archive."
    exit 1
fi

sudo install -m 755 "$ONEFETCH_BIN" /usr/local/bin/onefetch
echo "[+] Installed onefetch to /usr/local/bin/onefetch"
onefetch --version

echo "[✓] onefetch setup completed successfully!"
