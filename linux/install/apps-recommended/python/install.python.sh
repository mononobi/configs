#!/usr/bin/env bash
# Description: Install and configure Python versions (from 3.8 up to latest stable)
# Note: Installs Python runtimes with -dev and -full packages; links default python
# to python3 if not already present. Checks each component (runtime, -dev, -full) independently.
# Only installs stable Python versions (filters out pre-release alpha/beta/rc tags).

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
  version (e.g. 3.14). Excludes pre-release / development versions (e.g. alpha, beta, rc).
  For each version, the runtime, development package (-dev), and complete runtime
  (-full / -venv) are checked and installed independently. Configures default
  /usr/bin/python and /usr/bin/python-config symlinks to point to python3
  if they do not already exist, without requiring python3-is-python.

Arguments:
  VERSIONS              Optional specific Python version(s) to install (e.g. 3.12 3.14).
                        Default: all stable versions from 3.8 up to latest stable in repo.

Options:
  --fast                Quickly check if base Python runtime is installed and exit immediately
  --no-update           Skip apt update before installation
  -f, --force           Force installation even if already installed
  -h, --help            Show this help message and exit

Examples:
  $(basename "$0")              # Installs 3.8 through latest stable (e.g. 3.14)
  $(basename "$0") --fast       # Fast-exits if base python3 runtime is already installed
  $(basename "$0") 3.12         # Installs runtime, dev, and full packages for Python 3.12
  $(basename "$0") 3.12 --fast  # Fast-exits if base python3.12 runtime is already installed
EOF
}

