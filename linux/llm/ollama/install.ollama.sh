#!/usr/bin/env bash
# Description: Install and run Ollama with Open WebUI via Docker Compose
# Note: Implements the guidelines in installation.md. Completely idempotent.

set -euo pipefail

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
source "${SCRIPT_DIR}/../../install/utils.sh"

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Sets up the local Ollama and Open WebUI directories in ~/.ollama,
  copies the docker-compose.yml configuration, ensures Docker and Docker Compose
  are installed, and starts the containers in detached mode.

  Completely idempotent and safe to run repeatedly.

Options:
  --no-update   Skip apt update when installing Docker dependency
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
    echo "    Ollama is configured per-user in ~/.ollama." >&2
    echo "    Please run as your regular user: ./$(basename "$0")" >&2
    exit 1
fi

echo "================================================================================"
echo " Starting Ollama & Open WebUI Setup"
echo "================================================================================"

# 1. Require Docker & Docker Compose
echo "[+] Checking Docker and Docker Compose..."
if ! command -v docker >/dev/null 2>&1 || ! docker compose version >/dev/null 2>&1; then
    echo "[!] Docker or Docker Compose not found. Installing Docker..."
    if [[ "$SKIP_UPDATE" == "true" ]]; then
        require_app "docker" "apps-recommended" --no-update
    else
        require_app "docker" "apps-recommended"
    fi
else
    echo "[✓] Docker and Docker Compose are installed."
fi

# 2. Setup ~/.ollama directories and files
TARGET_DIR="${HOME}/.ollama"
echo "[+] Setting up Ollama directory at ${TARGET_DIR}..."
mkdir -p "${TARGET_DIR}/ollama_data"
mkdir -p "${TARGET_DIR}/open_webui_data"

if [[ -f "${SCRIPT_DIR}/docker-compose.yml" ]]; then
    echo "[+] Copying docker-compose.yml to ${TARGET_DIR}..."
    cp -f "${SCRIPT_DIR}/docker-compose.yml" "${TARGET_DIR}/docker-compose.yml"
fi

# 3. Start services via Docker Compose
echo "[+] Starting Ollama and Open WebUI containers..."
cd "${TARGET_DIR}"

if docker compose up -d; then
    echo "[✓] Containers started successfully."
else
    echo "[!] Standard docker compose command failed, attempting with sudo..."
    sudo docker compose up -d
    echo "[✓] Containers started successfully with sudo."
fi

echo ""
echo "================================================================================"
echo " Service Endpoints"
echo "================================================================================"
echo "  - Ollama API:    http://localhost:11434"
echo "  - Open WebUI:    http://localhost:3020"
echo ""
echo "  To view logs:    cd ~/.ollama && docker compose logs -f"
echo "  To stop service: cd ~/.ollama && docker compose down"
echo "================================================================================"
echo "[✓] Ollama & Open WebUI installation completed successfully!"
echo "================================================================================"
