#!/usr/bin/env bash
# Description: Install PlayStation controller support udev rules

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../../utils.sh"
SKIP_UPDATE="${SKIP_UPDATE:-false}"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs udev rules for PS3, PS4, and PS5 controllers to support emulators.

Options:
  --no-update   Skip apt update before installation
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
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

RULES_DIR="/etc/udev/rules.d"
F1="99-ds3-controllers.rules"
F2="99-ds4-controllers.rules"
F3="99-dualsense-controllers.rules"

# Idempotency check
if [[ -f "${RULES_DIR}/${F1}" ]] && cmp -s "${SCRIPT_DIR}/${F1}" "${RULES_DIR}/${F1}" && \
   [[ -f "${RULES_DIR}/${F2}" ]] && cmp -s "${SCRIPT_DIR}/${F2}" "${RULES_DIR}/${F2}" && \
   [[ -f "${RULES_DIR}/${F3}" ]] && cmp -s "${SCRIPT_DIR}/${F3}" "${RULES_DIR}/${F3}"; then
    if [[ "${FORCE:-false}" != "true" ]]; then
        echo "[i] PlayStation controller udev rules are already installed, skipping..."
        exit 0
    fi
fi

echo "[+] Starting installation for PlayStation controller udev rules..."

echo "[+] Copying udev rules to ${RULES_DIR}..."
sudo cp "${SCRIPT_DIR}/${F1}" "${RULES_DIR}/"
sudo cp "${SCRIPT_DIR}/${F2}" "${RULES_DIR}/"
sudo cp "${SCRIPT_DIR}/${F3}" "${RULES_DIR}/"

echo "[+] Reloading udev rules..."
sudo udevadm control --reload-rules

echo "------------------------------------------------------------"
echo "NOTE: Controller udev rules for PS3, PS4, and PS5 have been applied."
echo "Please disconnect and then reconnect your controller."
echo "Then, in each emulator app, go to controller settings and select your controller."
echo "------------------------------------------------------------"

echo "[✓] Controller support setup completed successfully!"
