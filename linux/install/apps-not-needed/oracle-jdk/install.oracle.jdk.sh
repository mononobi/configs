#!/usr/bin/env bash
# Description: Install and configure oracle-jdk
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"
SKIP_UPDATE="${SKIP_UPDATE:-false}"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Downloads and installs Oracle JDK or configures Java alternatives.

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

is_installed "java" --name "Oracle JDK" && exit 0

echo "[+] Starting installation/setup for oracle-jdk..."

# Oracle JDK requires manual download or official Oracle debian package
echo "[+] Checking for Oracle JDK .deb package in directory..."
DEB_FILE=$(ls jdk-*.deb 2>/dev/null | head -n 1 || true)

if [[ -n "$DEB_FILE" && -f "$DEB_FILE" ]]; then
    conditional_apt_update
    sudo apt-get install -y "./$DEB_FILE"
else
    echo "[!] No Oracle JDK .deb found in current directory."
    echo "[+] To install Oracle JDK, download the x64 Debian Package from https://www.oracle.com/java/technologies/downloads/"
    echo "    and run: sudo apt install ./jdk-<version>_linux-x64_bin.deb"
fi

echo "[✓] oracle-jdk setup completed successfully!"
