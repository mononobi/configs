#!/usr/bin/env bash
# Description: Install and configure Memcached instance via Docker Compose
# Note: Deploys official memcached:latest image and equips host with interactive memcached-cli.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

DEFAULT_PORT=11211
CUSTOM_PORT=""
MEMCACHED_MEMORY="64"
MEMCACHED_MAX_CONNECTIONS="1024"
CONTAINER_NAME="memcached"
TARGET_DIR="${HOME}/.memcached"
FORCE=false
SKIP_UPDATE="${SKIP_UPDATE:-false}"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs and configures Memcached using Docker Compose with the official memcached:latest image.
  Persists configuration drops and logs in ~/.memcached/.
  Automatically equips the host system with an interactive memcached-cli client linked to ~/.local/bin/memcached-cli
  featuring Redis-like commands, multi-key operations, and memcached-tool diagnostic utilities.

Options:
  --port PORT                   Specify host port (default: 11211). Fails if port is already busy.
  -m, --memory MB               Max memory allocation in megabytes (default: 64).
  -c, --connections NUM         Max simultaneous connections (default: 1024).
  -f, --force                   Force recreating container and updating configurations.
  --no-update                   Skip package index updates for host dependencies.
  --skip-update                 Alias for --no-update.
  -h, --help                    Show this help message and exit.

Note:
  Version flags (-v, --version) are explicitly not supported. This installer strictly
  provisions the latest official Memcached image (memcached:latest).

Examples:
  $(basename "$0")                      # Installs Memcached on default port 11211
  $(basename "$0") --port 11220         # Installs Memcached on custom port 11220
  $(basename "$0") -m 128 -c 2048       # Installs Memcached with 128MB RAM and 2048 connections
  $(basename "$0") -f                   # Recreates container and updates configurations
EOF
}

