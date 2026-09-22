#!/usr/bin/env bash
# Description: Install GNOME Shell Extensions activator/manager and all recommended extensions
# Note: Idempotently orchestrates activator and all extension subfolders under recommended/.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SKIP_UPDATE="${SKIP_UPDATE:-false}"
INSTALL_ADD_TO_DESKTOP=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs the GNOME Shell Extensions Activator (Extension Manager,
  gnome-shell-extensions, browser connector, and version check bypass)
  and dynamically auto-discovers and installs all recommended extensions
  from the recommended/ subdirectories.

  Completely idempotent and safe to run repeatedly.

Options:
  --add-to-desktop  Install and enable desktop icon extensions
                    (Add to Desktop, DING; omitted by default)
  --no-update       Skip apt update before installation
  -h, --help        Show this help message and exit
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
        --add-to-desktop|--with-add-to-desktop|--include-add-to-desktop)
            INSTALL_ADD_TO_DESKTOP=true
            shift
            ;;
        *)
            echo -e "${C_RED}[!] Unknown option: $1${C_RESET}" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
    esac
done

# Prevent running via sudo to preserve user's HOME and gsettings
if [[ -n "${SUDO_USER:-}" && $EUID -eq 0 ]]; then
    echo -e "${C_RED}[!] Error: Do not run $(basename "$0") with sudo.${C_RESET}" >&2
    echo "    GNOME extensions must be installed in your personal user session." >&2
    echo "    Please run as your regular user: ./$(basename "$0")" >&2
    exit 1
fi

echo -e "${C_CYAN}${DIV_MAIN}${C_RESET}"
echo -e " ${C_BOLD}Starting Full GNOME Shell Extensions Setup${C_RESET}"
echo -e "${C_CYAN}${DIV_MAIN}${C_RESET}"

# 1. Run Activator Setup
echo -e "${C_BLUE}[+] Step 1:${C_RESET}" \
    "${C_BOLD}Ensuring GNOME Shell Extensions Activator is installed...${C_RESET}"
require_app gnome-extensions/activator

# 2. Auto-discover and install recommended extensions
echo ""
echo -e "${C_BLUE}[+] Step 2:${C_RESET}" \
    "${C_BOLD}Auto-discovering and installing recommended GNOME extensions...${C_RESET}"
for ext_dir in "${SCRIPT_DIR}/recommended"/*/; do
    [[ -d "$ext_dir" ]] || continue
    ext_name="$(basename "$ext_dir")"

    # Handle desktop extensions conditionally
    if [[ "$ext_name" == "add-to-desktop" || "$ext_name" == "desktop-icons-ng-ding" ]]; then
        if [[ "$INSTALL_ADD_TO_DESKTOP" != "true" ]]; then
            continue
        fi
    fi

    # Skip system-extensions for the dedicated final step
    if [[ "$ext_name" == "system-extensions" ]]; then
        continue
    fi

    # Respect ignore file if present in the extension folder
    if [[ -f "${ext_dir}/ignore" ]]; then
        echo -e "    ${C_YELLOW}[-] Skipping ignored extension: ${ext_name}${C_RESET}"
        continue
    fi

    require_app "gnome-extensions/recommended/${ext_name}"
done

# 3. Handle desktop extensions disabled notice if not requested
if [[ "$INSTALL_ADD_TO_DESKTOP" != "true" ]]; then
    echo ""
    echo -e "${C_YELLOW}[i] Desktop extensions disabled by default" \
        "(pass --add-to-desktop to enable).${C_RESET}"
    for desktop_ext in "add-to-desktop@tommimon.github.com" "ding@rastersoft.com"; do
        if gnome-extensions list 2>/dev/null | grep -Fxq "$desktop_ext"; then
            echo -e "    ${C_YELLOW}[-] Disabling: ${desktop_ext}...${C_RESET}"
            gnome-extensions disable "$desktop_ext" 2>/dev/null || true
        fi
    done
fi

# 4. Enable and configure built-in system extensions
echo ""
echo -e "${C_BLUE}[+] Step 3:${C_RESET}" \
    "${C_BOLD}Configuring built-in system extensions...${C_RESET}"
require_app gnome-extensions/recommended/system-extensions

echo ""
echo -e "${C_CYAN}${DIV_MAIN}${C_RESET}"
echo -e "${C_GREEN}[✓] Full GNOME Shell Extensions setup completed successfully!${C_RESET}"
echo -e "${C_CYAN}${DIV_MAIN}${C_RESET}"
