#!/usr/bin/env bash
# Description: List all application folders under apps-recommended and apps-extra containing an 'ignore' file
# Note: Folders with an 'ignore' file are skipped by installer.sh during batch execution.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

NAMES_ONLY=false
CATEGORIES=()

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [CATEGORIES...]

Description:
  Scans application subfolders under 'apps-recommended' and 'apps-extra'
  (or custom categories passed as arguments) and displays all folders
  that contain an 'ignore' file.

Options:
  -s, --short, --names-only   Output only folder names without headers/decorations
  -h, --help                  Show this help message and exit

Examples:
  $(basename "$0")
  $(basename "$0") --names-only
  $(basename "$0") apps-recommended
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -s|--short|--names-only)
            NAMES_ONLY=true
            shift
            ;;
        -*)
            echo "[!] Unknown option: $1" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
        *)
            CATEGORIES+=("$1")
            shift
            ;;
    esac
done

if [[ ${#CATEGORIES[@]} -eq 0 ]]; then
    CATEGORIES=("apps-recommended" "apps-extra")
fi

total_ignored=0

if [[ "$NAMES_ONLY" != "true" ]]; then
    echo "================================================================================"
    echo " Ignored Applications (containing 'ignore' file)"
    echo "================================================================================"
fi

for category in "${CATEGORIES[@]}"; do
    if [[ -d "$category" ]]; then
        cat_dir="$(cd "$category" && pwd)"
    elif [[ -d "${SCRIPT_DIR}/${category}" ]]; then
        cat_dir="$(cd "${SCRIPT_DIR}/${category}" && pwd)"
    else
        if [[ "$NAMES_ONLY" != "true" ]]; then
            echo "[!] Warning: Category directory '${category}' not found." >&2
        fi
        continue
    fi

    cat_name="$(basename "$cat_dir")"
    cat_ignored=()

    for subfolder in "${cat_dir}"/*/; do
        [[ -d "$subfolder" ]] || continue

        if [[ -f "${subfolder}ignore" ]]; then
            folder_name="$(basename "$subfolder")"
            cat_ignored+=("$folder_name")
            ((total_ignored++)) || true
        fi
    done

    if [[ "$NAMES_ONLY" == "true" ]]; then
        for folder in "${cat_ignored[@]}"; do
            echo "$folder"
        done
    else
        echo ""
        echo "[${cat_name}]"
        if [[ ${#cat_ignored[@]} -eq 0 ]]; then
            echo "  (none)"
        else
            for folder in "${cat_ignored[@]}"; do
                echo "  - ${folder}"
            done
        fi
    fi
done

if [[ "$NAMES_ONLY" != "true" ]]; then
    echo ""
    echo "--------------------------------------------------------------------------------"
    echo "Total ignored folders: ${total_ignored}"
    echo "================================================================================"
fi
