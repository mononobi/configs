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

# 1. Require framework dependencies: Docker and UFW
require_app docker ufw

# 2. Ensure lightweight host client tools (psql, pg_dump) are available
if ! is_installed --check "psql"; then
    echo "[+] Installing postgresql-client on host for terminal CLI access..."
    conditional_apt_update
    sudo apt-get install -y postgresql-client
fi

# Helper: Detect latest stable major version via Docker metadata with clean fallback
detect_latest_major_version() {
    local detected=""

    # Tier 1: Query Docker Registry v2 API directly for OCI annotations (no layer downloads)
    local repo="library/postgres"
    local token
    token=$(curl -fsSL "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${repo}:pull" 2>/dev/null | jq -r .token || true)
    if [[ -n "$token" && "$token" != "null" ]]; then
        detected=$(curl -fsSL -H "Authorization: Bearer ${token}" \
            -H "Accept: application/vnd.docker.distribution.manifest.v2+json,application/vnd.oci.image.index.v1+json" \
            "https://registry-1.docker.io/v2/${repo}/manifests/latest" 2>/dev/null \
            | jq -r '.. | .["org.opencontainers.image.version"]? // empty' 2>/dev/null | head -n 1 | cut -d. -f1 || true)
    fi

    if [[ -n "$detected" && "$detected" =~ ^[0-9]+$ ]]; then
        echo "$detected"
        return 0
    fi

    # Tier 2: Fallback to pulling temporary :latest image, inspecting PG_MAJOR, and removing it
    local temp_image="postgres:latest"
    if docker pull -q "$temp_image" >/dev/null 2>&1; then
        detected=$(docker inspect "$temp_image" --format '{{range .Config.Env}}{{println .}}{{end}}' 2>/dev/null \
            | grep '^PG_MAJOR=' | cut -d= -f2 | head -n 1 || true)
        # Clean up temporary :latest image immediately
        docker rmi "$temp_image" >/dev/null 2>&1 || true
        if [[ -n "$detected" && "$detected" =~ ^[0-9]+$ ]]; then
            echo "$detected"
            return 0
        fi
    fi

    # Tier 3: Query postgresql.org API or default fallback
    local api_ver
    api_ver=$(python3 -c '
import urllib.request, json
try:
    with urllib.request.urlopen("https://www.postgresql.org/versions.json", timeout=3) as r:
        for v in json.loads(r.read().decode()):
            if v.get("current"):
                print(v["major"])
                break
except Exception:
    pass
' 2>/dev/null || true)

    if [[ -n "$api_ver" && "$api_ver" =~ ^[0-9]+$ ]]; then
        echo "$api_ver"
        return 0
    fi

    echo "18"
}

# Helper: Resolve appropriate PostGIS tag for a major version
resolve_postgis_tag() {
    local major="$1"
    if curl -fsSL "https://hub.docker.com/v2/repositories/postgis/postgis/tags/${major}" >/dev/null 2>&1; then
        echo "${major}"
        return 0
    fi
    local matched
    matched=$(curl -fsSL "https://hub.docker.com/v2/repositories/postgis/postgis/tags?page_size=20" 2>/dev/null \
        | jq -r '.results[].name' 2>/dev/null | grep -E "^${major}-[0-9.]+$" | head -n 1 || true)
    if [[ -n "$matched" ]]; then
        echo "$matched"
        return 0
    fi
    echo "${major}"
}

# Resolve target versions: replace missing or 'latest' with detected major version
if [[ ${#TARGET_VERSIONS[@]} -eq 0 ]]; then
    echo "[+] Auto-detecting latest stable PostgreSQL major version..."
    LATEST_MAJOR=$(detect_latest_major_version)
    echo "[+] Detected latest stable PostgreSQL major version: ${LATEST_MAJOR}"
    TARGET_VERSIONS=("${LATEST_MAJOR}")
else
    for i in "${!TARGET_VERSIONS[@]}"; do
        if [[ "${TARGET_VERSIONS[$i]}" == "latest" ]]; then
            LATEST_MAJOR=$(detect_latest_major_version)
            TARGET_VERSIONS[$i]="$LATEST_MAJOR"
        fi
    done
fi

# Helper: Check if a TCP port is currently listening
is_port_in_use() {
    local port="$1"
    if ss -tuln "sport = :${port}" 2>/dev/null | grep -q ":${port} "; then
        return 0
    fi
    if command -v lsof >/dev/null 2>&1; then
        lsof -iTCP:"$port" -sTCP:LISTEN -n -P >/dev/null 2>&1 && return 0
    fi
    return 1
}

# Helper: Check if a specific container owns the listening port
container_owns_port() {
    local cname="$1"
    local port="$2"
    if docker ps --filter "name=^/${cname}$" --format '{{.Ports}}' 2>/dev/null | grep -q "${port}->"; then
        return 0
    fi
    return 1
}

# Track if this is the first instance being processed in this run
is_first_instance=true

# Process each target version
for VER in "${TARGET_VERSIONS[@]}"; do
    TAG="$VER"
    CONTAINER_BASE="postgres-${TAG}"
    [[ "$USE_POSTGIS" == "true" ]] && CONTAINER_BASE="postgis-${TAG}"

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
        # Check if port 5432 should be used for primary instance
        if [[ "$is_first_instance" == "true" ]]; then
            PORT="$DEFAULT_PORT"
            if is_port_in_use "$PORT"; then
                if ! container_owns_port "$CONTAINER_BASE" "$PORT"; then
                    echo "[!] Error: Default port ${PORT} is already in use by another process." >&2
                    echo "[!] Cannot install primary PostgreSQL instance on ${PORT}. Halting." >&2
                    exit 1
                fi
            fi
        else
            # Calculate port for secondary versions: 5432 + subfolder_count, incrementing if busy
            subfolder_count=0
            if [[ -d "$HOME/.postgres" ]]; then
                subfolder_count=$(find "$HOME/.postgres" -mindepth 1 -maxdepth 1 -type d ! -name "$TAG" | wc -l)
            fi
            candidate_port=$((DEFAULT_PORT + subfolder_count))
            while is_port_in_use "$candidate_port"; do
                if container_owns_port "$CONTAINER_BASE" "$candidate_port"; then
                    break
                fi
                candidate_port=$((candidate_port + 1))
            done
            PORT="$candidate_port"
        fi
    fi

    is_first_instance=false

    echo "[+] Assigned host port: ${PORT}"

    # Check and ensure target directory structure exists before compose execution
    echo "[+] Verifying target directories in ${TARGET_DIR}..."
    mkdir -p "${TARGET_DIR}/data"
    mkdir -p "${TARGET_DIR}/config/conf.d"
    mkdir -p "${TARGET_DIR}/initdb.d"
    mkdir -p "${TARGET_DIR}/logs"

    # Copy template configuration files idempotently
    if [[ ! -f "${TARGET_DIR}/config/conf.d/db.conf" ]]; then
        echo "[+] Installing default db.conf to ${TARGET_DIR}/config/conf.d/db.conf..."
        cp "${SCRIPT_DIR}/files/db.conf" "${TARGET_DIR}/config/conf.d/db.conf"
    elif [[ "$FORCE" == "true" ]]; then
        echo "[+] Force-updating ${TARGET_DIR}/config/conf.d/db.conf..."
        cp "${SCRIPT_DIR}/files/db.conf" "${TARGET_DIR}/config/conf.d/db.conf"
    fi

    if [[ ! -f "${TARGET_DIR}/config/pg_hba.conf" ]]; then
        echo "[+] Installing default pg_hba.conf to ${TARGET_DIR}/config/pg_hba.conf..."
        cp "${SCRIPT_DIR}/files/pg_hba.conf" "${TARGET_DIR}/config/pg_hba.conf"
    elif [[ "$FORCE" == "true" ]]; then
        echo "[+] Force-updating ${TARGET_DIR}/config/pg_hba.conf..."
        cp "${SCRIPT_DIR}/files/pg_hba.conf" "${TARGET_DIR}/config/pg_hba.conf"
    fi

    # Detect host UID and GID dynamically to embed into docker-compose
    HOST_UID="$(id -u)"
    HOST_GID="$(id -g)"

    if [[ "$USE_POSTGIS" == "true" ]]; then
        POSTGIS_TAG=$(resolve_postgis_tag "$TAG")
        PG_IMAGE="postgis/postgis:${POSTGIS_TAG}"
    else
        PG_IMAGE="postgres:${TAG}"
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
        -e "s|\${HOST_UID}|${HOST_UID}|g" \
        -e "s|\${HOST_GID}|${HOST_GID}|g" \
        "${SCRIPT_DIR}/files/docker-compose.template.yml")

    if [[ ! -f "$COMPOSE_FILE" ]] || [[ "$FORCE" == "true" ]]; then
        echo "$NEW_COMPOSE" > "$COMPOSE_FILE"
    else
        # Only rewrite if content actually changed
        CURRENT_COMPOSE=$(cat "$COMPOSE_FILE" 2>/dev/null || true)
        if [[ "$CURRENT_COMPOSE" != "$NEW_COMPOSE" ]]; then
            echo "$NEW_COMPOSE" > "$COMPOSE_FILE"
        fi
    fi

    # Check container running state
    IS_RUNNING=false
    if docker ps --filter "name=^/${CONTAINER_BASE}$" --format '{{.Names}}' 2>/dev/null | grep -q "^${CONTAINER_BASE}$"; then
        IS_RUNNING=true
    fi

    if [[ "$IS_RUNNING" == "true" && "$FORCE" != "true" ]]; then
        echo "[i] Container ${CONTAINER_BASE} is already active and running, skipping compose up..."
    else
        echo "[+] Launching container ${CONTAINER_BASE} via Docker Compose..."
        (cd "$TARGET_DIR" && docker compose up -d)

        # Wait up to 15 seconds for postgres service readiness
        echo "[+] Verifying database service readiness..."
        for _ in {1..15}; do
            if docker exec "${CONTAINER_BASE}" pg_isready -U "${PG_USER}" >/dev/null 2>&1; then
                break
            fi
            sleep 1
        done
    fi

    # Mandatory UFW firewall rule for the instance port
    echo "[+] Configuring UFW firewall for port ${PORT}/tcp..."
    sudo ufw allow "${PORT}/tcp" >/dev/null 2>&1 || sudo ufw allow "${PORT}/tcp"

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
    printf "%-18s: %s\n" "Host CLI Command" "psql -h localhost -p ${PORT} -U ${PG_USER} -d ${PG_DB}"
    printf "%-18s: %s\n" "Data Directory" "${TARGET_DIR}/data"
    printf "%-18s: %s\n" "Config Directory" "${TARGET_DIR}/config/conf.d"
    printf "%-18s: %s\n" "Compose File" "${TARGET_DIR}/docker-compose.yml"
    echo "${DIV_MAIN}"
done

echo ""
echo "[✓] All PostgreSQL Docker instances processed successfully!"
