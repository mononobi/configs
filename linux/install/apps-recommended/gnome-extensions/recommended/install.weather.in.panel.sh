#!/usr/bin/env bash
# Description: Install and enable Weather O'Clock GNOME Shell extension
# Note: Completely idempotent. Can be run standalone or invoked from batch runners.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
source "${SCRIPT_DIR}/../../../utils.sh"

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs and enables Weather O'Clock (UUID: weatheroclock@CleoMenezesJr.github.io),
  displaying current weather conditions and temperature next to the top-bar clock.
  Requires gnome-weather to be installed.

Options:
  --no-update   Skip apt update when verifying dependencies
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
            SKIP_UPDATE=true
            shift
            ;;
        *)
            echo "[!] Unknown option: $1" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
    esac
done

# Prevent running via sudo
if [[ -n "${SUDO_USER:-}" && $EUID -eq 0 ]]; then
    echo "[!] Error: Do not run $(basename "$0") with sudo." >&2
    echo "    GNOME extensions must be installed in your personal user session." >&2
    echo "    Please run as your regular user: ./$(basename "$0")" >&2
    exit 1
fi

# Require prerequisite application gnome-weather
echo "[+] Ensuring gnome-weather application dependency is installed..."
if [[ "$SKIP_UPDATE" == "true" ]]; then
    require_app "gnome-weather" "apps-recommended" --no-update
else
    require_app "gnome-weather" "apps-recommended"
fi

install_gnome_extension "weatheroclock@CleoMenezesJr.github.io" "Weather O'Clock"
