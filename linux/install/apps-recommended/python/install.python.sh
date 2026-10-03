#!/usr/bin/env bash
# Description: Install and configure Python versions (from 3.8 up to latest stable)
# Note: Installs Python runtimes with -dev and -full packages; links default python
# without python3-is-python. Checks each component (runtime, -dev, -full) independently.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

CUSTOM_VERSIONS=()
FAST=false
FORCE="${FORCE:-false}"
SKIP_UPDATE="${SKIP_UPDATE:-false}"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [VERSIONS...]

Description:
  Installs Python versions starting from 3.8, 3.9 up to current latest stable
  version (e.g. 3.14). For each version, the runtime, development package (-dev),
  and complete runtime (-full / -venv) are checked and installed independently.
  Configures default /usr/bin/python and /usr/bin/python-config symlinks to point
  to the latest installed Python version without requiring python3-is-python.

Arguments:
  VERSIONS              Optional specific Python version(s) to install (e.g. 3.12 3.14).
                        Default: all versions from 3.8 up to latest available in repo.

Options:
  --fast                Quickly check if base Python runtime is installed and exit immediately
  --no-update           Skip apt update before installation
  -f, --force           Force installation even if already installed
  -h, --help            Show this help message and exit

Examples:
  $(basename "$0")              # Installs 3.8 through latest and links python
  $(basename "$0") --fast       # Fast-exits if base python3 runtime is already installed
  $(basename "$0") 3.12         # Installs runtime, dev, and full packages for Python 3.12
  $(basename "$0") 3.12 --fast  # Fast-exits if base python3.12 runtime is already installed
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        --fast)
            FAST=true
            shift
            ;;
        --no-update|--skip-update)
            SKIP_UPDATE=true
            shift
            ;;
        python[0-9]*|python-[0-9]*|python|[0-9]*)
            raw_ver="$1"
            ver="${raw_ver#python}"
            ver="${ver#-}"
            [[ -z "$ver" ]] && ver="3"
            CUSTOM_VERSIONS+=("$ver")
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

