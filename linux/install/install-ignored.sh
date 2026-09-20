#!/usr/bin/env bash
# Description: Interactively prompt to install ignored applications within a category
# Note: Defaults to 'apps-recommended'. Default answer is No [y/N].

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.sh"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [CATEGORY]

Description:
  Scans ignored application folders (containing an 'ignore' file) within the
  specified category (default: apps-recommended) and interactively prompts
  to install each one. The default choice is No [y/N]. On 'y' or 'yes', the
  application installer script is executed.

Arguments:
  CATEGORY              Category directory to scan (default: apps-recommended)

Options:
  -c, --category CAT    Specify category directory (default: apps-recommended)
  --no-update           Skip upfront apt update before installation
  -h, --help            Show this help message and exit

Examples:
  $(basename "$0")                          # Prompt for ignored apps in apps-recommended
  $(basename "$0") apps-extra               # Prompt for ignored apps in apps-extra
  $(basename "$0") -c apps-recommended      # Explicit category flag
EOF
}

CATEGORY="apps-recommended"
SKIP_UPDATE="${SKIP_UPDATE:-false}"

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
        -c|--category)
            if [[ $# -ge 2 ]]; then
                CATEGORY="$2"
                shift 2
            else
                echo "[!] Error: --category requires an argument" >&2
                exit 1
            fi
            ;;
        --category=*)
            CATEGORY="${1#*=}"
            shift
            ;;
        -*)
            echo "[!] Unknown option: $1" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
        *)
            CATEGORY="$1"
            shift
            ;;
    esac
done

# Prevent running as root or via sudo
if [[ $EUID -eq 0 ]] || [[ -n "${SUDO_USER:-}" ]]; then
    echo "[!] Error: Do not run $(basename "$0") as root or with sudo." >&2
    echo "    Application installers configure local tools and user assets directly in \$HOME." >&2
    echo "    Subscripts will automatically invoke sudo internally when root privileges are required." >&2
    echo "    Please run as your regular user: $(basename "$0")" >&2
    exit 1
fi

# Resolve category directory
if [[ -d "$CATEGORY" ]]; then
    CATEGORY_DIR="$(cd "$CATEGORY" && pwd)"
elif [[ -d "${SCRIPT_DIR}/${CATEGORY}" ]]; then
    CATEGORY_DIR="$(cd "${SCRIPT_DIR}/${CATEGORY}" && pwd)"
else
    echo "[!] Error: Category directory '${CATEGORY}' not found." >&2
    exit 1
fi

category_name="$(basename "$CATEGORY_DIR")"

# Retrieve list of ignored apps using list-ignored.sh
mapfile -t ignored_apps < <("${SCRIPT_DIR}/list-ignored.sh" --names-only -c "$CATEGORY_DIR")

if [[ ${#ignored_apps[@]} -eq 0 ]]; then
    echo "[i] No ignored applications found in '${category_name}'."
    exit 0
fi

# Sudo credentials and background keepalive
sudo_keepalive_pid=""
cleanup() {
    if [[ -n "$sudo_keepalive_pid" ]]; then
        kill "$sudo_keepalive_pid" 2>/dev/null || true
    fi
}
trap cleanup EXIT INT TERM

if ! sudo -n true 2>/dev/null; then
    echo "[+] Initializing sudo credentials..."
    if [[ -t 0 ]]; then
        sudo -v
    elif [[ -e /dev/tty && -r /dev/tty ]]; then
        sudo -v </dev/tty 2>/dev/null || sudo -v
    else
        sudo -v
    fi
fi

while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" 2>/dev/null || exit
done < /dev/null > /dev/null 2>&1 &
sudo_keepalive_pid=$!

ensure_local_bin_in_path

if [[ "$SKIP_UPDATE" != "true" ]]; then
    echo "[+] Running apt update once before interactive installations..."
    sudo apt-get update
fi

echo ""
echo "================================================================================"
echo " Interactive Installation for Ignored Applications: ${category_name}"
echo " Total found: ${#ignored_apps[@]} application(s)"
echo "================================================================================"
echo "Each application will be prompted with default choice [No]."
echo ""

installed_count=0
skipped_count=0
failed_count=0
declare -a failed_apps=()

for app_name in "${ignored_apps[@]}"; do
    app_dir="${CATEGORY_DIR}/${app_name}"
    if [[ ! -d "$app_dir" ]]; then
        continue
    fi

    # Read user input (defaulting to No)
    prompt_msg="[?] Install ${app_name}? [y/N]: "
    choice=""
    if read -r -p "$prompt_msg" input_val; then
        choice="$input_val"
    elif [[ -e /dev/tty && -r /dev/tty ]]; then
        read -r -p "$prompt_msg" choice </dev/tty || choice="n"
    else
        choice="n"
    fi

    choice="${choice:-n}"
    case "${choice,,}" in
        y|yes)
            ;;
        *)
            echo "    -> Skipped ${app_name}."
            ((skipped_count++)) || true
            continue
            ;;
    esac

    # Find installer scripts in the application directory
    sh_scripts=("$app_dir"/*.sh)
    if [[ ! -e "${sh_scripts[0]}" ]]; then
        echo "[!] Warning: No .sh installation script found in ${app_dir}" >&2
        ((skipped_count++)) || true
        continue
    fi

    for script in "${sh_scripts[@]}"; do
        [[ -f "$script" ]] || continue
        script_name="$(basename "$script")"

        echo ""
        echo "--------------------------------------------------------------------------------"
        echo "[==>] Installing: ${app_name} (${script_name})"
        echo "--------------------------------------------------------------------------------"

        set +e
        (cd "$app_dir" && ./"$script_name" --no-update)
        exit_code=$?
        set -e

        if [[ $exit_code -eq 130 ]] || [[ $exit_code -eq 2 ]]; then
            echo ""
            echo "[!] Interrupted by user (SIGINT). Aborting installation run." >&2
            exit 130
        fi

        if [[ $exit_code -eq 0 ]]; then
            ((installed_count++)) || true
            echo "[✓] Successfully installed: ${app_name}"
        else
            ((failed_count++)) || true
            failed_apps+=("${app_name} (${script_name})")
            echo "[✗] Failed: ${app_name} (${script_name}) [Exit code: ${exit_code}]"
        fi
    done
    echo ""
done

echo "================================================================================"
echo " Interactive Installation Summary: ${category_name}"
echo "================================================================================"
echo "  Total prompted: ${#ignored_apps[@]}"
echo "  Installed:      ${installed_count}"
echo "  Skipped:        ${skipped_count}"
echo "  Failed:         ${failed_count}"

if [[ ${#failed_apps[@]} -gt 0 ]]; then
    echo ""
    echo "  Failed Applications:"
    for failed in "${failed_apps[@]}"; do
        echo "    - ${failed}"
    done
fi
echo "================================================================================"
