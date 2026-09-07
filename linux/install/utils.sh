#!/usr/bin/env bash
# Description: Shared utility library for application installers and batch runners
# Note: Provides common functions like require_app for resolving inter-script dependencies.

# Prevent multiple inclusions
if [[ -n "${_INSTALL_UTILS_LOADED:-}" ]]; then
    return 0 2>/dev/null || exit 0
fi
_INSTALL_UTILS_LOADED=1

# Resolve the absolute path to linux/install/
INSTALL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# require_app <app_name> [category] [extra_args...]
#
# Ensures that an application dependency script has been executed.
# If category is omitted, searches 'apps-recommended' first, then 'apps-extra'.
#
# Examples:
#   require_app "python" "apps-recommended"
#   require_app "flatpak"
require_app() {
    local app_name="$1"
    local category="${2:-}"
    shift 2 2>/dev/null || shift 1 2>/dev/null || true
    local extra_args=("$@")

    local candidate_dirs=()
    if [[ -n "$category" ]]; then
        candidate_dirs=("${INSTALL_ROOT}/${category}/${app_name}")
    else
        candidate_dirs=(
            "${INSTALL_ROOT}/apps-recommended/${app_name}"
            "${INSTALL_ROOT}/apps-extra/${app_name}"
        )
    fi

    local target_script=""
    local target_dir=""
    for dir in "${candidate_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            local found
            found=$(find "$dir" -maxdepth 1 -name "*.sh" 2>/dev/null | head -n 1)
            if [[ -n "$found" && -f "$found" ]]; then
                target_script="$found"
                target_dir="$dir"
                break
            fi
        fi
    done

    if [[ -z "$target_script" ]]; then
        echo "[!] Error: Dependency application '${app_name}' not found in candidate locations: ${candidate_dirs[*]}" >&2
        return 1
    fi

    local script_name
    script_name="$(basename "$target_script")"

    local update_args=()
    if [[ "${SKIP_UPDATE:-false}" == "true" ]]; then
        update_args=("--no-update")
    fi

    echo "[+] Satisfying dependency: $(basename "$target_dir") (${script_name})..."
    (cd "$target_dir" && ./"$script_name" "${update_args[@]}" "${extra_args[@]}")
}

# ensure_local_bin_in_path
#
# Ensures ~/.local/bin exists, exports it to current process PATH,
# and permanently adds it to ~/.bashrc (or ~/.zshrc) if not already present.
ensure_local_bin_in_path() {
    local local_bin="${HOME}/.local/bin"
    mkdir -p "$local_bin"

    if [[ ":${PATH}:" != *":${local_bin}:"* ]]; then
        export PATH="${local_bin}:${PATH}"
    fi

    # Add to ~/.profile if not already present
    local profile="${HOME}/.profile"
    if [[ ! -f "$profile" ]] || ! grep -qs '\.local/bin' "$profile"; then
        [[ -f "$profile" && -s "$profile" ]] && echo "" >> "$profile"
        cat << 'EOF' >> "$profile"
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
EOF
        echo "[+] Added ~/.local/bin to PATH in $profile"
    fi

    local target_rcs=()
    [[ -f "${HOME}/.bashrc" ]] && target_rcs+=("${HOME}/.bashrc")
    [[ -f "${HOME}/.zshrc" ]] && target_rcs+=("${HOME}/.zshrc")

    # If neither rc file exists, default to ~/.bashrc
    if [[ ${#target_rcs[@]} -eq 0 ]]; then
        target_rcs=("${HOME}/.bashrc")
    fi

    for rc in "${target_rcs[@]}"; do
        if [[ ! -f "$rc" ]] || ! grep -qs '\.local/bin' "$rc"; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
            echo "[+] Added ~/.local/bin to PATH in $rc"
        fi
    done
}

export INSTALL_ROOT
export -f require_app
export -f ensure_local_bin_in_path
