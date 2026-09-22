#!/usr/bin/env bash
# Description: Generic runner to discover and install applications within a specified category directory
# Note: Iterates over first-level subfolders in the target directory and executes any *.sh script found.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.sh"

show_help() {
    cat <<EOHELP
Usage: $(basename "$0") <category_folder> [OPTIONS]

Description:
  Discovers and runs all installation scripts (*.sh) inside first-level
  subfolders of the specified target directory.
  Each installer is run from its own subfolder to ensure local asset resolution.
  Subfolders containing an 'ignore' file are skipped automatically.
  Collects and displays final statistics on processed, installed, ignored, and failed apps.

Arguments:
  category_folder   Directory containing application subfolders (e.g. apps-recommended, apps-extra)

Options:
  --no-update       Skip the upfront apt update before running batch installation
  -h, --help        Show this help message and exit
EOHELP
}

TARGET_INPUT=""
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
            ;;
        -*)
            echo "[!] Unknown option: $1" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
        *)
            if [[ -z "$TARGET_INPUT" ]]; then
                TARGET_INPUT="$1"
            else
                echo "[!] Unexpected extra argument: $1" >&2
                show_help
                exit 1
            fi
            ;;
    esac
    shift
done

# Prevent running as root or via sudo to ensure apps are installed in the actual user's $HOME
if [[ $EUID -eq 0 ]] || [[ -n "${SUDO_USER:-}" ]]; then
    echo "[!] Error: Do not run $(basename "$0") as root or with sudo." >&2
    echo "    Application installers configure local tools and user assets directly in \$HOME." >&2
    echo "    Subscripts will automatically invoke sudo internally when root privileges are required." >&2
    echo "    Please run as your regular user: $(basename "$0") ${TARGET_INPUT:-<category_folder>}" >&2
    exit 1
fi

if [[ -z "$TARGET_INPUT" ]]; then
    echo "[!] Error: No target category directory specified." >&2
    echo "Usage: $(basename "$0") <category_folder> [OPTIONS]" >&2
    exit 1
fi

# Resolve target directory (supports absolute path, relative to current dir, or relative to script dir)
if [[ -d "$TARGET_INPUT" ]]; then
    TARGET_DIR="$(cd "$TARGET_INPUT" && pwd)"
elif [[ -d "${SCRIPT_DIR}/${TARGET_INPUT}" ]]; then
    TARGET_DIR="$(cd "${SCRIPT_DIR}/${TARGET_INPUT}" && pwd)"
else
    echo "[!] Error: Target directory '${TARGET_INPUT}' not found." >&2
    exit 1
fi

category_name="$(basename "$TARGET_DIR")"

extract_error_message() {
    local log_file="$1"
    local exit_code="$2"
    local err_msg=""

    if [[ ! -s "$log_file" ]]; then
        echo "Exited with code ${exit_code} (no output recorded)"
        return
    fi

    # Check for lines containing common error indicators
    err_msg="$(grep -Ei "error|failed|fatal|cannot|unable to|not found|denied|invalid|\[\!\]" "$log_file" | tail -n 5 || true)"

    if [[ -z "$err_msg" ]]; then
        # Fall back to the last 5 non-empty lines of output
        err_msg="$(grep -v '^[[:space:]]*$' "$log_file" | tail -n 5 || true)"
    fi

    if [[ -z "$err_msg" ]]; then
        err_msg="Exited with code ${exit_code}"
    fi

    echo "$err_msg"
}

format_duration() {
    local total_seconds="$1"
    if (( total_seconds < 60 )); then
        echo "${total_seconds}s"
    elif (( total_seconds < 3600 )); then
        local min=$((total_seconds / 60))
        local sec=$((total_seconds % 60))
        echo "${min}m ${sec}s"
    else
        local hours=$((total_seconds / 3600))
        local min=$(((total_seconds % 3600) / 60))
        local sec=$((total_seconds % 60))
        echo "${hours}h ${min}m ${sec}s"
    fi
}

# Statistics tracking
installed_count=0
ignored_count=0
failed_count=0
skipped_count=0

declare -a ignored_apps=()
declare -a failed_apps=()
declare -a failed_scripts=()
declare -a failed_codes=()
declare -a failed_messages=()

current_log_file=""
sudo_keepalive_pid=""

cleanup() {
    if [[ -n "$sudo_keepalive_pid" ]]; then
        kill "$sudo_keepalive_pid" 2>/dev/null || true
    fi
    [[ -n "$current_log_file" && -f "$current_log_file" ]] && rm -f "$current_log_file" || true
}
trap cleanup EXIT INT TERM

start_time=$(date +%s)

echo "[+] Initializing sudo credentials..."
sudo -v

# Keep sudo timestamp updated in background every 60 seconds
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" 2>/dev/null || exit
done < /dev/null > /dev/null 2>&1 &
sudo_keepalive_pid=$!

echo -e "${C_CYAN}${DIV_MAIN}${C_RESET}"
echo -e " ${C_BOLD}Starting Installation of Applications: ${category_name}${C_RESET}"
echo -e " Directory: ${TARGET_DIR}"
echo -e "${C_CYAN}${DIV_MAIN}${C_RESET}"

# Ensure ~/.local/bin exists and is permanently added to PATH
ensure_local_bin_in_path

if [[ "$SKIP_UPDATE" != "true" ]]; then
    echo "[+] Running apt update once before batch installation..."
    sudo apt-get update
fi

