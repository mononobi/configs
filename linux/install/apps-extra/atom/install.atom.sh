#!/usr/bin/env bash
# Description: Install Atom text editor
# Note: Atom has been retired by GitHub. This downloads the latest official deb package or guides to Pulsar.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Atom text editor from the official GitHub debian release archive.
  Note: Atom was sunset in Dec 2022. Pulsar (https://pulsar-edit.dev) is the community successor.

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

echo "[+] Starting installation/setup for Atom..."

sudo apt-get update
sudo apt-get install -y curl ca-certificates libgconf-2-4

TEMP_DEB=$(mktemp --suffix=.deb)
trap "rm -f "$TEMP_DEB"" EXIT

echo "[+] Downloading official Atom v1.60.0 release deb package..."
curl -fsSL -o "$TEMP_DEB" "https://github.com/atom/atom/releases/download/v1.60.0/atom-amd64.deb"

sudo apt-get install -y "$TEMP_DEB"

echo "[✓] Atom setup completed successfully!"
