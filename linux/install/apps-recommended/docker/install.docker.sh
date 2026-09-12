#!/usr/bin/env bash
# Description: Install and configure Docker CE & Compose
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Docker Engine, Docker CLI, Docker Compose Plugin, sets user permissions,
  and initializes/enables Watchtower for automated container updates.

Options:
  --no-update   Skip apt update before installation
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
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

echo "[+] Starting installation/setup for Docker CE & Compose..."

if [[ "$SKIP_UPDATE" != "true" ]]; then
    sudo apt-get update
fi
sudo apt-get install -y ca-certificates curl gnupg lsb-release

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/docker.gpg > /dev/null
sudo chmod 644 /etc/apt/keyrings/docker.gpg

CODENAME=$(lsb_release -cs)
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin pass gnupg2

sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
echo "[+] Docker CE and Compose installed. User $USER added to docker group (re-login required)."

# Configure & Enable Watchtower
echo ""
echo "--------------------------------------------------------------------------------"
echo "[+] Configuring Watchtower..."
echo "--------------------------------------------------------------------------------"

WATCHTOWER_DIR="${HOME}/.watchtower"
WATCHTOWER_SRC="${SCRIPT_DIR}/watchtower/docker-compose.yml"

mkdir -p "$WATCHTOWER_DIR"

if [[ -f "$WATCHTOWER_SRC" ]]; then
    if ! cmp -s "$WATCHTOWER_SRC" "${WATCHTOWER_DIR}/docker-compose.yml" 2>/dev/null; then
        cp "$WATCHTOWER_SRC" "${WATCHTOWER_DIR}/docker-compose.yml"
        echo "[+] Copied Watchtower configuration to ${WATCHTOWER_DIR}/docker-compose.yml"
    else
        echo "[+] Watchtower configuration in ${WATCHTOWER_DIR}/ is already up to date."
    fi
else
    echo "[!] Warning: Watchtower template not found at ${WATCHTOWER_SRC}" >&2
fi

if [[ -f "${WATCHTOWER_DIR}/docker-compose.yml" ]]; then
    echo "[+] Starting/verifying Watchtower service..."
    if docker info >/dev/null 2>&1; then
        docker compose -f "${WATCHTOWER_DIR}/docker-compose.yml" up -d
    else
        # If user session has not reloaded group memberships yet, run via sudo
        sudo docker compose -f "${WATCHTOWER_DIR}/docker-compose.yml" up -d
    fi
    echo "[✓] Watchtower is active and monitoring containers."
fi

echo ""
echo "[✓] Docker CE, Compose & Watchtower setup completed successfully!"
