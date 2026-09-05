#!/usr/bin/env bash
# Description: Install and configure Python versions (from 3.8 up to latest stable)
# Note: Installs Python runtimes with -dev and -full packages; links default python without python3-is-python.

set -euo pipefail

CUSTOM_VERSIONS=()

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [VERSIONS...]

Description:
  Installs Python versions starting from 3.8, 3.9 up to the current latest stable version (e.g. 3.14).
  For each version, both the development package (-dev) and the complete runtime (-full) are installed.
  Configures the default /usr/bin/python and /usr/bin/python-config symlinks to point to the latest
  installed Python version without requiring the python3-is-python package.

Arguments:
  VERSIONS              Optional specific Python version(s) to install (e.g. 3.12 3.14).
                        Default: all versions from 3.8 up to the latest available in repository.

Options:
  -h, --help            Show this help message and exit

Examples:
  $(basename "$0")              # Installs 3.8 through latest (e.g. 3.14) and links python to latest
  $(basename "$0") 3.12 3.14    # Installs only Python 3.12 and 3.14
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        [0-9]*)
            CUSTOM_VERSIONS+=("$1")
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

echo "[+] Starting installation/setup for Python toolchains..."

# 1. Update system and install essential prerequisites
sudo apt-get update
sudo apt-get install -y software-properties-common ca-certificates curl build-essential

# 2. Add deadsnakes PPA for multi-version Python support
echo "[+] Adding deadsnakes PPA..."
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt-get update

# 3. Determine target versions
TARGET_VERSIONS=()
if [[ ${#CUSTOM_VERSIONS[@]} -gt 0 ]]; then
    TARGET_VERSIONS=("${CUSTOM_VERSIONS[@]}")
else
    # Target versions from 3.8 up to at least 3.14 (or higher if newer exists)
    MAX_MINOR=14
    DETECTED_MAX=$(apt-cache search "^python3\.[0-9]+$" | awk '{print $1}' | grep -Po '3\.\K[0-9]+' | sort -n | tail -1)
    if [[ -n "$DETECTED_MAX" ]] && (( DETECTED_MAX > MAX_MINOR )); then
        MAX_MINOR="$DETECTED_MAX"
    fi

    for (( m=8; m<=MAX_MINOR; m++ )); do
        TARGET_VERSIONS+=("3.$m")
    done
fi

echo "[+] Target Python versions to install: ${TARGET_VERSIONS[*]}"

# 4. Assemble package list for each version (runtime, -dev, -full)
PKGS=()
for ver in "${TARGET_VERSIONS[@]}"; do
    PKGS+=("python${ver}" "python${ver}-dev")

    if apt-cache show "python${ver}-full" >/dev/null 2>&1; then
        PKGS+=("python${ver}-full")
    else
        PKGS+=("python${ver}-venv")
    fi

    if apt-cache show "python${ver}-distutils" >/dev/null 2>&1; then
        PKGS+=("python${ver}-distutils")
    fi
done

# Also install general tools (pip, venv), but NOT python3-is-python
PKGS+=("python3-pip" "python3-venv" "python3-setuptools")

echo "[+] Installing packages..."
sudo apt-get install -y "${PKGS[@]}"

# 5. Point /usr/bin/python and /usr/bin/python-config to the latest installed version
LATEST_VER="${TARGET_VERSIONS[-1]}"
echo "[+] Configuring default /usr/bin/python -> /usr/bin/python${LATEST_VER}..."
sudo ln -sf "/usr/bin/python${LATEST_VER}" /usr/bin/python

if [[ -f "/usr/bin/python${LATEST_VER}-config" ]]; then
    echo "[+] Configuring default /usr/bin/python-config -> /usr/bin/python${LATEST_VER}-config..."
    sudo ln -sf "/usr/bin/python${LATEST_VER}-config" /usr/bin/python-config
fi

# 6. Verify installation
echo "[+] Verification:"
python --version
pip3 --version || true

echo "[✓] Python versions (${TARGET_VERSIONS[*]}) setup completed successfully!"
