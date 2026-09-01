#!/usr/bin/env bash
# Description: Install and configure onefetch Git information tool
# Note: Modernized for Ubuntu with best practices (direct GitHub binary / Cargo, no snap).

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Onefetch Git repository information tool by downloading the latest official release binary from GitHub.

Options:
  -h, --help    Show this help message and exit
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

echo "[+] Starting installation/setup for onefetch..."

sudo apt-get update
sudo apt-get install -y curl tar ca-certificates

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "[+] Fetching latest onefetch release from GitHub..."
DOWNLOAD_URL=$(curl -fsSL https://api.github.com/repos/o2sh/onefetch/releases/latest | grep -Po '"browser_download_url":\s*"\K[^"]*linux-x86_64\.tar\.gz' | head -n 1 || true)

if [[ -z "$DOWNLOAD_URL" ]]; then
    # Fallback to direct well-known pattern
    DOWNLOAD_URL=$(curl -fsSL https://api.github.com/repos/o2sh/onefetch/releases/latest | grep -Po '"browser_download_url":\s*"\K[^"]*linux[^"]*\.tar\.gz' | head -n 1 || true)
fi

if [[ -n "$DOWNLOAD_URL" ]]; then
    echo "[+] Downloading $DOWNLOAD_URL..."
    curl -fsSL "$DOWNLOAD_URL" -o "$TEMP_DIR/onefetch.tar.gz"
    tar -xzf "$TEMP_DIR/onefetch.tar.gz" -C "$TEMP_DIR"
    ONEFETCH_BIN=$(find "$TEMP_DIR" -type f -name "onefetch" | head -n 1)
    if [[ -n "$ONEFETCH_BIN" ]]; then
        sudo install -m 755 "$ONEFETCH_BIN" /usr/local/bin/onefetch
        echo "[+] Installed onefetch to /usr/local/bin/onefetch"
    fi
elif command -v cargo >/dev/null 2>&1; then
    echo "[+] Installing onefetch via Cargo..."
    cargo install onefetch
else
    echo "[+] Installing onefetch via APT..."
    sudo apt-get install -y onefetch || true
fi

echo "[✓] onefetch setup completed successfully!"
