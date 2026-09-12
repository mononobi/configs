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

# install_gnome_extension <uuid> [display_name]
#
# Downloads, installs, and enables a GNOME Shell extension by its UUID from extensions.gnome.org.
# Automatically ensures curl, python, and unzip dependencies exist via require_app.
# Completely idempotent: if the extension is already installed, it ensures it is enabled.
install_gnome_extension() {
    local uuid="$1"
    local name="${2:-$uuid}"

    echo "[+] Processing GNOME extension: ${name} (${uuid})..."

    local user_ext_dir="${HOME}/.local/share/gnome-shell/extensions/${uuid}"
    local sys_ext_dir="/usr/share/gnome-shell/extensions/${uuid}"

    if [[ -d "$user_ext_dir" || -d "$sys_ext_dir" ]]; then
        echo "    [✓] Extension already installed. Ensuring enabled..."
        gnome-extensions enable "${uuid}" 2>/dev/null || true
        return 0
    fi

    # Ensure required helper apps
    if [[ "${SKIP_UPDATE:-false}" == "true" ]]; then
        require_app "curl" "apps-recommended" --no-update
        require_app "python" "apps-recommended" --no-update
        require_app "unzip" "apps-recommended" --no-update
    else
        require_app "curl" "apps-recommended"
        require_app "python" "apps-recommended"
        require_app "unzip" "apps-recommended"
    fi

    local shell_ver
    shell_ver="$(gnome-shell --version 2>/dev/null | awk '{print $3}' | cut -d. -f1)"
    shell_ver="${shell_ver:-46}"

    echo "    Querying extensions.gnome.org for GNOME ${shell_ver} bundle..."
    local download_url
    download_url="$(python3 -c "
import urllib.request, json, sys

uuid = sys.argv[1]
shell_ver = sys.argv[2]
url = f'https://extensions.gnome.org/extension-info/?uuid={uuid}&shell_version={shell_ver}'
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req, timeout=10) as resp:
        data = json.loads(resp.read().decode())
        print('https://extensions.gnome.org' + data['download_url'])
except Exception:
    try:
        url_fallback = f'https://extensions.gnome.org/extension-info/?uuid={uuid}'
        req_fallback = urllib.request.Request(url_fallback, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req_fallback, timeout=10) as resp2:
            data2 = json.loads(resp2.read().decode())
            print('https://extensions.gnome.org' + data2['download_url'])
    except Exception:
        pass
" "$uuid" "$shell_ver" 2>/dev/null || true)"

    if [[ -z "$download_url" ]]; then
        echo "    [!] Warning: Could not resolve download URL for ${uuid}" >&2
        return 1
    fi

    local tmp_zip
    tmp_zip="$(mktemp --suffix=.zip)"
    if curl -fsSL "$download_url" -o "$tmp_zip" 2>/dev/null; then
        if command -v gnome-extensions >/dev/null 2>&1; then
            gnome-extensions install -f "$tmp_zip" 2>/dev/null || {
                mkdir -p "$user_ext_dir"
                unzip -q -o "$tmp_zip" -d "$user_ext_dir"
            }
        else
            mkdir -p "$user_ext_dir"
            unzip -q -o "$tmp_zip" -d "$user_ext_dir"
        fi
        rm -f "$tmp_zip"

        if [[ -d "${user_ext_dir}/schemas" ]]; then
            glib-compile-schemas "${user_ext_dir}/schemas" 2>/dev/null || true
        fi

        # Ensure extension version validation is disabled so all extensions load cleanly
        gsettings set org.gnome.shell disable-extension-version-validation true 2>/dev/null || true

        gnome-extensions enable "${uuid}" 2>/dev/null || true
        echo "    [✓] Successfully installed and enabled: ${name}"
        return 0
    else
        rm -f "$tmp_zip"
        echo "    [!] Error: Failed to download extension zip for ${uuid}" >&2
        return 1
    fi
}

export INSTALL_ROOT
export -f require_app
export -f ensure_local_bin_in_path
export -f install_gnome_extension
