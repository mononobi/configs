#!/usr/bin/env bash
# Description: Enable and configure swap file based on Ubuntu version and RAM sizing formula
# Note: Implements the guidelines in enable-swap.txt for Ubuntu <= 22.04 and > 22.04.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Detects the current Ubuntu version, determines the appropriate swap size
  based on system RAM (or uses size specified via -s/--size), creates and initializes
  the swap file (/swapfile for <= 22.04, or /swap.img for > 22.04), sets secure permissions
  (600), activates swap, and configures /etc/fstab for persistence across reboots.

  Completely idempotent and safe to run multiple times.

Options:
  -s, --size <GB>       Swap size in gigabytes (e.g. 4, 8G, 16)
                        Default: calculated from system RAM based on guidelines
  -w, --swappiness <N>  Set Linux kernel swappiness (0-100) and persist to /etc/sysctl.conf
                        Default: calculated from system RAM (10 for >8GB, 30 for 2-8GB, 60 for <2GB)
  -h, --help            Show this help message and exit

Sizing Formula (when --size is omitted):
  - RAM < 2 GB   -> 2 times the amount of RAM
  - RAM 2 - 8 GB -> Equal to the amount of RAM
  - RAM > 8 GB   -> 8 GB of swap
EOF
}

CLI_SWAP_SIZE=""
SWAPPINESS=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -s|--size)
            if [[ -z "${2:-}" || "${2:-}" =~ ^- ]]; then
                echo "[!] Error: -s/--size requires an argument in GB (e.g. 4 or 8G)" >&2
                exit 1
            fi
            CLI_SWAP_SIZE="$2"
            shift 2
            ;;
        --size=*)
            CLI_SWAP_SIZE="${1#*=}"
            shift
            ;;
        -w|--swappiness)
            if [[ -z "${2:-}" || "${2:-}" =~ ^- ]]; then
                echo "[!] Error: -w/--swappiness requires an integer between 0 and 100" >&2
                exit 1
            fi
            SWAPPINESS="$2"
            shift 2
            ;;
        --swappiness=*)
            SWAPPINESS="${1#*=}"
            shift
            ;;
        *)
            echo "[!] Unknown option: $1" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
    esac
done

# Validate CLI_SWAP_SIZE if provided
if [[ -n "$CLI_SWAP_SIZE" ]]; then
    # Strip optional G/GB suffix (case-insensitive)
    CLI_SWAP_SIZE="${CLI_SWAP_SIZE%[gG][bB]}"
    CLI_SWAP_SIZE="${CLI_SWAP_SIZE%[gG]}"

    if ! [[ "$CLI_SWAP_SIZE" =~ ^[1-9][0-9]*$ ]]; then
        echo "[!] Error: Swap size must be a positive integer in GB (e.g. 4 or 8)." >&2
        exit 1
    fi
fi

# Validate SWAPPINESS if provided
if [[ -n "$SWAPPINESS" ]]; then
    if ! [[ "$SWAPPINESS" =~ ^[0-9]+$ ]] || [[ "$SWAPPINESS" -lt 0 || "$SWAPPINESS" -gt 100 ]]; then
        echo "[!] Error: Swappiness must be an integer between 0 and 100." >&2
        exit 1
    fi
fi

echo "================================================================================"
echo " Enable Swap Script"
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
    echo "    Target swap file is: ${TARGET_SWAP}"
else
    TARGET_SWAP="/swapfile"
    ALT_SWAP="/swap.img"
    echo "[+] Detected Ubuntu ${OS_VERSION} (<= 22.04)"
    echo "    Target swap file is: ${TARGET_SWAP}"
fi

# 2. Determine swap size (in GB)
if [[ -n "$CLI_SWAP_SIZE" ]]; then
    SWAP_GB="$CLI_SWAP_SIZE"
    echo "[+] Swap size specified via flag: ${SWAP_GB} GB"
else
    echo "[+] Calculating recommended swap size based on system RAM..."
    if [[ -f /proc/meminfo ]]; then
        ram_kb=$(grep -i '^MemTotal:' /proc/meminfo | awk '{print $2}')
        ram_mb=$(( ram_kb / 1024 ))
        ram_gb=$(( (ram_mb + 512) / 1024 ))
    else
        ram_mb=4096
        ram_gb=4
    fi
    echo "    Detected RAM: ~${ram_gb} GB (${ram_mb} MB)"

    if [[ $ram_mb -lt 2048 ]]; then
        # < 2 GB RAM: 2 times the amount of RAM
        SWAP_GB=$(( (ram_mb * 2 + 512) / 1024 ))
        [[ $SWAP_GB -lt 1 ]] && SWAP_GB=1
        echo "    RAM < 2 GB: Guideline recommends 2x RAM -> ${SWAP_GB} GB"
    elif [[ $ram_mb -le 8192 ]]; then
        # 2 to 8 GB RAM: same size as the amount of RAM
        SWAP_GB=$ram_gb
        [[ $SWAP_GB -lt 2 ]] && SWAP_GB=2
        echo "    RAM 2 - 8 GB: Guideline recommends 1x RAM -> ${SWAP_GB} GB"
    else
        # > 8 GB RAM: 8 GB of swap
        SWAP_GB=8
        echo "    RAM > 8 GB: Guideline recommends 8 GB -> ${SWAP_GB} GB"
    fi
    echo "    Calculated swap size: ${SWAP_GB} GB"
fi

