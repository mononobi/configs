#!/usr/bin/env bash
# Description: Install and configure PostgreSQL multi-version instances via Docker Compose
# Note: Persists data and configs under ~/.postgres/<version>/ and pins concrete major versions.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

PG_USER="postgres"
PG_PASSWORD="123"
PG_DB="postgres"
DEFAULT_PORT=5432
CUSTOM_PORT=""
USE_POSTGIS=false
FORCE=false
SKIP_UPDATE="${SKIP_UPDATE:-false}"

TARGET_VERSIONS=()

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [VERSION...]

Description:
  Installs and configures PostgreSQL (or PostGIS) instances using Docker Compose.
  Each instance is completely isolated, persists database data and configuration
  in ~/.postgres/<version>/, runs with restart: unless-stopped, and is protected by UFW.
  If no version is specified, it auto-detects the latest stable major version via Docker
  metadata (e.g. 18) and pins the instance to that concrete major version.

Arguments:
  VERSION               PostgreSQL major version(s) to install (e.g. 18, 17, 16).
                        Default: auto-detects latest stable major version

Options:
  -v, --version VER     Specify PostgreSQL version (can be specified multiple times)
  --port PORT           Specify base host port. Used for the first instance (aborts if busy).
                        For multiple instances, subsequent versions increment from this port
                        and automatically select the next available free port.
  -p, --password PASS   Set password for the postgres superuser (default: 123)
  -u, --user USER       Set default database superuser (default: postgres)
  -d, --database DB     Set default database name (default: postgres)
  --postgis             Use the official PostGIS image (postgis/postgis) instead of postgres
  -f, --force           Force recreating containers and updating configurations
  --no-update           Skip package index updates for host dependencies
  --skip-update         Alias for --no-update
  -h, --help            Show this help message and exit

