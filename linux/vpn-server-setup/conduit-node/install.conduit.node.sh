#!/usr/bin/env bash
# Description: Install and setup Psiphon Conduit Node container
# Note: Sets up ~/.conduit-node, configures dynamic UID:GID, configures UFW firewall, and starts services.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../install/utils.sh"

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Sets up and starts Psiphon Conduit Node along with Prometheus and Grafana.
  Copies configs to ~/.conduit-node, dynamically configures container user permissions,
  applies firewall rules, and launches the Docker Compose stack.

Options:
  --no-update   Skip apt update when installing dependencies
  -h, --help    Show this help message and exit
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
        *)
            echo "[!] Unknown option: $1" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
    esac
done

# Prevent running via sudo to preserve user's HOME and permissions
if [[ -n "${SUDO_USER:-}" && $EUID -eq 0 ]]; then
    echo "[!] Error: Do not run $(basename "$0") with sudo." >&2
    echo "    Run as your regular user: ./$(basename "$0")" >&2
    echo "    Sudo will be requested internally when needed." >&2
    exit 1
fi

echo "================================================================================"
echo " Starting Conduit Node Setup"
echo "================================================================================"

# 1. Require Docker and UFW dependencies
echo "[+] Checking Docker and Docker Compose..."
if ! command -v docker >/dev/null 2>&1 || ! docker compose version >/dev/null 2>&1; then
    echo "[!] Docker or Docker Compose not found. Installing docker via utils.sh..."
    require_app "docker" "apps-recommended"
else
    echo "[✓] Docker and Docker Compose are installed."
fi

echo "[+] Checking UFW..."
if ! command -v ufw >/dev/null 2>&1; then
    echo "[!] UFW not found. Installing ufw via utils.sh..."
    require_app "ufw" "apps-recommended"
else
    echo "[✓] UFW is installed."
fi

# 2. Conduit Node Directory & File Setup
TARGET_DIR="${HOME}/.conduit-node"
FILES_DIR="${SCRIPT_DIR}/files"

echo "[+] Creating Conduit Node directories in ${TARGET_DIR}..."
mkdir -p "${TARGET_DIR}/data"
mkdir -p "${TARGET_DIR}/grafana_data"
mkdir -p "${TARGET_DIR}/prometheus_data"

echo "[+] Copying configuration files to ${TARGET_DIR}..."
cp "${FILES_DIR}/docker-compose.yml" "${TARGET_DIR}/"
cp "${FILES_DIR}/prometheus.yml" "${TARGET_DIR}/"
cp -r "${FILES_DIR}/grafana-provisioning" "${TARGET_DIR}/"

# 3. Dynamically set user in docker-compose.yml
CURRENT_UID="$(id -u)"
CURRENT_GID="$(id -g)"
CURRENT_USER_ID="${CURRENT_UID}:${CURRENT_GID}"

echo "[+] Updating user to ${CURRENT_USER_ID} in ${TARGET_DIR}/docker-compose.yml..."
sed -i "s/1000:1000/${CURRENT_USER_ID}/g" "${TARGET_DIR}/docker-compose.yml"

# Ensure user ownership of ~/.conduit-node and all files
sudo chown -R "${CURRENT_USER_ID}" "${TARGET_DIR}"

# 4. Firewall Rules
echo "[+] Applying firewall rules..."
if command -v ufw >/dev/null 2>&1; then
    # Allow access from Grafana to Prometheus in the Docker network
    sudo ufw allow from 172.16.0.0/12
    sudo ufw allow from 10.0.0.0/8
    # Allow access to Grafana dashboard and Prometheus from local machine through SSH tunneling
    sudo ufw allow OpenSSH
    sudo ufw allow 22
else
    echo "[!] UFW not found, skipping firewall rules."
fi

# 5. Start the Service
echo "[+] Starting Conduit services via Docker Compose..."
cd "${TARGET_DIR}"

if docker compose up -d; then
    echo "[✓] Conduit node services started successfully!"
else
    echo "[!] Trying docker compose with sudo..."
    sudo docker compose up -d
    echo "[✓] Conduit node services started successfully with sudo!"
fi

# Ensure user ownership after containers start
sudo chown -R "${CURRENT_USER_ID}" "${TARGET_DIR}"

echo ""
echo "================================================================================"
echo "[✓] Conduit Node setup completed successfully!"
echo "================================================================================"
