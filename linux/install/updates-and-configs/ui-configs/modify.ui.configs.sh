#!/usr/bin/env bash
# Description: Install and configure ui-configs
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Configures GNOME Desktop UI options (app icons, window buttons, workspace behavior) via gsettings.

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
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

echo "[+] Starting installation/setup for ui-configs..."

echo "[+] Configuring GNOME UI settings..."
# Show minimize, maximize, and close buttons on window titlebars
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close' || true

# Center new windows
gsettings set org.gnome.mutter center-new-windows true || true

# Show desktop icons or configure dash-to-dock if installed
echo "[+] UI preferences applied successfully."

echo "[✓] ui-configs setup completed successfully!"