Examples:
  $(basename "$0")                  # Auto-detects latest (e.g. 18) and installs on port 5432
  $(basename "$0") 18               # Installs PostgreSQL 18
  $(basename "$0") 18 --port 5435   # Installs PostgreSQL 18 on custom port 5435
  $(basename "$0") 18 16 --port 5440 # Installs 18 on 5440, and 16 on next free port (>=5441)
  $(basename "$0") 18 16 --postgis  # Installs PostGIS 18 and 16 on incrementing ports
  $(basename "$0") -p mysecret      # Installs latest with custom password
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
        --postgis)
            USE_POSTGIS=true
            shift
            ;;
        -v|--version)
            if [[ $# -ge 2 ]]; then
                TARGET_VERSIONS+=("$2")
                shift 2
            else
                echo "[!] Error: -v/--version requires an argument" >&2
                exit 1
            fi
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
        -p|--password)
            if [[ $# -ge 2 ]]; then
                PG_PASSWORD="$2"
                shift 2
            else
                echo "[!] Error: -p/--password requires an argument" >&2
                exit 1
            fi
            ;;
        -u|--user)
            if [[ $# -ge 2 ]]; then
                PG_USER="$2"
                shift 2
            else
                echo "[!] Error: -u/--user requires an argument" >&2
                exit 1
            fi
            ;;
        -d|--database)
            if [[ $# -ge 2 ]]; then
                PG_DB="$2"
                shift 2
            else
                echo "[!] Error: -d/--database requires an argument" >&2
                exit 1
            fi
            ;;
        latest|[0-9]*)
            TARGET_VERSIONS+=("$1")
            shift
            ;;
        *)
            echo "[!] Error: Unknown option or argument: $1" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
    esac
done

echo "[+] Starting PostgreSQL Docker setup..."

# 1. Require framework dependencies
require_app docker lsof curl
require_app python --fast

# 2. Ensure lightweight host client tools (psql, pg_dump) are available
if ! is_installed --check "psql"; then
    echo "[+] Installing postgresql-client on host for terminal CLI access..."
    conditional_apt_update
    sudo apt-get install -y postgresql-client
fi

# Helper: Detect latest stable major version via Docker metadata with clean fallback
# Helper: Fetch tags once from Docker Hub Registry v2 API with retry and in-memory caching
CACHED_PG_TAGS=""
CACHED_POSTGIS_TAGS=""

fetch_docker_registry_tags() {
    local repo="$1"
    if [[ "$repo" == "library/postgres" && -n "$CACHED_PG_TAGS" ]]; then
        echo "$CACHED_PG_TAGS"
        return 0
    elif [[ "$repo" == "postgis/postgis" && -n "$CACHED_POSTGIS_TAGS" ]]; then
        echo "$CACHED_POSTGIS_TAGS"
        return 0
    fi

    local token
    token=$(curl -fsSL --retry 3 --retry-connrefused --retry-delay 1 "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${repo}:pull" 2>/dev/null | jq -r .token || true)
    if [[ -z "$token" || "$token" == "null" ]]; then
        return 1
    fi

    local raw
    raw=$(curl -fsSL --retry 3 --retry-connrefused --retry-delay 1 \
        -H "Authorization: Bearer ${token}" \
        "https://registry-1.docker.io/v2/${repo}/tags/list" 2>/dev/null || true)

    if [[ -z "$raw" ]]; then
        return 1
    fi

    if [[ "$repo" == "library/postgres" ]]; then
        CACHED_PG_TAGS="$raw"
    elif [[ "$repo" == "postgis/postgis" ]]; then
        CACHED_POSTGIS_TAGS="$raw"
    fi

    echo "$raw"
}

# Helper: Retrieve available major versions from Docker Hub tags (strictly major numbers: e.g. 18 17 16...)
get_available_postgres_versions() {
    local repo="library/postgres"
    if [[ "$USE_POSTGIS" == "true" ]]; then
        repo="postgis/postgis"
    fi

    local raw
    raw=$(fetch_docker_registry_tags "$repo") || return 1

    if [[ "$USE_POSTGIS" == "true" ]]; then
        # PostGIS tags format: e.g. "18-3.6", "17-3.5". Extract distinct major versions.
        echo "$raw" | jq -r '.tags[]' 2>/dev/null \
            | grep -E '^[0-9]+-[0-9.]+$' \
            | cut -d'-' -f1 \
            | sort -u -rV \
            | tr '\n' ' ' \
            | sed 's/ $//' || true
    else
        # Vanilla PostgreSQL tags format: pure major numbers e.g. "18", "17", "16", "15"...
        echo "$raw" | jq -r '.tags[]' 2>/dev/null \
            | grep -E '^[0-9]+$' \
            | sort -rV \
            | tr '\n' ' ' \
            | sed 's/ $//' || true
    fi
}

# Helper: Detect latest stable major version via Docker Hub tags
detect_latest_major_version() {
    local versions
    versions=$(get_available_postgres_versions) || return 1
    local latest
    latest=$(echo "$versions" | awk '{print $1}')
    if [[ -n "$latest" && "$latest" =~ ^[0-9]+$ ]]; then
        echo "$latest"
        return 0
    fi
    return 1
}

# Helper: Resolve appropriate PostGIS tag for a major version from cached registry tags
resolve_postgis_tag() {
    local major="$1"
    local raw
    raw=$(fetch_docker_registry_tags "postgis/postgis") || true

    if [[ -n "$raw" ]]; then
        # Check exact tag match first (if user passed full tag e.g. 18-3.6)
        if echo "$raw" | jq -e --arg t "$major" '.tags[] | select(. == $t)' >/dev/null 2>&1; then
            echo "$major"
            return 0
        fi
        # Match standard stable Debian release tag: <major>-<postgis_version>
        local matched
        matched=$(echo "$raw" | jq -r '.tags[]' 2>/dev/null | grep -E "^${major}-[0-9.]+$" | head -n 1 || true)
        if [[ -n "$matched" ]]; then
            echo "$matched"
            return 0
        fi
    fi

    echo "${major}"
}

# Helper: Verify whether a Docker image exists on Docker Hub
check_docker_image_exists() {
    local repo="$1"
    local tag="$2"

    local raw
    raw=$(fetch_docker_registry_tags "$repo") || true
    if [[ -n "$raw" ]]; then
        if echo "$raw" | jq -e --arg t "$tag" '.tags[] | select(. == $t)' >/dev/null 2>&1; then
            return 0
        fi
        return 1
    fi

    local token
    token=$(curl -fsSL --retry 3 --retry-connrefused --retry-delay 1 "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${repo}:pull" 2>/dev/null | jq -r .token || true)
    [[ -z "$token" || "$token" == "null" ]] && return 1

    local status
    status=$(curl -s -o /dev/null -w "%{http_code}" --retry 3 --retry-connrefused --retry-delay 1 -I \
        -H "Authorization: Bearer ${token}" \
        -H "Accept: application/vnd.docker.distribution.manifest.v2+json,application/vnd.oci.image.index.v1+json" \
        "https://registry-1.docker.io/v2/${repo}/manifests/${tag}" 2>/dev/null || true)

    [[ "$status" == "200" ]]
}

# Resolve target versions: replace missing or 'latest' with detected major version
if [[ ${#TARGET_VERSIONS[@]} -eq 0 ]]; then
    echo "[+] Auto-detecting latest stable PostgreSQL major version..."
    if ! LATEST_MAJOR=$(detect_latest_major_version); then
        echo -e "${C_RED}[!] Error: Failed to detect latest PostgreSQL version from Docker Hub (network unreachable).${C_RESET}" >&2
        exit 1
    fi
    echo "[+] Detected latest stable PostgreSQL major version: ${LATEST_MAJOR}"
    TARGET_VERSIONS=("${LATEST_MAJOR}")
else
    for i in "${!TARGET_VERSIONS[@]}"; do
        if [[ "${TARGET_VERSIONS[$i]}" == "latest" ]]; then
            if ! LATEST_MAJOR=$(detect_latest_major_version); then
                echo -e "${C_RED}[!] Error: Failed to detect latest PostgreSQL version from Docker Hub (network unreachable).${C_RESET}" >&2
                exit 1
            fi
            TARGET_VERSIONS[$i]="$LATEST_MAJOR"
        fi
    done
fi

# Pre-flight check: Verify all requested versions exist BEFORE creating any directories
echo "[+] Validating requested PostgreSQL version(s) against Docker Hub..."
for VER in "${TARGET_VERSIONS[@]}"; do
    if [[ "$USE_POSTGIS" == "true" ]]; then
        probe_tag=$(resolve_postgis_tag "$VER")
        if ! check_docker_image_exists "postgis/postgis" "$probe_tag"; then
            echo -e "${C_RED}[!] Error: PostgreSQL PostGIS release '${VER}' (image: postgis/postgis:${probe_tag}) does not exist on Docker Hub.${C_RESET}" >&2
            available_versions=$(get_available_postgres_versions || true)
            if [[ -n "$available_versions" ]]; then
                echo -e "${C_YELLOW}[i] Available release versions: ${available_versions// /, }${C_RESET}" >&2
            fi
            echo -e "${C_YELLOW}[i] No directories or configurations were created.${C_RESET}" >&2
            exit 1
        fi
    else
        if ! check_docker_image_exists "library/postgres" "$VER"; then
            echo -e "${C_RED}[!] Error: PostgreSQL release '${VER}' (image: postgres:${VER}) does not exist on Docker Hub.${C_RESET}" >&2
            available_versions=$(get_available_postgres_versions || true)
            if [[ -n "$available_versions" ]]; then
                echo -e "${C_YELLOW}[i] Available release versions: ${available_versions// /, }${C_RESET}" >&2
            fi
            echo -e "${C_YELLOW}[i] No directories or configurations were created.${C_RESET}" >&2
            exit 1
        fi
    fi
done
echo "[✓] Requested PostgreSQL version(s) verified."

# Ensure base directory ~/.postgres exists and is owned by host user
mkdir -p "$HOME/.postgres"
chown "${USER}:${USER}" "$HOME/.postgres" 2>/dev/null || true
chmod 755 "$HOME/.postgres"

# Track if this is the first instance being processed in this run
is_first_instance=true

# Process each target version
for VER in "${TARGET_VERSIONS[@]}"; do
    if [[ "$USE_POSTGIS" == "true" ]]; then
        TAG="${VER}-postgis"
        CONTAINER_BASE="postgres-${VER}-postgis"
    else
        TAG="${VER}"
        CONTAINER_BASE="postgres-${VER}"
    fi

    TARGET_DIR="$HOME/.postgres/${TAG}"

    echo ""
    echo "${DIV_SUB}"
    echo "[+] Configuring PostgreSQL instance: ${TAG} (Container: ${CONTAINER_BASE})"
    echo "${DIV_SUB}"

    # Determine assigned port
    PORT=""
    if [[ -f "${TARGET_DIR}/docker-compose.yml" ]]; then
        # Preserve previously configured port if compose file already exists
        EXISTING_PORT=$(grep -oE '[0-9]+:5432' "${TARGET_DIR}/docker-compose.yml" | head -n 1 | cut -d: -f1 || true)
        if [[ -n "$EXISTING_PORT" ]]; then
            PORT="$EXISTING_PORT"
        fi
    fi

    if [[ -z "$PORT" ]]; then
        # Determine starting candidate port:
        if [[ -n "$CUSTOM_PORT" ]]; then
            if [[ "$is_first_instance" == "true" ]]; then
                candidate_port="$CUSTOM_PORT"
            else
                candidate_port="$next_available_port"
            fi
        else
            existing_subfolder_count=0
            if [[ -d "$HOME/.postgres" ]]; then
                existing_subfolder_count=$(find "$HOME/.postgres" -mindepth 1 -maxdepth 1 -type d ! -name "$TAG" | wc -l)
            fi

            if [[ "$is_first_instance" == "true" && "$existing_subfolder_count" -eq 0 ]]; then
                candidate_port="$DEFAULT_PORT"
            else
                candidate_port=$((DEFAULT_PORT + existing_subfolder_count))
            fi
        fi

        # Find the next free port without failing
        original_port="$candidate_port"
        while is_port_in_use "$candidate_port"; do
            if container_owns_port "$CONTAINER_BASE" "$candidate_port"; then
                break
            fi
            candidate_port=$((candidate_port + 1))
        done

        if [[ "$candidate_port" -ne "$original_port" ]]; then
            echo "[i] Port ${original_port} is busy; automatically using next available port: ${candidate_port}"
        fi

        PORT="$candidate_port"
        next_available_port=$((candidate_port + 1))
    fi

    is_first_instance=false

    echo "[+] Assigned host port: ${PORT}"

    # Check and ensure target directory structure exists before compose execution
    echo "[+] Verifying target directories in ${TARGET_DIR}..."
    mkdir -p "${TARGET_DIR}/data"
    mkdir -p "${TARGET_DIR}/config/conf.d"
    mkdir -p "${TARGET_DIR}/initdb.d"
    mkdir -p "${TARGET_DIR}/logs"
    mkdir -p "${TARGET_DIR}/shared"

    # Set appropriate ownership and permissions:
    # User-space configuration and scripts owned by host user
    chown -R "${USER}:${USER}" "${TARGET_DIR}/config" "${TARGET_DIR}/initdb.d" 2>/dev/null || true
    chmod -R 755 "${TARGET_DIR}/config" "${TARGET_DIR}/initdb.d"
    # Exchange directories (logs & shared) require write access for both host user and container engine
    chmod 777 "${TARGET_DIR}/logs" "${TARGET_DIR}/shared"

    CONFIG_UPDATED=false

    # Copy template configuration files idempotently
    if [[ ! -f "${TARGET_DIR}/config/conf.d/db.conf" ]] || [[ "$FORCE" == "true" ]]; then
        echo "[+] Installing db.conf to ${TARGET_DIR}/config/conf.d/db.conf..."
        cp "${SCRIPT_DIR}/files/db.conf" "${TARGET_DIR}/config/conf.d/db.conf"
        CONFIG_UPDATED=true
    elif ! cmp -s "${SCRIPT_DIR}/files/db.conf" "${TARGET_DIR}/config/conf.d/db.conf"; then
        echo "[+] Updating ${TARGET_DIR}/config/conf.d/db.conf with updated settings..."
        cp "${SCRIPT_DIR}/files/db.conf" "${TARGET_DIR}/config/conf.d/db.conf"
        CONFIG_UPDATED=true
    fi

    if [[ -d "${TARGET_DIR}/config/pg_hba.conf" ]]; then
        sudo rm -rf "${TARGET_DIR}/config/pg_hba.conf"
    fi
    if [[ ! -f "${TARGET_DIR}/config/pg_hba.conf" ]] || [[ "$FORCE" == "true" ]]; then
        echo "[+] Installing pg_hba.conf to ${TARGET_DIR}/config/pg_hba.conf..."
        cp "${SCRIPT_DIR}/files/pg_hba.conf" "${TARGET_DIR}/config/pg_hba.conf"
        CONFIG_UPDATED=true
    elif ! cmp -s "${SCRIPT_DIR}/files/pg_hba.conf" "${TARGET_DIR}/config/pg_hba.conf"; then
        echo "[+] Updating ${TARGET_DIR}/config/pg_hba.conf with updated rules..."
        cp "${SCRIPT_DIR}/files/pg_hba.conf" "${TARGET_DIR}/config/pg_hba.conf"
        CONFIG_UPDATED=true
    fi

    # Copy initdb script to inject include_dir into postgresql.conf during initialization
    if [[ ! -f "${TARGET_DIR}/initdb.d/00-init-conf.sh" ]]; then
        echo "[+] Installing 00-init-conf.sh to ${TARGET_DIR}/initdb.d/..."
        cp "${SCRIPT_DIR}/scripts/00-init-conf.sh" "${TARGET_DIR}/initdb.d/00-init-conf.sh"
        chmod +x "${TARGET_DIR}/initdb.d/00-init-conf.sh"
    elif [[ "$FORCE" == "true" ]] || ! cmp -s "${SCRIPT_DIR}/scripts/00-init-conf.sh" "${TARGET_DIR}/initdb.d/00-init-conf.sh"; then
        cp "${SCRIPT_DIR}/scripts/00-init-conf.sh" "${TARGET_DIR}/initdb.d/00-init-conf.sh"
        chmod +x "${TARGET_DIR}/initdb.d/00-init-conf.sh"
    fi

    # Detect host UID and GID dynamically to embed into docker-compose
    HOST_UID="$(id -u)"
    HOST_GID="$(id -g)"

    if [[ "$USE_POSTGIS" == "true" ]]; then
        POSTGIS_TAG=$(resolve_postgis_tag "$VER")
        PG_IMAGE="postgis/postgis:${POSTGIS_TAG}"
    else
        PG_IMAGE="postgres:${VER}"
    fi

    # Generate docker-compose.yml from template
    COMPOSE_FILE="${TARGET_DIR}/docker-compose.yml"
    NEW_COMPOSE=$(sed \
        -e "s|\${PG_IMAGE}|${PG_IMAGE}|g" \
        -e "s|\${CONTAINER_NAME}|${CONTAINER_BASE}|g" \
        -e "s|\${PG_PORT}|${PORT}|g" \
        -e "s|\${PG_USER}|${PG_USER}|g" \
        -e "s|\${PG_PASSWORD}|${PG_PASSWORD}|g" \
        -e "s|\${PG_DB}|${PG_DB}|g" \
        "${SCRIPT_DIR}/files/docker-compose.template.yml")

    if [[ ! -f "$COMPOSE_FILE" ]] || [[ "$FORCE" == "true" ]]; then
        echo "$NEW_COMPOSE" > "$COMPOSE_FILE"
        CONFIG_UPDATED=true
    else
        # Only rewrite if content actually changed
        CURRENT_COMPOSE=$(cat "$COMPOSE_FILE" 2>/dev/null || true)
        if [[ "$CURRENT_COMPOSE" != "$NEW_COMPOSE" ]]; then
            echo "$NEW_COMPOSE" > "$COMPOSE_FILE"
            CONFIG_UPDATED=true
        fi
    fi

    # If cluster already initialized, ensure include_dir is in postgresql.conf
    PGDATA_CONF="${TARGET_DIR}/data/pgdata/postgresql.conf"
    if [[ -f "$PGDATA_CONF" ]]; then
        if ! grep -q "include_dir = '/etc/postgresql/conf.d'" "$PGDATA_CONF" 2>/dev/null; then
            echo "[+] Adding include_dir directive to existing ${PGDATA_CONF}..."
            echo "" | sudo tee -a "$PGDATA_CONF" >/dev/null
            echo "# Custom configuration drops" | sudo tee -a "$PGDATA_CONF" >/dev/null
            echo "include_dir = '/etc/postgresql/conf.d'" | sudo tee -a "$PGDATA_CONF" >/dev/null
            CONFIG_UPDATED=true
        fi
    fi

    # Check container running state
    IS_RUNNING=false
    if docker ps --filter "name=^/${CONTAINER_BASE}$" --format '{{.Names}}' 2>/dev/null | grep -q "^${CONTAINER_BASE}$"; then
        IS_RUNNING=true
    fi

    if [[ "$IS_RUNNING" == "true" ]]; then
        if [[ "$CONFIG_UPDATED" == "true" || "$FORCE" == "true" ]]; then
            echo "[+] Configurations updated; restarting container ${CONTAINER_BASE} to reload changes..."
            (cd "$TARGET_DIR" && docker compose restart)
        else
            echo "[i] Container ${CONTAINER_BASE} is already active with latest configuration, skipping..."
        fi
    else
        echo "[+] Launching container ${CONTAINER_BASE} via Docker Compose..."
        (cd "$TARGET_DIR" && docker compose up -d)
    fi

    # Wait up to 15 seconds for postgres service readiness
    echo "[+] Verifying database service readiness..."
    for _ in {1..15}; do
        if docker exec "${CONTAINER_BASE}" pg_isready -U "${PG_USER}" >/dev/null 2>&1; then
            break
        fi
        sleep 1
    done

    # Ensure user-space configs, compose file, logs, and shared directories remain accessible to host user
    echo "[+] Ensuring user access permissions on configuration and exchange directories..."
    chown -R "${USER}:${USER}" "${TARGET_DIR}/config" "${TARGET_DIR}/initdb.d" "${TARGET_DIR}/docker-compose.yml" 2>/dev/null || true
    chmod -R 755 "${TARGET_DIR}/config" "${TARGET_DIR}/initdb.d"
    chmod 644 "${TARGET_DIR}/docker-compose.yml" 2>/dev/null || true
    chmod 777 "${TARGET_DIR}/logs" "${TARGET_DIR}/shared"

    # Mandatory UFW firewall rule for the instance port (restricted to LAN and container networks)
    configure_ufw_lan_private_port "${PORT}" "PostgreSQL"

    # Display clean connection summary block
    echo ""
    echo "${DIV_MAIN}"
    echo -e "${C_BOLD}${C_GREEN}[✓] PostgreSQL (${TAG}) Ready!${C_RESET}"
    echo "${DIV_SUB}"
    printf "%-18s: %s\n" "Container" "$CONTAINER_BASE"
    printf "%-18s: %s\n" "Host Port" "$PORT"
    printf "%-18s: %s\n" "Superuser" "$PG_USER"
    printf "%-18s: %s\n" "Password" "$PG_PASSWORD"
    printf "%-18s: %s\n" "Default Database" "$PG_DB"
    printf "%-18s: %s\n" "Connection URI" "postgresql://${PG_USER}:${PG_PASSWORD}@localhost:${PORT}/${PG_DB}"
    printf "%-18s: %s\n" "Host CLI Command" "psql --port ${PORT}"
    printf "%-18s: %s\n" "Data Directory" "${TARGET_DIR}/data"
    printf "%-18s: %s\n" "Config Directory" "${TARGET_DIR}/config/conf.d"
    printf "%-18s: %s\n" "Compose File" "${TARGET_DIR}/docker-compose.yml"
    echo "${DIV_MAIN}"
done

# Ensure container CLI helper tools are executable and linked into ~/.local/bin
chmod +x "${SCRIPT_DIR}/scripts/pg-docker-cli"
for tool in "psql" "pg_dump" "pg_restore" "pg_dumpall" "pgbench" "pg-stop-all" "pg-start-all"; do
    symlink_to_local_bin "${SCRIPT_DIR}/scripts/${tool}"
done

echo ""
echo "[✓] All PostgreSQL Docker instances processed successfully!"
