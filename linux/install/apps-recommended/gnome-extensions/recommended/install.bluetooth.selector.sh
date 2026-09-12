#!/usr/bin/env bash
# Description: Install and enable Bluetooth Quick Connect GNOME Shell extension
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
  Installs and enables Bluetooth Quick Connect
  (UUID: bluetooth-quick-connect@bjarosze.gmail.com), allowing quick connecting/disconnecting
  of paired bluetooth devices from the system menu.

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

UUID="bluetooth-quick-connect@bjarosze.gmail.com"
NAME="Bluetooth Quick Connect"

install_gnome_extension "${UUID}" "${NAME}"

# Apply recommended settings
schema_dir=""
for d in \
    "${HOME}/.local/share/gnome-shell/extensions/${UUID}/schemas" \
    "/usr/share/gnome-shell/extensions/${UUID}/schemas" \
    "${HOME}/.local/share/glib-2.0/schemas" \
    "/usr/share/glib-2.0/schemas"; do
    if [[ -f "${d}/org.gnome.shell.extensions.bluetooth-quick-connect.gschema.xml" ]]; then
        schema_dir="$d"
        break
    fi
done

gset=(gsettings)
if [[ -n "$schema_dir" ]]; then
    glib-compile-schemas "$schema_dir" 2>/dev/null || true
    gset+=(--schemadir "$schema_dir")
fi

if "${gset[@]}" list-keys org.gnome.shell.extensions.bluetooth-quick-connect >/dev/null 2>&1; then
    echo "[+] Configuring Bluetooth Quick Connect settings..."
    "${gset[@]}" set org.gnome.shell.extensions.bluetooth-quick-connect keep-menu-on-toggle true 2>/dev/null || true
    "${gset[@]}" set org.gnome.shell.extensions.bluetooth-quick-connect show-battery-value-on true 2>/dev/null || true
    "${gset[@]}" set org.gnome.shell.extensions.bluetooth-quick-connect show-battery-icon-on true 2>/dev/null || true
fi