# Parse command line arguments
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
        -f|--force)
            FORCE=true
            shift
            ;;
        --port)
            if [[ $# -ge 2 ]]; then
                CUSTOM_PORT="$2"
                shift 2
            else
                echo "[!] Error: --port requires an argument" >&2
                exit 1
            fi
            ;;
        -m|--memory)
            if [[ $# -ge 2 ]]; then
                MEMCACHED_MEMORY="$2"
                shift 2
            else
                echo "[!] Error: -m/--memory requires an argument" >&2
                exit 1
            fi
            ;;
        -c|--connections)
            if [[ $# -ge 2 ]]; then
                MEMCACHED_MAX_CONNECTIONS="$2"
                shift 2
            else
                echo "[!] Error: -c/--connections requires an argument" >&2
                exit 1
            fi
            ;;
        -v|--version|-v=*|--version=*)
            echo -e "${C_RED}[!] Error: Version flag is not supported. This installer strictly provisions the latest official Memcached image (:latest).${C_RESET}" >&2
            exit 1
            ;;
        *)
            echo -e "${C_RED}[!] Error: Unknown option or argument: $1${C_RESET}" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
    esac
done

echo "[+] Starting Memcached Docker setup..."

# 1. Require framework dependencies
require_app docker ufw lsof
require_app python --fast

# 2. Determine assigned port
PORT=""
if [[ -n "$CUSTOM_PORT" ]]; then
    PORT="$CUSTOM_PORT"
elif [[ -f "${TARGET_DIR}/docker-compose.yml" ]]; then
    EXISTING_PORT=$(grep -oE '[0-9]+:11211' "${TARGET_DIR}/docker-compose.yml" | head -n 1 | cut -d: -f1 || true)
    if [[ -n "$EXISTING_PORT" ]]; then
        PORT="$EXISTING_PORT"
    fi
fi

if [[ -z "$PORT" ]]; then
    PORT="$DEFAULT_PORT"
fi

# 3. Fail-fast port check: abort immediately if port is busy by an external process
if is_port_in_use "$PORT"; then
    if ! container_owns_port "$CONTAINER_NAME" "$PORT"; then
        echo -e "${C_RED}[!] Error: Port ${PORT} is already in use by another process.${C_RESET}" >&2
        echo -e "${C_YELLOW}[i] Please free port ${PORT} or specify an alternative port using --port <PORT>.${C_RESET}" >&2
        exit 1
    fi
fi

echo "[+] Assigned host port: ${PORT}"

# 4. Verify target directories exist on host
echo "[+] Verifying target directories in ${TARGET_DIR}..."
mkdir -p "${TARGET_DIR}/config"
mkdir -p "${TARGET_DIR}/logs"

chown -R "${USER}:${USER}" "${TARGET_DIR}" 2>/dev/null || true
chmod -R 755 "${TARGET_DIR}/config"
chmod 777 "${TARGET_DIR}/logs"

CONFIG_UPDATED=false

# 5. Copy & render memcached.conf idempotently
CONF_FILE="${TARGET_DIR}/config/memcached.conf"
if [[ ! -f "$CONF_FILE" ]] || [[ "$FORCE" == "true" ]]; then
    echo "[+] Installing memcached.conf to ${CONF_FILE}..."
    cp "${SCRIPT_DIR}/files/memcached.conf" "$CONF_FILE"
    CONFIG_UPDATED=true
elif ! cmp -s "${SCRIPT_DIR}/files/memcached.conf" "$CONF_FILE"; then
    echo "[+] Updating ${CONF_FILE} with updated settings..."
    cp "${SCRIPT_DIR}/files/memcached.conf" "$CONF_FILE"
    CONFIG_UPDATED=true
fi

# 6. Generate docker-compose.yml from template idempotently
COMPOSE_FILE="${TARGET_DIR}/docker-compose.yml"
NEW_COMPOSE=$(sed \
    -e "s|\${CONTAINER_NAME}|${CONTAINER_NAME}|g" \
    -e "s|\${MEMCACHED_PORT}|${PORT}|g" \
    -e "s|\${MEMCACHED_MEMORY}|${MEMCACHED_MEMORY}|g" \
    -e "s|\${MEMCACHED_MAX_CONNECTIONS}|${MEMCACHED_MAX_CONNECTIONS}|g" \
    "${SCRIPT_DIR}/files/docker-compose.template.yml")

if [[ ! -f "$COMPOSE_FILE" ]] || [[ "$FORCE" == "true" ]]; then
    echo "$NEW_COMPOSE" > "$COMPOSE_FILE"
    CONFIG_UPDATED=true
else
    CURRENT_COMPOSE=$(cat "$COMPOSE_FILE" 2>/dev/null || true)
    if [[ "$CURRENT_COMPOSE" != "$NEW_COMPOSE" ]]; then
        echo "$NEW_COMPOSE" > "$COMPOSE_FILE"
        CONFIG_UPDATED=true
    fi
fi

# 7. Container lifecycle management
IS_RUNNING=false
if docker ps --filter "name=^/${CONTAINER_NAME}$" --format '{{.Names}}' 2>/dev/null | grep -qx "${CONTAINER_NAME}"; then
    IS_RUNNING=true
fi

if [[ "$IS_RUNNING" == "true" ]]; then
    if [[ "$CONFIG_UPDATED" == "true" || "$FORCE" == "true" ]]; then
        echo "[+] Configurations updated; recreating container ${CONTAINER_NAME}..."
        (cd "$TARGET_DIR" && docker compose up -d --force-recreate)
    else
        echo -e "${C_GREEN}[i] Container ${CONTAINER_NAME} is already active with latest configuration, skipping...${C_RESET}"
    fi
else
    echo "[+] Launching container ${CONTAINER_NAME} via Docker Compose..."
    (cd "$TARGET_DIR" && docker compose up -d)
fi

# 8. Verify Memcached service readiness
echo "[+] Verifying Memcached service readiness..."
ready=false
for _ in {1..15}; do
    if "${SCRIPT_DIR}/scripts/memcached-cli" -p "$PORT" ping >/dev/null 2>&1; then
        ready=true
        break
    fi
    sleep 1
done

if [[ "$ready" != "true" ]]; then
    echo -e "${C_YELLOW}[!] Warning: Memcached ping check did not respond within 15 seconds. Please inspect logs: docker logs ${CONTAINER_NAME}${C_RESET}" >&2
fi

# 9. Configure UFW firewall
echo "[+] Configuring UFW firewall for port ${PORT}/tcp..."
sudo ufw allow "${PORT}/tcp" >/dev/null 2>&1 || sudo ufw allow "${PORT}/tcp"

# 10. Ensure memcached-cli is executable and linked into ~/.local/bin
ensure_local_bin_in_path
chmod +x "${SCRIPT_DIR}/scripts/memcached-cli"
ln -sf "${SCRIPT_DIR}/scripts/memcached-cli" "${HOME}/.local/bin/memcached-cli"
echo "[+] Linked CLI utility (memcached-cli) to ${HOME}/.local/bin/memcached-cli"

# 11. Display connection summary
echo ""
echo "${DIV_MAIN}"
echo -e "${C_BOLD}${C_GREEN}[✓] Memcached (Docker) Ready!${C_RESET}"
echo "${DIV_SUB}"
printf "%-18s: %s\n" "Container" "$CONTAINER_NAME"
printf "%-18s: %s\n" "Host Port" "$PORT"
printf "%-18s: %s\n" "Image" "memcached:latest"
printf "%-18s: %s MB\n" "Max Memory" "$MEMCACHED_MEMORY"
printf "%-18s: %s\n" "Max Connections" "$MEMCACHED_MAX_CONNECTIONS"
printf "%-18s: %s\n" "Connection URI" "memcached://localhost:${PORT}"
printf "%-18s: %s\n" "Host CLI Command" "memcached-cli"
printf "%-18s: %s\n" "Config Directory" "${TARGET_DIR}/config"
printf "%-18s: %s\n" "Log Directory" "${TARGET_DIR}/logs"
printf "%-18s: %s\n" "Compose File" "${TARGET_DIR}/docker-compose.yml"
echo "${DIV_MAIN}"
