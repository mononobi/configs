#!/usr/bin/env bash
# Description: Install pre-commit (framework for managing multi-language git pre-commit hooks)
# Note: Manages and maintains multi-language pre-commit hooks in git repositories

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE="${SKIP_UPDATE:-false}"
FORCE="${FORCE:-false}"
PYTHON_VERSION=""
CUSTOM_PYTHON=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [PYTHON_VERSION]

Description:
  Installs pre-commit (framework for managing multi-language git pre-commit hooks)
  into an isolated user environment using uv tool with a dedicated Python runtime.
  The binary is placed in ~/.local/bin/pre-commit.

Arguments:
  PYTHON_VERSION              Optional Python version to pin pre-commit to (default: system python3)

Options:
  -p, --python <ver>          Python version to use for pre-commit environment (default: system python3)
  -F, --force                 Force re-installation even if already installed
  --no-update, --skip-update  Skip apt update before installation
  -h, --help                  Show this help message and exit

Examples:
  $(basename "$0")                    # Installs using system python3
  $(basename "$0") -p 3.12            # Pins pre-commit to Python 3.12
  $(basename "$0") 3.12               # Pins pre-commit to Python 3.12
  $(basename "$0") -F                 # Force re-installs pre-commit
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
        -p|--python)
            if [[ $# -ge 2 ]]; then
                PYTHON_VERSION="$2"
                CUSTOM_PYTHON=true
                shift 2
            else
                echo "Error: --python requires a version argument" >&2
                exit 1
            fi
            ;;
        --python=*)
            PYTHON_VERSION="${1#*=}"
            CUSTOM_PYTHON=true
            shift
            ;;
        python[0-9]*|[0-9]*)
            raw_ver="$1"
            ver="${raw_ver#python}"
            PYTHON_VERSION="${ver#-}"
            CUSTOM_PYTHON=true
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            show_help >&2
            exit 1
            ;;
    esac
done

# If a custom Python version was explicitly requested, force re-installation with that runtime
if [[ "$CUSTOM_PYTHON" == "true" ]]; then
    FORCE=true
fi

# Fast-path self-check (bypassed if FORCE=true)
is_installed "pre-commit" && exit 0

# Require uv package installer and target Python runtime
require_app uv

if [[ "$CUSTOM_PYTHON" == "true" ]]; then
    require_app python --args "$PYTHON_VERSION" --fast
else
    # Guarantees system python3 runtime is installed before querying its version
    require_app python --fast
    PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")' 2>/dev/null || echo "3")
fi

echo "[+] Starting installation/setup for pre-commit (Python ${PYTHON_VERSION})..."

# Ensure ~/.local/bin is present in PATH and shell startup files
ensure_local_bin_in_path

if [[ "$FORCE" == "true" ]]; then
    uv tool install --force --reinstall --python "$PYTHON_VERSION" pre-commit
else
    uv tool install --python "$PYTHON_VERSION" pre-commit
fi

echo "[✓] pre-commit setup completed successfully!"
