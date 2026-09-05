#!/usr/bin/env bash
# Description: Install and configure PostgreSQL, PostGIS, and configuration files
# Note: Supports auto-detecting latest stable release or installing a user-specified version.

set -euo pipefail

PG_VERSION=""
PG_PASSWORD="123"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [VERSION]

Description:
  Installs PostgreSQL Server and PostGIS extension from the official PostgreSQL (PGDG) APT repository.
  Applies custom db.conf configuration, sets default password, and configures the service.
  If no version is specified, it automatically detects and installs the latest stable version.

Arguments:
  VERSION               PostgreSQL major version (e.g. 17, 16, 15). Default: auto-detects latest stable

Options:
  -v, --version VER     Specify PostgreSQL major version
  -p, --password PASS   Set password for the postgres superuser (default: 123)
  -h, --help            Show this help message and exit

Examples:
  $(basename "$0")              # Auto-detects and installs the latest stable version
  $(basename "$0") 16           # Installs PostgreSQL 16
  $(basename "$0") -v 17 -p 123 # Installs PostgreSQL 17 with password 123
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            PG_VERSION="$2"
            shift 2
            ;;
        -p|--password)
            PG_PASSWORD="$2"
            shift 2
            ;;
        [0-9]*)
            PG_VERSION="$1"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

echo "[+] Starting installation/setup for PostgreSQL..."

# 1. Update system and install prerequisites
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y wget ca-certificates curl gnupg lsb-release

# 2. Add official PostgreSQL PGDG repository & GPG keyring
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/postgresql.gpg > /dev/null
sudo chmod 644 /etc/apt/keyrings/postgresql.gpg

RELEASE=$(lsb_release -cs)
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt ${RELEASE}-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list > /dev/null

sudo apt-get update

# 3. Resolve target PostgreSQL version (auto-detect latest if not provided)
if [[ -z "$PG_VERSION" ]]; then
    echo "[+] Auto-detecting latest stable PostgreSQL version from repository..."
    DETECTED_VER=$(apt-cache search '^postgresql-[0-9]+$' 2>/dev/null | awk '{print $1}' | grep -Po '[0-9]+' | sort -n | tail -1 || true)

    if [[ -z "$DETECTED_VER" ]]; then
        DETECTED_VER=$(python3 -c '
import urllib.request, json
try:
    with urllib.request.urlopen("https://www.postgresql.org/versions.json", timeout=5) as r:
        for v in json.loads(r.read().decode()):
            if v.get("current"):
                print(v["major"])
                break
except Exception:
    pass
' 2>/dev/null || true)
    fi

    PG_VERSION="${DETECTED_VER:-17}"
fi

echo "[+] Selected PostgreSQL version: $PG_VERSION"

# 4. Install PostgreSQL and client tools
echo "[+] Installing postgresql-${PG_VERSION} and contrib..."
sudo apt-get install -y "postgresql-${PG_VERSION}" "postgresql-contrib-${PG_VERSION}" "postgresql-client-${PG_VERSION}"

# Install PostGIS for this PostgreSQL version if available
echo "[+] Installing PostGIS extension packages..."
sudo apt-get install -y "postgresql-${PG_VERSION}-postgis-3" "postgresql-${PG_VERSION}-postgis-3-scripts" postgis 2>/dev/null || sudo apt-get install -y postgis || true

# 5. Copy custom db.conf into conf.d directory if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF_D="/etc/postgresql/${PG_VERSION}/main/conf.d"

if [[ -f "$SCRIPT_DIR/db.conf" ]]; then
    sudo mkdir -p "$CONF_D"
    echo "[+] Copying db.conf to $CONF_D/db.conf..."
    sudo cp "$SCRIPT_DIR/db.conf" "$CONF_D/db.conf"
    sudo chown postgres:postgres "$CONF_D/db.conf"
    sudo chmod 644 "$CONF_D/db.conf"
fi

# 6. Ensure PostgreSQL service is started
sudo systemctl enable --now postgresql

# 7. Set default password for postgres database superuser
echo "[+] Setting password for 'postgres' database user to '$PG_PASSWORD'..."
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '$PG_PASSWORD';"

# 8. Restart service to apply configuration
echo "[+] Restarting PostgreSQL service..."
sudo systemctl restart postgresql

# 9. Verify service and listening port
echo "[+] Checking PostgreSQL service status..."
sudo systemctl is-active --quiet postgresql && echo "[✓] PostgreSQL service is active and running." || sudo systemctl status postgresql --no-pager
sudo ss -tunelp | grep 5432 || true

echo "[✓] PostgreSQL ${PG_VERSION} setup completed successfully!"
