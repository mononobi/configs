#!/usr/bin/env bash
# Description: Install Antigravity CLI (agy)
# Note: Google's official agentic terminal assistant

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE="${SKIP_UPDATE:-false}"
FORCE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Antigravity CLI (agy) using Google's official bootstrapper installer.
  The binary is placed in ~/.local/bin/agy and self-updates automatically.

Options:
  -F, --force                 Force re-installation even if already installed
  --no-update, --skip-update  Skip apt update before installation
  -h, --help                  Show this help message and exit
EOF
}

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
        *)
            echo "Unknown option: $1" >&2
            show_help >&2
            exit 1
            ;;
    esac
done

# Fast-path self-check (bypassed if FORCE=true)
is_installed "agy" --name "Antigravity CLI" && exit 0

echo "[+] Starting installation/setup for Antigravity CLI (agy)..."

# Require shared dependencies
require_app curl ca-certificates

# Ensure ~/.local/bin is present in PATH and shell startup files
ensure_local_bin_in_path

# If forcing re-installation, remove existing binary so the official installer proceeds
if [[ "$FORCE" == "true" ]]; then
    rm -f "${HOME}/.local/bin/agy"
fi

# Execute official Google Antigravity CLI bootstrapper installer
curl -fsSL https://antigravity.google/cli/install.sh | bash

echo "[✓] Antigravity CLI (agy) setup completed successfully!"
