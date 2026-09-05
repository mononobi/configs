#!/usr/bin/env bash
# Description: Install uWSGI and compile Python plugins for Python versions from 3.8 to latest stable
# Note: Implements the exact plugin compilation approach from the original uwsgi.python3.*.apt scripts.

set -euo pipefail

CUSTOM_VERSIONS=()

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

echo "[+] Starting installation and plugin build for uWSGI..."

# 1. Update system and add deadsnakes PPA if needed
sudo apt-get update
sudo apt-get install -y software-properties-common ca-certificates curl build-essential

# 2. Determine target versions (3.8 up to latest stable)
TARGET_VERSIONS=()
if [[ ${#CUSTOM_VERSIONS[@]} -gt 0 ]]; then
    TARGET_VERSIONS=("${CUSTOM_VERSIONS[@]}")
else
    MAX_MINOR=$(apt-cache search "^python3\.[0-9]+$" 2>/dev/null | awk '{print $1}' | grep -Po '3\.\K[0-9]+' | sort -n | tail -1 || echo "14")
    if (( MAX_MINOR < 14 )); then
        MAX_MINOR=14
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
        echo "[+] Installing build requirements for uwsgi ${PLUGIN_TAG} plugin (Python ${ver})..."

        DEPS=("python${ver}-dev" "uwsgi" "uwsgi-src" "uuid-dev" "libcap-dev" "libssl-dev" "zlib1g-dev")

        if apt-cache show "python${ver}-distutils" >/dev/null 2>&1; then
            DEPS+=("python${ver}-distutils")
        fi
        if apt-cache show "libpcre2-dev" >/dev/null 2>&1; then
            DEPS+=("libpcre2-dev")
        fi
        if apt-cache show "libpcre3-dev" >/dev/null 2>&1; then
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
