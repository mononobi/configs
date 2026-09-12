#!/usr/bin/env bash
# Description: Batch installer for server applications and dependencies
# Note: Calls apt update once, ensures ~/.local/bin is in PATH, and installs apps defined in SERVER_APPS using require_app.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils.sh"

# ==============================================================================
# Server Applications List
# Add or remove application names here (they will be resolved via require_app).
# NOTE: Do NOT use commas! Bash arrays are separated by newlines or spaces.
# ==============================================================================
SERVER_APPS=(
    "docker"
    "git"
    "ufw"
    "curl"
    "cloc"
    "g++"
    "gcc"
    "htop"
    "memcached"
    "net-tools"
    "nethogs"
    "nginx"
    "node.js"
    "openvpn"
    "pass"
    "python"
    "virtualenv"
    "pip-setuptools"
    "pipenv"
    "poetry"
    "redis"
    "speedtest"
    "syslog"
    "vim"
    "conduit-node"
    "commands"
    "disable-swap"
)

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [APP_NAMES...]

Description:
  Batch installer for server applications.
  Ensures ~/.local/bin is in PATH, runs apt update once, and sequentially installs
  applications defined in the SERVER_APPS list (or passed as command-line arguments)
  using require_app from utils.sh.

Arguments:
  APP_NAMES             Optional extra or specific application name(s) to install.
                        If provided, these are appended to the SERVER_APPS list.

Options:
  --no-update           Skip upfront apt update before installation
  -h, --help            Show this help message and exit

Examples:
  $(basename "$0")                  # Installs apps defined in SERVER_APPS array
  $(basename "$0") docker git       # Installs SERVER_APPS plus docker and git
  $(basename "$0") --no-update      # Installs without running apt update upfront
EOF
}

SKIP_UPDATE=false
CLI_APPS=()

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
            echo "[!] Unknown option: $1" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
        *)
            CLI_APPS+=("$1")
            shift
            ;;
    esac
done

# Prevent running as root or via sudo to ensure apps are installed in the actual user's $HOME
if [[ $EUID -eq 0 ]] || [[ -n "${SUDO_USER:-}" ]]; then
    echo "[!] Error: Do not run $(basename "$0") as root or with sudo." >&2
    echo "    Application installers configure local tools and user assets directly in \$HOME." >&2
    echo "    Subscripts will automatically invoke sudo internally when root privileges are required." >&2
    echo "    Please run as your regular user: $(basename "$0")" >&2
    exit 1
fi

# Combine predefined list with any command-line specified applications
APPS_TO_INSTALL=("${SERVER_APPS[@]}" "${CLI_APPS[@]}")

# Filter out empty entries
FILTERED_APPS=()
for app in "${APPS_TO_INSTALL[@]}"; do
    [[ -n "$app" ]] && FILTERED_APPS+=("$app")
done
APPS_TO_INSTALL=("${FILTERED_APPS[@]}")

if [[ ${#APPS_TO_INSTALL[@]} -eq 0 ]]; then
    echo "[!] No applications to install."
    echo "    Add application names to the 'SERVER_APPS' array inside $(basename "$0"),"
    echo "    or pass them as arguments: $(basename "$0") <app1> <app2> ..."
    exit 0
fi

echo "================================================================================"
echo " Starting Server Applications Batch Installer"
echo " Applications to install: ${APPS_TO_INSTALL[*]}"
echo "================================================================================"

# Initialize sudo credentials
echo "[+] Initializing sudo credentials..."
sudo -v

# Keep sudo timestamp updated in background every 60 seconds
sudo_keepalive_pid=""
cleanup() {
    if [[ -n "$sudo_keepalive_pid" ]]; then
        kill "$sudo_keepalive_pid" 2>/dev/null || true
    fi
}
trap cleanup EXIT INT TERM

while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" 2>/dev/null || exit
done < /dev/null > /dev/null 2>&1 &
sudo_keepalive_pid=$!

# 1. Ensure ~/.local/bin exists and is permanently added to PATH
echo "[+] Ensuring ~/.local/bin is present and configured in PATH..."
ensure_local_bin_in_path

# 2. Run apt update once before batch installation
if [[ "$SKIP_UPDATE" != "true" ]]; then
    echo "[+] Running apt update once before installing server applications..."
    sudo apt-get update
fi

# Export SKIP_UPDATE=true so require_app passes --no-update to child installers
export SKIP_UPDATE=true

# 3. Iterate over the application list and install each using require_app
declare -a installed_apps=()
declare -a failed_apps=()

for app in "${APPS_TO_INSTALL[@]}"; do
    app="${app%,}" # Strip trailing comma if accidentally added
    [[ -z "$app" ]] && continue
    echo ""
    echo "--------------------------------------------------------------------------------"
    echo "[==>] Installing server application: ${app}"
    echo "--------------------------------------------------------------------------------"

    if require_app "$app"; then
        echo "[✓] Successfully installed: ${app}"
        installed_apps+=("$app")
    else
        echo "[✗] Failed to install: ${app}" >&2
        failed_apps+=("$app")
    fi
done

# 4. Display Final Summary
echo ""
echo "================================================================================"
echo " Server Applications Installation Summary"
echo "================================================================================"
echo "Total processed: ${#APPS_TO_INSTALL[@]}"
echo "Installed:       ${#installed_apps[@]}"
echo "Failed:          ${#failed_apps[@]}"

if [[ ${#installed_apps[@]} -gt 0 ]]; then
    echo ""
    echo "Successfully installed applications:"
    for app in "${installed_apps[@]}"; do
        echo "  [✓] ${app}"
    done
fi

if [[ ${#failed_apps[@]} -gt 0 ]]; then
    echo ""
    echo "Failed applications:"
    for app in "${failed_apps[@]}"; do
        echo "  [✗] ${app}"
    done
    echo "================================================================================"
    exit 1
fi

echo "================================================================================"
echo "[✓] All server applications processed successfully!"
