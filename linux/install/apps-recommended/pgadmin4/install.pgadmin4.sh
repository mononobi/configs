#!/usr/bin/env bash
# Description: Install and configure pgAdmin 4
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs pgAdmin 4 (desktop and web modes) using the official pgAdmin APT repository.

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

echo "[+] Starting installation/setup for pgAdmin 4..."

if [[ "$SKIP_UPDATE" != "true" ]]; then
    sudo apt-get update
fi
sudo apt-get install -y curl ca-certificates gnupg lsb-release

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/packages-pgadmin-org.gpg > /dev/null
sudo chmod 644 /etc/apt/keyrings/packages-pgadmin-org.gpg

CODENAME=$(lsb_release -cs)
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/${CODENAME} pgadmin4 main" | sudo tee /etc/apt/sources.list.d/pgadmin4.list

sudo apt-get update
sudo apt-get install -y pgadmin4

# After installation, stop and disable apache2 server installed with pgadmin web mode
if systemctl is-active --quiet apache2 2>/dev/null || systemctl is-enabled --quiet apache2 2>/dev/null; then
    echo "[+] Stopping and disabling apache2..."
    sudo systemctl stop apache2 || true
    sudo systemctl disable apache2 || true
fi

echo "[✓] pgAdmin 4 setup completed successfully!"
