#!/usr/bin/env bash
# Description: Install pre-commit (framework for managing multi-language git pre-commit hooks)
# Note: Manages and maintains multi-language pre-commit hooks in git repositories

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE="${SKIP_UPDATE:-false}"
FORCE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs pre-commit (framework for managing multi-language git pre-commit hooks)
  into an isolated user environment using uv tool.
  The binary is placed in ~/.local/bin/pre-commit.

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
is_installed "pre-commit" && exit 0

echo "[+] Starting installation/setup for pre-commit..."

# Require uv package installer
require_app uv

# Ensure ~/.local/bin is present in PATH and shell startup files
ensure_local_bin_in_path

if [[ "$FORCE" == "true" ]]; then
    uv tool install --reinstall pre-commit
else
    uv tool install pre-commit
fi

echo "[✓] pre-commit setup completed successfully!"