for subfolder in "${TARGET_DIR}"/*/; do
    [[ -d "$subfolder" ]] || continue

    app_name="$(basename "$subfolder")"

    # Skip subfolders containing an 'ignore' marker file
    if [[ -f "${subfolder}ignore" ]]; then
        echo ""
        echo -e "${C_YELLOW}${DIV_SUB}${C_RESET}"
        echo -e "${C_YELLOW}[i] Skipping ignored application: ${app_name}${C_RESET}"
        echo -e "${C_YELLOW}${DIV_SUB}${C_RESET}"
        ignored_apps+=("$app_name")
        ((ignored_count++)) || true
        continue
    fi

    # Find .sh scripts in the first-level subfolder
    sh_scripts=("$subfolder"*.sh)
    if [[ ! -e "${sh_scripts[0]}" ]]; then
        ((skipped_count++)) || true
        continue
    fi

    for script in "${sh_scripts[@]}"; do
        [[ -f "$script" ]] || continue
        script_name="$(basename "$script")"

        echo ""
        echo -e "${C_BLUE}${DIV_SUB}${C_RESET}"
        echo -e "${C_BLUE}[==>] Installing:${C_RESET}" \
            "${C_BOLD}${app_name}${C_RESET} (${script_name})"
        echo -e "${C_BLUE}${DIV_SUB}${C_RESET}"

        current_log_file="$(mktemp)"

        set +e
        (cd "$subfolder" && ./"$script_name" --no-update) 2>&1 | tee "$current_log_file"
        exit_code=${PIPESTATUS[0]}
        set -e

        # Check for user cancellation (Ctrl+C)
        if [[ $exit_code -eq 130 ]] || [[ $exit_code -eq 2 ]]; then
            echo ""
            echo -e "${C_RED}[!] Interrupted by user (SIGINT)." \
                "Aborting installation run.${C_RESET}" >&2
            rm -f "$current_log_file"
            exit 130
        fi

        if [[ $exit_code -eq 0 ]]; then
            ((installed_count++)) || true
            echo -e "${C_GREEN}[✓] Successfully installed: ${app_name}${C_RESET}"
        else
            ((failed_count++)) || true
            err_msg="$(extract_error_message "$current_log_file" "$exit_code")"
            failed_apps+=("$app_name")
            failed_scripts+=("$script_name")
            failed_codes+=("$exit_code")
            failed_messages+=("$err_msg")
            echo -e "${C_RED}[✗] Failed: ${app_name} (${script_name})" \
                "[Exit code: ${exit_code}]${C_RESET}"
        fi

        rm -f "$current_log_file"
        current_log_file=""
    done
done

total_processed=$((installed_count + ignored_count + failed_count))
end_time=$(date +%s)
duration=$((end_time - start_time))
duration_display="$(format_duration "$duration")"

echo ""
echo -e "${C_CYAN}${DIV_MAIN}${C_RESET}"
echo -e " ${C_BOLD}Final Installation Statistics: ${category_name}${C_RESET}"
echo -e "${C_CYAN}${DIV_MAIN}${C_RESET}"
echo -e " Total Processed Apps: ${C_BOLD}${total_processed}${C_RESET}"
echo -e "   - Installed:        ${C_GREEN}${installed_count}${C_RESET}"
echo -e "   - Ignored:          ${C_YELLOW}${ignored_count}${C_RESET}"
if [[ $failed_count -gt 0 ]]; then
    echo -e "   - Failed:           ${C_RED}${failed_count}${C_RESET}"
else
    echo -e "   - Failed:           ${failed_count}"
fi
if [[ $skipped_count -gt 0 ]]; then
    echo -e "   - Skipped:          ${skipped_count} (no .sh script found)"
fi
echo -e " Total Duration:       ${C_BOLD}${duration_display}${C_RESET}"
echo -e "${C_CYAN}${DIV_MAIN}${C_RESET}"

if [[ ${#ignored_apps[@]} -gt 0 ]]; then
    echo ""
    echo -e "${C_YELLOW}${DIV_MAIN}${C_RESET}"
    echo -e " ${C_BOLD}${C_YELLOW}Ignored Applications (${#ignored_apps[@]}):${C_RESET}"
    echo -e "${C_YELLOW}${DIV_MAIN}${C_RESET}"
    for app in "${ignored_apps[@]}"; do
        echo -e "  ${C_YELLOW}[i]${C_RESET} ${app}"
    done
    echo -e "${C_YELLOW}${DIV_MAIN}${C_RESET}"
fi

if [[ $failed_count -gt 0 ]]; then
    echo ""
    echo -e "${C_RED}${DIV_MAIN}${C_RESET}"
    echo -e " ${C_BOLD}${C_RED}Failure Details (${failed_count}):${C_RESET}"
    echo -e "${C_RED}${DIV_MAIN}${C_RESET}"
    for i in "${!failed_apps[@]}"; do
        echo -e "  ${C_RED}[✗] ${failed_apps[i]} (${failed_scripts[i]})" \
            "- Exit Code: ${failed_codes[i]}${C_RESET}"
        echo -e "      ${C_RED}Error Output:${C_RESET}"
        while IFS= read -r line; do
            [[ -n "$line" ]] && echo -e "        ${C_RED}$line${C_RESET}"
        done <<< "${failed_messages[i]}"
        echo ""
    done
    echo -e "${C_RED}${DIV_MAIN}${C_RESET}"
    exit 1
else
    echo -e "${C_GREEN}[✓] All processed applications installed successfully!${C_RESET}"
    echo -e "${C_CYAN}${DIV_MAIN}${C_RESET}"
fi