# Fast-path check: if --fast is specified, only check base runtime binary and exit
if [[ "$FAST" == "true" && "$FORCE" != "true" ]]; then
    if [[ ${#CUSTOM_VERSIONS[@]} -gt 0 ]]; then
        missing_versions=()
        for ver in "${CUSTOM_VERSIONS[@]}"; do
            if ! is_installed "python${ver}"; then
                missing_versions+=("$ver")
            fi
        done

        if [[ ${#missing_versions[@]} -eq 0 ]]; then
            exit 0
        fi

        # Narrow custom versions to only those missing the base runtime
        CUSTOM_VERSIONS=("${missing_versions[@]}")
    else
        is_installed "python3" && exit 0
    fi
fi

# Determine target versions
TARGET_VERSIONS=()
if [[ ${#CUSTOM_VERSIONS[@]} -gt 0 ]]; then
    TARGET_VERSIONS=("${CUSTOM_VERSIONS[@]}")
else
    # Target versions from 3.8 up to at least 3.14 (or higher if newer exists)
    MAX_MINOR=14
    DETECTED_MAX=$(
        apt-cache search "^python3\.[0-9]+$" 2>/dev/null | awk '{print $1}' \
            | grep -Po '3\.\K[0-9]+' | sort -n | tail -1 || true
    )
    if [[ -n "$DETECTED_MAX" ]] && (( DETECTED_MAX > MAX_MINOR )); then
        MAX_MINOR="$DETECTED_MAX"
    fi

    for (( m=8; m<=MAX_MINOR; m++ )); do
        TARGET_VERSIONS+=("3.$m")
    done
fi

# Fast-path check for full installation: check if all components are already installed
if [[ "$FORCE" != "true" ]]; then
    all_installed=true
    for ver in "${TARGET_VERSIONS[@]}"; do
        if ! is_installed --check "python${ver}" || \
           ! is_installed --check "python${ver}-dev" || \
           (! is_installed --check "python${ver}-full" && ! is_installed --check "python${ver}-venv"); then
            all_installed=false
            break
        fi
    done

    for pkg in "python3" "python3-dev" "python3-pip" "python3-venv" "python3-setuptools"; do
        if ! is_installed --check "$pkg"; then
            all_installed=false
            break
        fi
    done

    if [[ "$all_installed" == "true" ]]; then
        echo "[i] All components for Python (${TARGET_VERSIONS[*]}) are already installed, skipping..."
        exit 0
    fi
fi

echo "[+] Starting installation/setup for Python toolchains..."

# 1. Update system and install essential prerequisites
require_app software-properties-common ca-certificates curl build-essential

# 2. Add deadsnakes PPA for multi-version Python support
echo "[+] Adding deadsnakes PPA..."
sudo add-apt-repository -y -n ppa:deadsnakes/ppa
sudo apt-get update

echo "[+] Target Python versions to process: ${TARGET_VERSIONS[*]}"

# 3. Assemble package list for each version by checking each component independently
PKGS=()
for ver in "${TARGET_VERSIONS[@]}"; do
    # Component A: Base runtime
    if [[ "$FORCE" == "true" ]] || ! is_installed --check "python${ver}"; then
        if has_apt_candidate "python${ver}"; then
            PKGS+=("python${ver}")
        fi
    fi

    # Component B: Development headers (-dev)
    if [[ "$FORCE" == "true" ]] || ! is_installed --check "python${ver}-dev"; then
        if has_apt_candidate "python${ver}-dev"; then
            PKGS+=("python${ver}-dev")
        fi
    fi

    # Component C: Full environment / venv
    if [[ "$FORCE" == "true" ]] || (! is_installed --check "python${ver}-full" && ! is_installed --check "python${ver}-venv"); then
        if has_apt_candidate "python${ver}-full"; then
            PKGS+=("python${ver}-full")
        elif has_apt_candidate "python${ver}-venv"; then
            PKGS+=("python${ver}-venv")
        fi
    fi

    # Component D: Distutils (only for legacy Python versions <= 3.11 where distutils existed)
    minor="${ver#3.}"
    if [[ "$ver" != "3" && "$minor" =~ ^[0-9]+$ && "$minor" -le 11 ]]; then
        if has_apt_candidate "python${ver}-distutils"; then
            if [[ "$FORCE" == "true" ]] || ! is_installed --check "python${ver}-distutils"; then
                PKGS+=("python${ver}-distutils")
            fi
        fi
    fi
done

# General tools (pip, venv, setuptools), but NOT python3-is-python
GENERAL_PKGS=()
for pkg in "python3" "python3-dev" "python3-pip" "python3-venv" "python3-setuptools"; do
    if [[ "$FORCE" == "true" ]] || ! is_installed --check "$pkg"; then
        if has_apt_candidate "$pkg"; then
            GENERAL_PKGS+=("$pkg")
        fi
    fi
done

TO_INSTALL=()
# Deduplicate packages
for p in "${PKGS[@]}" "${GENERAL_PKGS[@]}"; do
    if [[ ! " ${TO_INSTALL[*]:-} " =~ " ${p} " ]]; then
        TO_INSTALL+=("$p")
    fi
done

if [[ ${#TO_INSTALL[@]} -gt 0 ]]; then
    echo "[+] Installing missing Python packages: ${TO_INSTALL[*]}..."
    sudo apt-get install -y "${TO_INSTALL[@]}"
else
    echo "[+] All components for target Python versions and tools are already installed."
fi

# 4. Point /usr/bin/python and /usr/bin/python-config to the highest installed Python version on the system
HIGHEST_INSTALLED_MINOR=$(
    find /usr/bin -maxdepth 1 \( -name "python3.[0-9]*" ! -name "*config*" ! -name "*m" \) 2>/dev/null \
        | grep -Po "python3\.\K[0-9]+$" | sort -n | tail -1 || true
)

if [[ -n "$HIGHEST_INSTALLED_MINOR" && -x "/usr/bin/python3.${HIGHEST_INSTALLED_MINOR}" ]]; then
    LATEST_SYSTEM_VER="3.${HIGHEST_INSTALLED_MINOR}"
elif command -v python3 >/dev/null 2>&1; then
    LATEST_SYSTEM_VER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")' 2>/dev/null || echo "3")
else
    LATEST_SYSTEM_VER=""
fi

if [[ -n "$LATEST_SYSTEM_VER" ]]; then
    echo "[+] Configuring default /usr/bin/python -> /usr/bin/python${LATEST_SYSTEM_VER}..."
    sudo ln -sf "/usr/bin/python${LATEST_SYSTEM_VER}" /usr/bin/python

    if [[ -f "/usr/bin/python${LATEST_SYSTEM_VER}-config" ]]; then
        echo "[+] Configuring /usr/bin/python-config -> /usr/bin/python${LATEST_SYSTEM_VER}-config..."
        sudo ln -sf "/usr/bin/python${LATEST_SYSTEM_VER}-config" /usr/bin/python-config
    fi
fi

# 5. Verify installation
echo "[+] Verification:"
python --version
pip3 --version || true

echo "[✓] Python versions (${TARGET_VERSIONS[*]}) setup completed successfully!"