# 3. Handle existing swap files / active swap
echo "[+] Checking existing swap..."
if grep -qs "$TARGET_SWAP" /proc/swaps 2>/dev/null || grep -qs "$ALT_SWAP" /proc/swaps 2>/dev/null; then
    echo "[+] Active swap detected. Disabling previous swap before configuring new swap..."
    if [[ -x "${SCRIPT_DIR}/disable.swap.sh" ]]; then
        "${SCRIPT_DIR}/disable.swap.sh"
    else
        sudo swapoff -a || true
        sudo rm -f "$TARGET_SWAP" "$ALT_SWAP"
    fi
elif [[ -f "$TARGET_SWAP" || -f "$ALT_SWAP" ]]; then
    echo "[+] Inactive swap file found. Cleaning up..."
    sudo rm -f "$TARGET_SWAP" "$ALT_SWAP"
fi

# 4. Allocate swap file
echo "[+] Creating ${SWAP_GB} GB swap file at ${TARGET_SWAP}..."
if command -v fallocate >/dev/null 2>&1 && sudo fallocate -l "${SWAP_GB}G" "$TARGET_SWAP" 2>/dev/null; then
    echo "    Allocated ${SWAP_GB} GB using fallocate."
else
    echo "    fallocate failed or unavailable. Allocating using dd..."
    count_mb=$(( SWAP_GB * 1024 ))
    sudo dd if=/dev/zero of="$TARGET_SWAP" bs=1M count="$count_mb" status=progress
    echo "    Allocated ${SWAP_GB} GB using dd."
fi

# 5. Set permissions
echo "[+] Setting permissions (chmod 600)..."
sudo chmod 600 "$TARGET_SWAP"

# 6. Setup swap area
echo "[+] Initializing Linux swap area (mkswap)..."
sudo mkswap "$TARGET_SWAP"

# 7. Activate swap
echo "[+] Activating swap (swapon)..."
sudo swapon "$TARGET_SWAP"

# 8. Configure /etc/fstab for persistence
echo "[+] Updating /etc/fstab for persistent swap..."
if [[ -f /etc/fstab ]]; then
    # Comment out alternate swap if present
    if grep -E "^[[:space:]]*${ALT_SWAP//./\\.}[[:space:]]" /etc/fstab >/dev/null 2>&1; then
        echo "    Commenting out legacy ${ALT_SWAP} in /etc/fstab..."
        sudo sed -i -E "s|^[[:space:]]*(${ALT_SWAP//./\\.}[[:space:]].*)$|# \1|" /etc/fstab
    fi

    # Update or append target swap entry
    if grep -E "^#?[[:space:]]*${TARGET_SWAP//./\\.}[[:space:]]" /etc/fstab >/dev/null 2>&1; then
        echo "    Updating existing entry for ${TARGET_SWAP} in /etc/fstab..."
        sudo sed -i -E "s|^#?[[:space:]]*(${TARGET_SWAP//./\\.}[[:space:]].*)$|${TARGET_SWAP}\tnone\tswap\tsw\t0\t0|" /etc/fstab
    else
        echo "    Adding entry for ${TARGET_SWAP} to /etc/fstab..."
        echo -e "${TARGET_SWAP}\tnone\tswap\tsw\t0\t0" | sudo tee -a /etc/fstab >/dev/null
    fi
else
    echo "[!] Warning: /etc/fstab does not exist."
fi

# 9. Configure swappiness
echo ""
echo "================================================================================"
echo " Swappiness Configuration"
echo "================================================================================"
current_swappiness=$(cat /proc/sys/vm/swappiness 2>/dev/null || echo "unknown")
echo "[+] Current kernel swappiness: ${current_swappiness}"

if [[ -n "$SWAPPINESS" ]]; then
    TARGET_SWAPPINESS="$SWAPPINESS"
    echo "[+] Using user-specified swappiness: ${TARGET_SWAPPINESS}"
else
    echo "[+] Calculating recommended swappiness based on system RAM..."
    if [[ $ram_mb -lt 2048 ]]; then
        TARGET_SWAPPINESS=60
        echo "    RAM < 2 GB: Retaining default swappiness 60 (proactive swapping to prevent OOM)."
    elif [[ $ram_mb -le 8192 ]]; then
        TARGET_SWAPPINESS=30
        echo "    RAM 2 - 8 GB: Setting balanced swappiness 30."
    else
        TARGET_SWAPPINESS=10
        echo "    RAM > 8 GB: Setting low swappiness 10 (prioritizes physical RAM, swap acts as safety net)."
    fi
    echo "    Calculated recommended swappiness: ${TARGET_SWAPPINESS}"
fi

echo "[+] Setting swappiness to ${TARGET_SWAPPINESS}..."
sudo sysctl vm.swappiness="$TARGET_SWAPPINESS"
if [[ -f /etc/sysctl.conf ]]; then
    if grep -E "^#?[[:space:]]*vm\.swappiness[[:space:]]*=" /etc/sysctl.conf >/dev/null 2>&1; then
        sudo sed -i -E "s|^#?[[:space:]]*vm\.swappiness[[:space:]]*=.*$|vm.swappiness=${TARGET_SWAPPINESS}|" /etc/sysctl.conf
    else
        echo "vm.swappiness=${TARGET_SWAPPINESS}" | sudo tee -a /etc/sysctl.conf >/dev/null
    fi
    echo "    Swappiness persisted to /etc/sysctl.conf across reboots."
fi

# 10. Verify swap status
echo ""
echo "================================================================================"
echo " Swap Verification"
echo "================================================================================"
echo "[+] Active swap (swapon --show):"
sudo swapon --show

echo ""
echo "[+] Memory status (free -h):"
free -h

echo ""
echo "================================================================================"
echo "[✓] Swap enabled successfully (${SWAP_GB} GB on ${TARGET_SWAP}, swappiness=${TARGET_SWAPPINESS})!"
echo "================================================================================"
