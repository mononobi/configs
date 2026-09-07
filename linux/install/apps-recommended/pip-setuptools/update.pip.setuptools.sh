#!/usr/bin/env bash
# Description: Install and configure pip-setuptools
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

TARGET_PYTHON=""

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [PYTHON_VERSION_OR_PATH]

Description:
  Upgrades pip, setuptools, and wheel for the latest installed non-system Python version
  (avoiding PEP 668 system environment conflicts with Ubuntu's default python3).

Arguments:
  PYTHON_VERSION_OR_PATH  Optional specific Python version or executable to target (e.g. 3.13, python3.13).
                          Default: automatically detects the highest installed non-system Python.

Options:
  --no-update             Skip apt update before installation
  -h, --help              Show this help message and exit
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
        -*)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
        *)
            TARGET_PYTHON="$1"
            shift
            ;;
    esac
done

echo "[+] Starting installation/setup for pip-setuptools..."

SYSTEM_PY=$(readlink -f /usr/bin/python3)

if [[ -n "$TARGET_PYTHON" ]]; then
    if [[ "$TARGET_PYTHON" =~ ^[0-9]+\.[0-9]+$ ]]; then
        TARGET_PYTHON="python${TARGET_PYTHON}"
    fi
    if ! command -v "$TARGET_PYTHON" >/dev/null 2>&1; then
        echo "[!] Error: Specified Python executable '$TARGET_PYTHON' not found."
        exit 1
    fi
    TARGET_PYTHON=$(command -v "$TARGET_PYTHON")
else
    # Find all installed pythonX.Y binaries
    CANDIDATES=()
    for bin in /usr/bin/python[0-9]*.[0-9]* /usr/local/bin/python[0-9]*.[0-9]*; do
        [[ -x "$bin" ]] || continue
        bname=$(basename "$bin")
        [[ "$bname" =~ ^python[0-9]+\.[0-9]+$ ]] || continue

        real_path=$(readlink -f "$bin")
        if [[ "$real_path" != "$SYSTEM_PY" ]]; then
            CANDIDATES+=("$bin")
        fi
    done

    if [[ ${#CANDIDATES[@]} -eq 0 ]]; then
        echo "[!] Error: No non-system Python installation found in /usr/bin or /usr/local/bin."
        echo "[!] System Python ($SYSTEM_PY) is protected by OS package manager."
        echo "[!] Please install an alternative Python version (e.g. using install.python.sh) first."
        exit 1
    fi

    TARGET_PYTHON=$(printf "%s\n" "${CANDIDATES[@]}" | sort -V -u | tail -n 1)
fi

REAL_TARGET=$(readlink -f "$TARGET_PYTHON")
if [[ "$REAL_TARGET" == "$SYSTEM_PY" ]]; then
    echo "[!] Error: Target Python ($REAL_TARGET) is the system default python3."
    echo "[!] Modifying system Python site-packages can break OS package management."
    exit 1
fi

echo "[+] System Python default: $SYSTEM_PY"
echo "[+] Target Python: $TARGET_PYTHON ($("$TARGET_PYTHON" --version))"

if ! "$TARGET_PYTHON" -m pip --version >/dev/null 2>&1; then
    echo "[+] Bootstrapping pip for $TARGET_PYTHON..."
    "$TARGET_PYTHON" -m ensurepip --upgrade
fi

echo "[+] Upgrading pip, setuptools, and wheel for $TARGET_PYTHON..."
"$TARGET_PYTHON" -m pip install --upgrade pip setuptools wheel

echo "[+] Verifying updated packages:"
"$TARGET_PYTHON" -m pip --version

echo "[✓] pip-setuptools setup completed successfully for $TARGET_PYTHON!"