# Helper: check whether a python package candidate is a stable release
# (excludes pre-release versions with letters, tildes, alpha/beta/rc tags in upstream version)
is_stable_python_package() {
    local pkg="$1"
    local raw_ver
    raw_ver=$(apt-cache madison "$pkg" 2>/dev/null | awk -F'|' 'NR==1 {gsub(/ /, "", $2); ver=$2} END {print ver}')
    [[ -z "$raw_ver" ]] && return 1

    local upstream="${raw_ver%%-*}"
    upstream="${upstream#*:}"

    if [[ "$upstream" =~ ^[0-9]+(\.[0-9]+)+$ ]]; then
        return 0
    fi
    return 1
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
if [[ "$FAST" == "true" ]]; then
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

# Determine target versions (filtering out any unstable pre-release versions)
TARGET_VERSIONS=()
if [[ ${#CUSTOM_VERSIONS[@]} -gt 0 ]]; then
    for ver in "${CUSTOM_VERSIONS[@]}"; do
        if [[ "$ver" == "3" ]]; then
            TARGET_VERSIONS+=("$ver")
        elif is_stable_python_package "python${ver}"; then
            TARGET_VERSIONS+=("$ver")
        else
            raw_ver=$(apt-cache madison "python${ver}" 2>/dev/null | awk -F'|' 'NR==1 {gsub(/ /, "", $2); ver=$2} END {print ver}')
            if [[ -n "$raw_ver" ]]; then
                echo "[!] Skipping pre-release/unstable Python version: ${ver}"
            elif [[ "$ver" =~ ^[0-9]+(\.[0-9]+)*$ ]]; then
                TARGET_VERSIONS+=("$ver")
            else
                echo "[!] Skipping invalid/unstable Python version: ${ver}"
            fi
        fi
    done
else
    # Target versions starting from 3.8 up to the highest available stable release
    MAX_MINOR=14
    for (( m=15; m<=25; m++ )); do
        if is_stable_python_package "python3.${m}"; then
            MAX_MINOR="$m"
        else
            break
        fi
    done

    for (( m=8; m<=MAX_MINOR; m++ )); do
        TARGET_VERSIONS+=("3.$m")
    done
fi

if [[ ${#TARGET_VERSIONS[@]} -eq 0 ]]; then
    echo "[!] No valid stable Python versions specified or found."
    exit 1
fi

# Fast-path check for full installation: check if all components are already installed
if [[ "$FORCE" != "true" ]]; then
    all_installed=true
    for ver in "${TARGET_VERSIONS[@]}"; do
        if ! is_installed --check "python${ver}" || \
           ! is_installed --check "python${ver}-dev" || \
           (has_apt_candidate "python${ver}-full" && ! is_installed --check "python${ver}-full") || \
           (has_apt_candidate "python${ver}-venv" && ! is_installed --check "python${ver}-venv"); then
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

# Re-evaluate latest stable minor from deadsnakes PPA if using default versions
if [[ ${#CUSTOM_VERSIONS[@]} -eq 0 ]]; then
    for (( m=MAX_MINOR+1; m<=25; m++ )); do
        if is_stable_python_package "python3.${m}"; then
            MAX_MINOR="$m"
            TARGET_VERSIONS+=("3.$m")
        else
            break
        fi
    done
fi

echo "[+] Target Python versions to process: ${TARGET_VERSIONS[*]}"

# 3. Assemble package list for each version by checking each component independently
PKGS=()
for ver in "${TARGET_VERSIONS[@]}"; do
    # Component A: Base runtime
    if ! is_installed "python${ver}"; then
        if has_apt_candidate "python${ver}"; then
            PKGS+=("python${ver}")
        fi
    fi

    # Component B: Development headers (-dev)
    if ! is_installed "python${ver}-dev"; then
        if has_apt_candidate "python${ver}-dev"; then
            PKGS+=("python${ver}-dev")
        fi
    fi

    # Component C: Full environment (-full)
    if ! is_installed "python${ver}-full"; then
        if has_apt_candidate "python${ver}-full"; then
            PKGS+=("python${ver}-full")
        fi
    fi

    # Component D: Virtual environment (-venv)
    if ! is_installed "python${ver}-venv"; then
        if has_apt_candidate "python${ver}-venv"; then
            PKGS+=("python${ver}-venv")
        fi
    fi

    # Component E: Distutils (only for legacy Python versions <= 3.11 where distutils existed)
    minor="${ver#3.}"
    if [[ "$ver" != "3" && "$minor" =~ ^[0-9]+$ && "$minor" -le 11 ]]; then
        if has_apt_candidate "python${ver}-distutils"; then
            if ! is_installed "python${ver}-distutils"; then
                PKGS+=("python${ver}-distutils")
            fi
        fi
    fi
done

# General tools (pip, venv, setuptools), but NOT python3-is-python
GENERAL_PKGS=()
for pkg in "python3" "python3-dev" "python3-pip" "python3-venv" "python3-setuptools"; do
    if ! is_installed "$pkg"; then
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

# 4. Point /usr/bin/python and /usr/bin/python-config to python3 only if not already present
if [[ ! -e "/usr/bin/python" && ! -L "/usr/bin/python" ]]; then
    if [[ -x "/usr/bin/python3" ]]; then
        echo "[+] Configuring default /usr/bin/python -> /usr/bin/python3..."
        sudo ln -s "/usr/bin/python3" /usr/bin/python
    fi
fi

if [[ ! -e "/usr/bin/python-config" && ! -L "/usr/bin/python-config" ]]; then
    if [[ -f "/usr/bin/python3-config" ]]; then
        echo "[+] Configuring default /usr/bin/python-config -> /usr/bin/python3-config..."
        sudo ln -s "/usr/bin/python3-config" /usr/bin/python-config
    fi
fi

# 5. Verify installation and print accurate report
echo "[+] Verification:"
python --version
pip3 --version || true

VERIFIED_VERSIONS=()
for ver in "${TARGET_VERSIONS[@]}"; do
    if is_installed --check "python${ver}"; then
        VERIFIED_VERSIONS+=("${ver}")
    fi
done

if [[ ${#VERIFIED_VERSIONS[@]} -gt 0 ]]; then
    echo "[✓] Successfully installed and verified Python versions: ${VERIFIED_VERSIONS[*]}"
fi
