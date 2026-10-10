#!/usr/bin/env bash
# Description: Install and configure Redis instance via Docker Compose
# Note: Persists data, config, and logs under ~/.redis/ using official redis:latest image.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

DEFAULT_PORT=6379
CUSTOM_PORT=""
REDIS_PASSWORD=""
CONTAINER_NAME="redis"
TARGET_DIR="${HOME}/.redis"
FORCE=false
SKIP_UPDATE="${SKIP_UPDATE:-false}"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs and configures Redis using Docker Compose with the official redis:latest image.
  Persists database data in ~/.redis/data, configurations in ~/.redis/config, and logs in ~/.redis/logs.
  Provides a host redis-cli wrapper linked to ~/.local/bin/redis-cli with full interactive REPL
  and pipeline/redirection support.

Options:
  --port PORT                   Specify host port (default: 6379). Fails if port is already busy.
  -p, --password PASS           Set custom authentication password (optional, maps to requirepass in redis.conf).
  -a, --requirepass PASS        Alias for --password.
  -f, --force                   Force recreating container and updating configurations.
  --no-update                   Skip package index updates for host dependencies.
  --skip-update                 Alias for --no-update.
  -h, --help                    Show this help message and exit.

Note:
  Version flags (-v, --version) are explicitly not supported. This installer strictly
  provisions the latest official Redis image (redis:latest).

Examples:
  $(basename "$0")                      # Installs Redis on default port 6379
  $(basename "$0") --port 6380          # Installs Redis on custom port 6380
  $(basename "$0") -p mysecretpassword  # Installs Redis with password authentication
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
        -p|--password|-a|--requirepass)
            if [[ $# -ge 2 ]]; then
                REDIS_PASSWORD="$2"
                shift 2
            else
                echo "[!] Error: $1 requires an argument" >&2
                exit 1
            fi
            ;;
        -v|--version|-v=*|--version=*)
            echo -e "${C_RED}[!] Error: Version flag is not supported. This installer strictly provisions the latest official Redis image (:latest).${C_RESET}" >&2
            exit 1
            ;;
        *)
            echo -e "${C_RED}[!] Error: Unknown option or argument: $1${C_RESET}" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
    esac
done

echo "[+] Starting Redis Docker setup..."

# 1. Require framework dependencies
require_app docker lsof

# 2. Determine assigned port
PORT=""
if [[ -n "$CUSTOM_PORT" ]]; then
    PORT="$CUSTOM_PORT"
elif [[ -f "${TARGET_DIR}/docker-compose.yml" ]]; then
    EXISTING_PORT=$(grep -oE '[0-9]+:6379' "${TARGET_DIR}/docker-compose.yml" | head -n 1 | cut -d: -f1 || true)
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
mkdir -p "${TARGET_DIR}/data"
mkdir -p "${TARGET_DIR}/config"
mkdir -p "${TARGET_DIR}/logs"

chown -R "${USER}:${USER}" "${TARGET_DIR}/config" 2>/dev/null || true
chmod -R 755 "${TARGET_DIR}/config"
chmod 777 "${TARGET_DIR}/data" "${TARGET_DIR}/logs"

CONFIG_UPDATED=false

# 5. Copy & render redis.conf idempotently
PASS_LINE="# requirepass (disabled)"
if [[ -n "$REDIS_PASSWORD" ]]; then
    PASS_LINE="requirepass ${REDIS_PASSWORD}"
fi

CONF_FILE="${TARGET_DIR}/config/redis.conf"
NEW_CONF=$(sed -e "s|\${REDIS_REQUIREPASS}|${PASS_LINE}|g" "${SCRIPT_DIR}/files/redis.conf")

if [[ ! -f "$CONF_FILE" ]] || [[ "$FORCE" == "true" ]]; then
    echo "[+] Installing redis.conf to ${CONF_FILE}..."
    echo "$NEW_CONF" > "$CONF_FILE"
    CONFIG_UPDATED=true
else
    CURRENT_CONF=$(cat "$CONF_FILE" 2>/dev/null || true)
    if [[ "$CURRENT_CONF" != "$NEW_CONF" ]]; then
        echo "[+] Updating ${CONF_FILE} with updated settings..."
        echo "$NEW_CONF" > "$CONF_FILE"
        CONFIG_UPDATED=true
    fi
fi

# 6. Generate docker-compose.yml from template idempotently
COMPOSE_FILE="${TARGET_DIR}/docker-compose.yml"
NEW_COMPOSE=$(sed \
    -e "s|\${CONTAINER_NAME}|${CONTAINER_NAME}|g" \
    -e "s|\${REDIS_PORT}|${PORT}|g" \
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

# 8. Verify Redis service readiness
echo "[+] Verifying Redis service readiness..."
ping_cmd=("docker" "exec" "$CONTAINER_NAME" "redis-cli")
if [[ -n "$REDIS_PASSWORD" ]]; then
    ping_cmd+=("-a" "$REDIS_PASSWORD")
fi
ping_cmd+=("ping")

ready=false
for _ in {1..15}; do
    if "${ping_cmd[@]}" >/dev/null 2>&1; then
        ready=true
        break
    fi
    sleep 1
done

if [[ "$ready" != "true" ]]; then
    echo -e "${C_YELLOW}[!] Warning: Redis readiness check did not respond within 15 seconds. Please check logs: docker logs ${CONTAINER_NAME}${C_RESET}" >&2
fi

# 9. Configure UFW firewall (restricted to LAN and container networks)
configure_ufw_lan_private_port "${PORT}" "Redis"

# 10. Ensure redis-cli wrapper is linked to ~/.local/bin
symlink_to_local_bin "${SCRIPT_DIR}/scripts/redis-cli"

# 11. Display connection summary
echo ""
echo "${DIV_MAIN}"
echo -e "${C_BOLD}${C_GREEN}[✓] Redis (Docker) Ready!${C_RESET}"
echo "${DIV_SUB}"
printf "%-18s: %s\n" "Container" "$CONTAINER_NAME"
printf "%-18s: %s\n" "Host Port" "$PORT"
printf "%-18s: %s\n" "Image" "redis:latest"
if [[ -n "$REDIS_PASSWORD" ]]; then
    printf "%-18s: %s\n" "Password" "$REDIS_PASSWORD"
    printf "%-18s: %s\n" "Connection URI" "redis://:${REDIS_PASSWORD}@localhost:${PORT}/0"
else
    printf "%-18s: %s\n" "Password" "None (auth disabled)"
    printf "%-18s: %s\n" "Connection URI" "redis://localhost:${PORT}/0"
fi
printf "%-18s: %s\n" "Host CLI Command" "redis-cli"
printf "%-18s: %s\n" "Data Directory" "${TARGET_DIR}/data"
printf "%-18s: %s\n" "Log Directory" "${TARGET_DIR}/logs"
printf "%-18s: %s\n" "Config File" "${TARGET_DIR}/config/redis.conf"
printf "%-18s: %s\n" "Compose File" "${TARGET_DIR}/docker-compose.yml"
echo "${DIV_MAIN}"
