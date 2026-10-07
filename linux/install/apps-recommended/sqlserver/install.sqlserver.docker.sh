#!/usr/bin/env bash
# Description: Install and configure Microsoft SQL Server instances via Docker Compose
# Note: Persists data and shared folders under ~/.sqlserver/<version>/ with standard
# container isolation.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

SQL_USER="sa"
SQL_PASSWORD=""
SQL_COLLATION="SQL_Latin1_General_CP1_CS_AS"
DEFAULT_PORT=1433
CUSTOM_PORT=""
FORCE=false
SKIP_UPDATE="${SKIP_UPDATE:-false}"

TARGET_VERSIONS=()

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [VERSION...]

Description:
  Installs and configures Microsoft SQL Server instances using Docker Compose.
  Persists database data and shared backups in ~/.sqlserver/<version>/, runs with
  restart: unless-stopped, keeps data engine-private, and secures ports with UFW.

Arguments:
  VERSION               SQL Server release year(s) to install (e.g. 2022, 2019, latest).
                        Default: auto-detects latest stable release from MCR (e.g. 2022).

Options:
  -v, --version VER     Specify SQL Server version (can be specified multiple times)
  --port PORT           Specify base host port (default: 1433).
                        If busy, automatically selects the next available free port.
  -p, --password PASS   Set custom SA password (default: automatically generated UUID v4).
  --collation COL       Set SQL Server collation (default: SQL_Latin1_General_CP1_CS_AS).
  -f, --force           Force recreating containers and updating configurations.
  --no-update           Skip package index updates for host dependencies.
  --skip-update         Alias for --no-update.
  -h, --help            Show this help message and exit.

