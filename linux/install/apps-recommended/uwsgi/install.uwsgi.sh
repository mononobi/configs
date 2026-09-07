#!/usr/bin/env bash
# Description: Install uWSGI and compile Python plugins for Python versions from 3.8 to latest stable
# Note: Implements the exact plugin compilation approach from the original uwsgi.python3.*.apt scripts.

set -euo pipefail

CUSTOM_VERSIONS=()

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [VERSIONS...]

Description:
  Installs uWSGI, uwsgi-src, build dependencies, and compiles the dedicated uWSGI Python plugin
  (python<XY>_plugin.so) for all target Python versions from 3.8 up to the latest stable (e.g. 3.14).
  Places each compiled plugin into /usr/lib/uwsgi/plugins/.

Arguments:
  VERSIONS              Optional specific Python version(s) to build plugins for (e.g. 3.10 3.12).
                        Default: all versions from 3.8 up to the latest available (e.g. 3.14).

Options:
  --no-update           Skip apt update before installation
  -h, --help            Show this help message and exit

Examples:
  $(basename "$0")              # Builds plugins for Python 3.8 through 3.14
  $(basename "$0") 3.10 3.12    # Builds plugins only for Python 3.10 and 3.12
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
        [0-9]*)
            CUSTOM_VERSIONS+=("$1")
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

has_candidate() {
    local candidate
    candidate=$(apt-cache policy "$1" 2>/dev/null | awk '/Candidate:/ {print $2}')
    [[ -n "$candidate" && "$candidate" != "(none)" ]]
}

echo "[+] Starting installation and plugin build for uWSGI..."

# 1. Update system and add deadsnakes PPA if needed
if [[ "$SKIP_UPDATE" != "true" ]]; then
    sudo apt-get update
fi
sudo apt-get install -y software-properties-common ca-certificates curl build-essential

# 2. Determine target versions (3.8 up to latest stable)
TARGET_VERSIONS=()
if [[ ${#CUSTOM_VERSIONS[@]} -gt 0 ]]; then
    TARGET_VERSIONS=("${CUSTOM_VERSIONS[@]}")
else
    # Target versions from 3.8 up to at least 3.14 (or higher if newer exists)
    MAX_MINOR=14
    DETECTED_MAX=$(apt-cache search "^python3\.[0-9]+$" | awk '{print $1}' | grep -Po '3\.\K[0-9]+' | sort -n | tail -1)
    if [[ -n "$DETECTED_MAX" ]] && (( DETECTED_MAX > MAX_MINOR )); then
        MAX_MINOR="$DETECTED_MAX"
    fi

    for (( m=8; m<=MAX_MINOR; m++ )); do
        TARGET_VERSIONS+=("3.$m")
    done
fi

echo "[+] Target Python versions for uWSGI plugins: ${TARGET_VERSIONS[*]}"

# Ensure destination plugin directory exists
sudo mkdir -p /usr/lib/uwsgi/plugins

# 3. Compile plugin for each Python version
for ver in "${TARGET_VERSIONS[@]}"; do
    PLUGIN_TAG="python${ver//./}"
    PLUGIN_SO="/usr/lib/uwsgi/plugins/${PLUGIN_TAG}_plugin.so"

    if [[ ! -f "$PLUGIN_SO" ]]; then
        if ! has_candidate "python${ver}-dev"; then
            echo "[!] Skipping Python ${ver}: package 'python${ver}-dev' has no installation candidate."
            continue
        fi

        echo "[+] Installing build requirements for uwsgi ${PLUGIN_TAG} plugin (Python ${ver})..."

        DEPS=("python${ver}-dev" "uwsgi" "uwsgi-src" "uuid-dev" "libcap-dev" "libssl-dev" "zlib1g-dev")

        if has_candidate "python${ver}-distutils"; then
            DEPS+=("python${ver}-distutils")
        fi
        if has_candidate "libpcre2-dev"; then
            DEPS+=("libpcre2-dev")
        elif has_candidate "libpcre3-dev"; then
            DEPS+=("libpcre3-dev")
        fi

        sudo apt-get install -y "${DEPS[@]}"

        echo "[+] Compiling ${PLUGIN_TAG}_plugin.so for Python ${ver}..."
        BUILD_DIR=$(mktemp -d)
        pushd "$BUILD_DIR" >/dev/null

        export PYTHON="python${ver}"
        uwsgi --build-plugin "/usr/src/uwsgi/plugins/python ${PLUGIN_TAG}"
        sudo mv "${PLUGIN_TAG}_plugin.so" "$PLUGIN_SO"
        sudo chmod 644 "$PLUGIN_SO"

        popd >/dev/null
        rm -rf "$BUILD_DIR"

        echo "[✓] uwsgi ${PLUGIN_TAG} plugin installed successfully at $PLUGIN_SO"
    else
        echo "[+] uwsgi ${PLUGIN_TAG} plugin is already installed ($PLUGIN_SO)."
    fi
done

echo "[+] Installed uWSGI plugins in /usr/lib/uwsgi/plugins/:"
ls -la /usr/lib/uwsgi/plugins/python*_plugin.so 2>/dev/null || true

echo "[✓] uWSGI multi-python plugin setup completed successfully!"
