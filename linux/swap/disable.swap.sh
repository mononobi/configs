#!/usr/bin/env bash
# Description: Disable and remove swap file based on Ubuntu version
# Note: Implements the guidelines in disable-swap.txt for Ubuntu <= 22.04 and > 22.04.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Detects the current Ubuntu version, turns off active swap, comments out the
  swap entry in /etc/fstab, removes the swap file (/swapfile for <= 22.04,
  or /swap.img for > 22.04), and verifies the final swap status.

  Completely idempotent and safe to run multiple times.

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
        --no-update|--skip-update)
            shift
            ;;
        *)
            echo "[!] Unknown option: $1" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
    esac
done

echo "================================================================================"
echo " Disable Swap Script"
echo "================================================================================"

# 1. Detect Ubuntu version
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS_VERSION="${VERSION_ID:-}"
elif command -v lsb_release >/dev/null 2>&1; then
    OS_VERSION="$(lsb_release -rs)"
else
    OS_VERSION="24.04"
fi

MAJOR_MINOR="$(echo "$OS_VERSION" | cut -d. -f1,2)"

if dpkg --compare-versions "$MAJOR_MINOR" gt "22.04" 2>/dev/null; then
    TARGET_SWAP="/swap.img"
    ALT_SWAP="/swapfile"
    echo "[+] Detected Ubuntu ${OS_VERSION} (> 22.04)"
    echo "    Primary swap file is: ${TARGET_SWAP}"
else
    TARGET_SWAP="/swapfile"
    ALT_SWAP="/swap.img"
    echo "[+] Detected Ubuntu ${OS_VERSION} (<= 22.04)"
    echo "    Primary swap file is: ${TARGET_SWAP}"
fi

# 2. Disable active swap
for swap_path in "$TARGET_SWAP" "$ALT_SWAP"; do
    if grep -qs "$swap_path" /proc/swaps 2>/dev/null; then
        echo "[+] Disabling active swap on ${swap_path}..."
        sudo swapoff -v "$swap_path"
    fi
done

# If any other swap is still active, disable all
if [[ -f /proc/swaps ]] && [[ $(wc -l < /proc/swaps) -gt 1 ]]; then
    echo "[+] Disabling all remaining active swap..."
    sudo swapoff -a
fi

# 3. Comment out swap entry in /etc/fstab
echo "[+] Checking /etc/fstab..."
if [[ -f /etc/fstab ]]; then
    # Comment out un-commented swap lines for both target and alt swap files
    if grep -E "^[[:space:]]*${TARGET_SWAP//./\\.}[[:space:]]" /etc/fstab >/dev/null 2>&1; then
        echo "[+] Commenting out ${TARGET_SWAP} in /etc/fstab..."
        sudo sed -i -E "s|^[[:space:]]*(${TARGET_SWAP//./\\.}[[:space:]].*)$|# \1|" /etc/fstab
    fi

    if grep -E "^[[:space:]]*${ALT_SWAP//./\\.}[[:space:]]" /etc/fstab >/dev/null 2>&1; then
        echo "[+] Commenting out legacy ${ALT_SWAP} in /etc/fstab..."
        sudo sed -i -E "s|^[[:space:]]*(${ALT_SWAP//./\\.}[[:space:]].*)$|# \1|" /etc/fstab
    fi
fi

# 4. Remove the swap file(s)
for swap_path in "$TARGET_SWAP" "$ALT_SWAP"; do
    if [[ -f "$swap_path" ]]; then
        echo "[+] Deleting swap file: ${swap_path}..."
        sudo rm -f "$swap_path"
    fi
done

# 5. Verify swap status
echo ""
echo "================================================================================"
echo " Swap Verification"
echo "================================================================================"
echo "[+] Active swap (swapon --show):"
active_swap=$(sudo swapon --show || true)
if [[ -z "$active_swap" ]]; then
    echo "    None (swap successfully disabled)"
else
    echo "$active_swap"
fi

echo ""
echo "[+] Memory status (free -h):"
free -h

echo ""
echo "================================================================================"
echo "[✓] Swap disabling completed successfully!"
echo "================================================================================"