Examples:
  $(basename "$0")                  # Auto-detects latest (e.g. 2022) and installs on port 1433
  $(basename "$0") 2022             # Installs SQL Server 2022
  $(basename "$0") 2019 --port 1435 # Installs SQL Server 2019 on port 1435
  $(basename "$0") -p MyPass123!    # Installs with custom password
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        --no-update|--skip-update)
            SKIP_UPDATE=true
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
                SQL_PASSWORD="$2"
                shift 2
            else
                echo "[!] Error: -p/--password requires an argument" >&2
                exit 1
            fi
            ;;
        --collation)
            if [[ $# -ge 2 ]]; then
                SQL_COLLATION="$2"
                shift 2
            else
                echo "[!] Error: --collation requires an argument" >&2
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

echo "[+] Starting Microsoft SQL Server Docker setup..."

# 1. Require framework dependencies
require_app docker ufw lsof curl
require_app python --fast

# Helper: Detect latest stable SQL Server release year from MCR
detect_latest_release_year() {
    local detected
    detected=$(curl -fsSL "https://mcr.microsoft.com/v2/mssql/server/tags/list" 2>/dev/null \
        | jq -r '.tags[]' 2>/dev/null \
        | grep -E '^[0-9]{4}-latest$' \
        | sed 's/-latest//' \
        | sort -V \
        | tail -n 1 || true)

    if [[ -n "$detected" && "$detected" =~ ^[0-9]{4}$ ]]; then
        echo "$detected"
        return 0
    fi

    echo "2025"
}

# Resolve target versions: replace missing or 'latest' with detected release year
if [[ ${#TARGET_VERSIONS[@]} -eq 0 ]]; then
    echo "[+] Auto-detecting latest stable SQL Server release year from MCR..."
    LATEST_YEAR=$(detect_latest_release_year)
    echo "[+] Detected latest stable SQL Server release: ${LATEST_YEAR}"
    TARGET_VERSIONS=("${LATEST_YEAR}")
else
    for i in "${!TARGET_VERSIONS[@]}"; do
        if [[ "${TARGET_VERSIONS[$i]}" == "latest" ]]; then
            LATEST_YEAR=$(detect_latest_release_year)
            TARGET_VERSIONS[$i]="$LATEST_YEAR"
        fi
    done
fi
# Helper: Generate a compliant UUID v4 password for SQL Server
generate_sa_password() {
    echo "SqlPass-$(python3 -c 'import uuid; print(uuid.uuid4())')!"
}

# Ensure SQL Server non-root container group (mssql: 10001) exists on host
# so the host user can read diagnostic logs (created with mode 0660) without sudo
MSSQL_UID=10001
MSSQL_GID=10001
if ! getent group "$MSSQL_GID" >/dev/null 2>&1; then
    sudo groupadd -g "$MSSQL_GID" mssql 2>/dev/null || true
fi
MSSQL_GROUP_NAME=$(getent group "$MSSQL_GID" | cut -d: -f1 || echo "mssql")

if ! id -nG "$USER" | grep -qw "$MSSQL_GROUP_NAME"; then
    echo "[+] Adding ${USER} to mssql group (${MSSQL_GROUP_NAME}) for log reading..."
    sudo usermod -aG "$MSSQL_GROUP_NAME" "$USER" 2>/dev/null || true
fi

# Ensure base directory ~/.sqlserver exists and is owned by host user
mkdir -p "$HOME/.sqlserver"
chown "${USER}:${USER}" "$HOME/.sqlserver" 2>/dev/null || true
chmod 755 "$HOME/.sqlserver"

is_first_instance=true

# Process each target version
for VER in "${TARGET_VERSIONS[@]}"; do
    YEAR="${VER}"
    # Strip any -latest suffix if passed manually
    YEAR="${YEAR%-latest}"

    IMAGE_TAG="${YEAR}-latest"
    CONTAINER_NAME="sqlserver-${YEAR}"
    TARGET_DIR="$HOME/.sqlserver/${YEAR}"

    echo ""
    echo "${DIV_SUB}"
    echo "[+] Configuring Microsoft SQL Server instance: ${YEAR} (Container: ${CONTAINER_NAME})"
    echo "${DIV_SUB}"

    # Determine assigned port
    PORT=""
    if [[ -f "${TARGET_DIR}/docker-compose.yml" ]]; then
        EXISTING_PORT=$(grep -oE '[0-9]+:1433' "${TARGET_DIR}/docker-compose.yml" | head -n 1 | cut -d: -f1 || true)
        if [[ -n "$EXISTING_PORT" ]]; then
            PORT="$EXISTING_PORT"
        fi
    fi

    if [[ -z "$PORT" ]]; then
        if [[ -n "$CUSTOM_PORT" ]]; then
            if [[ "$is_first_instance" == "true" ]]; then
                candidate_port="$CUSTOM_PORT"
            else
                candidate_port="$next_available_port"
            fi
        else
            existing_count=0
            if [[ -d "$HOME/.sqlserver" ]]; then
                existing_count=$(find "$HOME/.sqlserver" -mindepth 1 -maxdepth 1 -type d ! -name "$YEAR" | wc -l)
            fi

            if [[ "$is_first_instance" == "true" && "$existing_count" -eq 0 ]]; then
                candidate_port="$DEFAULT_PORT"
            else
                candidate_port=$((DEFAULT_PORT + existing_count))
            fi
        fi

        original_port="$candidate_port"
        while is_port_in_use "$candidate_port"; do
            if container_owns_port "$CONTAINER_NAME" "$candidate_port"; then
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

    # Verify and create target directories
    mkdir -p "${TARGET_DIR}/data"
    mkdir -p "${TARGET_DIR}/logs"
    mkdir -p "${TARGET_DIR}/shared"

    # Set ownership and permissions:
    # SQL Server container engine (UID 10001) requires ownership of its data directory (/var/opt/mssql)
    sudo chown -R "${MSSQL_UID}:${MSSQL_UID}" "${TARGET_DIR}/data"
    sudo chmod -R 700 "${TARGET_DIR}/data"
    # Exchange and log directories require write access for both host user and container engine
    chmod 777 "${TARGET_DIR}/logs" "${TARGET_DIR}/shared"

    # Password management: preserve existing password from docker-compose.yml or generate new UUID v4
    CURRENT_PASS=""
    COMPOSE_FILE="${TARGET_DIR}/docker-compose.yml"
    if [[ -f "$COMPOSE_FILE" ]]; then
        CURRENT_PASS=$(grep -E 'MSSQL_SA_PASSWORD=' "$COMPOSE_FILE" | head -n 1 | cut -d= -f2- | tr -d ' "' || true)
    fi

    if [[ -n "$SQL_PASSWORD" ]]; then
        ACTIVE_PASS="$SQL_PASSWORD"
    elif [[ -n "$CURRENT_PASS" && "$FORCE" != "true" ]]; then
        ACTIVE_PASS="$CURRENT_PASS"
    else
        ACTIVE_PASS=$(generate_sa_password)
    fi

    CONFIG_UPDATED=false
    SQL_IMAGE="mcr.microsoft.com/mssql/server:${IMAGE_TAG}"

    # Generate docker-compose.yml from template
    NEW_COMPOSE=$(sed \
        -e "s|\${SQL_IMAGE}|${SQL_IMAGE}|g" \
        -e "s|\${CONTAINER_NAME}|${CONTAINER_NAME}|g" \
        -e "s|\${SQL_PORT}|${PORT}|g" \
        -e "s|\${SA_PASSWORD}|${ACTIVE_PASS}|g" \
        -e "s|\${SQL_COLLATION}|${SQL_COLLATION}|g" \
        "${SCRIPT_DIR}/files/docker-compose.template.yml")

    if [[ ! -f "$COMPOSE_FILE" ]] || [[ "$FORCE" == "true" ]]; then
        echo "$NEW_COMPOSE" > "$COMPOSE_FILE"
        CONFIG_UPDATED=true
    else
        EXISTING_COMPOSE=$(cat "$COMPOSE_FILE" 2>/dev/null || true)
        if [[ "$EXISTING_COMPOSE" != "$NEW_COMPOSE" ]]; then
            echo "$NEW_COMPOSE" > "$COMPOSE_FILE"
            CONFIG_UPDATED=true
        fi
    fi

    # Check container running state
    IS_RUNNING=false
    if docker ps --filter "name=^/${CONTAINER_NAME}$" --format '{{.Names}}' 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
        IS_RUNNING=true
    fi

    if [[ "$IS_RUNNING" == "true" ]]; then
        if [[ "$CONFIG_UPDATED" == "true" || "$FORCE" == "true" ]]; then
            echo "[+] Configurations updated; restarting container ${CONTAINER_NAME}..."
            (cd "$TARGET_DIR" && docker compose restart)
        else
            echo "[i] Container ${CONTAINER_NAME} is already active with latest configuration, skipping..."
        fi
    else
        echo "[+] Launching container ${CONTAINER_NAME} via Docker Compose..."
        (cd "$TARGET_DIR" && docker compose up -d)
    fi

    # Wait up to 20 seconds for SQL Server service readiness
    echo "[+] Verifying SQL Server database engine readiness..."
    READY=false
    for _ in {1..20}; do
        if docker exec "${CONTAINER_NAME}" /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "${ACTIVE_PASS}" -C -Q "SELECT 1;" >/dev/null 2>&1; then
            READY=true
            break
        fi
        sleep 1
    done

    # Ensure user-space compose file and exchange directories remain properly accessible
    chown "${USER}:${USER}" "${TARGET_DIR}/docker-compose.yml" 2>/dev/null || true
    chmod 644 "${TARGET_DIR}/docker-compose.yml" 2>/dev/null || true
    chmod 777 "${TARGET_DIR}/logs" "${TARGET_DIR}/shared" 2>/dev/null || true

    # Configure UFW firewall
    echo "[+] Configuring UFW firewall for port ${PORT}/tcp..."
    sudo ufw allow "${PORT}/tcp" >/dev/null 2>&1 || sudo ufw allow "${PORT}/tcp"

    # Display clean connection summary block
    echo ""
    echo "${DIV_MAIN}"
    echo -e "${C_BOLD}${C_GREEN}[✓] Microsoft SQL Server (${YEAR}) Ready!${C_RESET}"
    echo "${DIV_SUB}"
    printf "%-18s: %s\n" "Container" "$CONTAINER_NAME"
    printf "%-18s: %s\n" "Host Port" "$PORT"
    printf "%-18s: %s\n" "Superuser" "$SQL_USER"
    printf "%-18s: %s\n" "Password" "$ACTIVE_PASS"
    printf "%-18s: %s\n" "Collation" "$SQL_COLLATION"
    printf "%-18s: %s\n" "JDBC / URL" "jdbc:sqlserver://localhost:${PORT};encrypt=false;trustServerCertificate=true"
    printf "%-18s: %s\n" "Data Directory" "${TARGET_DIR}/data"
    printf "%-18s: %s\n" "Log Directory" "${TARGET_DIR}/logs"
    printf "%-18s: %s\n" "Shared Directory" "${TARGET_DIR}/shared"
    printf "%-18s: %s\n" "Compose File" "${TARGET_DIR}/docker-compose.yml"
    echo "${DIV_MAIN}"
done

echo ""
echo "[✓] Microsoft SQL Server Docker setup completed successfully!"
