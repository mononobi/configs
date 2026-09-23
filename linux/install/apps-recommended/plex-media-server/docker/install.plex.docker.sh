#!/usr/bin/env bash
# Description: Install and configure Plex Media Server via Docker Compose
# Note: Modernized for Ubuntu with hardware acceleration (AMD iGPU / Intel QSV),
#       RAM-based transcoding, host LAN discovery, and 1:1 host media path preservation.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../../utils.sh"

SKIP_UPDATE="${SKIP_UPDATE:-false}"
FORCE="${FORCE:-false}"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Sets up and launches Plex Media Server via official Docker container with:
  - AMD / Intel GPU hardware decoding & transcoding (/dev/dri)
  - Transcoding in shared RAM (/dev/shm/plex)
  - LAN network discovery (host network mode)
  - 1:1 preserved host media paths (/mnt/movies-* and /mnt/movies-7/TV-Shows)
  - Persistent metadata in ~/.plex/plexmediaserver

Options:
  -f, --force       Force update, reconfiguration, and restart of the container
  --no-update       Skip apt update before installing dependencies
  --skip-update     Alias for --no-update
  -h, --help        Show this help message and exit
EOF
}

# Parse arguments
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
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

check_plex_running() {
    if command -v docker >/dev/null 2>&1; then
        if docker ps --format '{{.Names}}' 2>/dev/null | grep -qx "plex-media-server"; then
            return 0
        fi
        if sudo docker ps --format '{{.Names}}' 2>/dev/null | grep -qx "plex-media-server"; then
            return 0
        fi
    fi
    return 1
}

# Fast-path check: skip if Plex is already running and force is not set
if [[ "$FORCE" != "true" ]] && check_plex_running; then
    echo -e "${C_GREEN}[i] Plex Media Server (Docker) is already running, skipping...${C_RESET}"
    exit 0
fi

echo -e "${C_BLUE}${DIV_MAIN}${C_RESET}"
echo -e "${C_BOLD}[+] Configuring Plex Media Server via Docker Compose...${C_RESET}"
echo -e "${C_BLUE}${DIV_MAIN}${C_RESET}"

# Ensure Docker is installed and ready
conditional_apt_update
require_app docker

CURRENT_USER="${USER:-mono}"
USER_UID="$(id -u "$CURRENT_USER" 2>/dev/null || id -u)"
USER_GID="$(id -g "$CURRENT_USER" 2>/dev/null || id -g)"

PLEX_BASE_DIR="${HOME}/.plex"
PLEX_DATA_DIR="${PLEX_BASE_DIR}/plexmediaserver"
PLEX_TRANSCODE_DIR="/dev/shm/plex"
COMPOSE_SRC="${SCRIPT_DIR}/docker-compose.yml"
COMPOSE_DEST="${PLEX_BASE_DIR}/docker-compose.yml"

echo "[+] Preparing host metadata and RAM transcode directories..."
mkdir -p "${PLEX_DATA_DIR}"
mkdir -p "${PLEX_TRANSCODE_DIR}"

sudo chown -R "${USER_UID}:${USER_GID}" "${PLEX_BASE_DIR}"
chmod -R 775 "${PLEX_BASE_DIR}"
chmod 1777 "${PLEX_TRANSCODE_DIR}"

# Verify media directories exist on host
media_paths=(
    "/mnt/movies-1/Movies-1"
    "/mnt/movies-2/Movies-2"
    "/mnt/movies-3/Movies-3"
    "/mnt/movies-4/Movies-4"
    "/mnt/movies-5/Movies-5"
    "/mnt/movies-6/Movies-6"
    "/mnt/movies-7/Movies-7"
    "/mnt/movies-7/TV-Shows"
)

echo "[+] Checking host media library mount points..."
for path in "${media_paths[@]}"; do
    if [[ ! -d "$path" ]]; then
        echo -e "${C_YELLOW}[!] Notice: Media directory '${path}' not currently mounted on host.${C_RESET}"
        echo -e "    Creating placeholder directory to avoid Docker bind mount error..."
        sudo mkdir -p "$path"
    fi
done

# Ensure user is part of video and render groups for GPU acceleration
echo "[+] Checking GPU hardware acceleration groups..."
for grp in video render; do
    if getent group "$grp" >/dev/null 2>&1; then
        if ! id -nG "$CURRENT_USER" | grep -qw "$grp"; then
            echo "[+] Adding ${CURRENT_USER} to group '${grp}' for GPU passthrough..."
            sudo usermod -aG "$grp" "$CURRENT_USER"
        fi
    fi
done

# Deploy docker-compose.yml to host destination
if [[ -f "$COMPOSE_SRC" ]]; then
    if ! cmp -s "$COMPOSE_SRC" "$COMPOSE_DEST" 2>/dev/null; then
        cp "$COMPOSE_SRC" "$COMPOSE_DEST"
        echo "[+] Deployed Plex Docker Compose file to ${COMPOSE_DEST}"
    else
        echo "[+] Compose configuration in ${COMPOSE_DEST} is already up to date."
    fi
else
    echo "[!] Error: Source compose file not found at ${COMPOSE_SRC}" >&2
    exit 1
fi

# Configure UFW firewall rules if active
if command -v ufw >/dev/null 2>&1 && sudo ufw status | grep -qw "active"; then
    echo "[+] Configuring UFW firewall rules for Plex streaming & local LAN discovery..."
    sudo ufw allow 32400/tcp comment 'Plex Web & Streaming' >/dev/null
    sudo ufw allow 32410:32414/udp comment 'Plex GDM Discovery' >/dev/null
    sudo ufw allow 1900/udp comment 'Plex DLNA' >/dev/null
fi

# Start or restart Plex container
echo "[+] Launching Plex Media Server container..."
if docker info >/dev/null 2>&1; then
    docker compose -f "${COMPOSE_DEST}" up -d
else
    sudo docker compose -f "${COMPOSE_DEST}" up -d
fi

echo ""
echo -e "${C_GREEN}[✓] Plex Media Server (Docker) setup completed successfully!${C_RESET}"
echo -e "    Web Interface: http://localhost:32400/web (or http://<LAN_IP>:32400/web)"
echo -e "    Metadata Dir:  ${PLEX_DATA_DIR}"
echo -e "    Compose File:  ${COMPOSE_DEST}"
