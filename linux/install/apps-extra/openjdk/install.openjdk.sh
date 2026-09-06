#!/usr/bin/env bash
# Description: Install and configure openjdk
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

JDK_VER=""

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [VERSION]

Description:
  Installs OpenJDK Java Development Kit via official OpenJDK PPA (ppa:openjdk-r/ppa).
  Defaults to default-jdk if no version is specified, or installs openjdk-<VERSION>-jdk.

Arguments:
  VERSION               Specific JDK major version (e.g. 21, 17, 14)

Options:
  -v, --version VER     Specify JDK version
  -h, --help            Show this help message and exit

Examples:
  $(basename "$0")              # Installs default-jdk
  $(basename "$0") 21           # Installs openjdk-21-jdk
  $(basename "$0") -v 17        # Installs openjdk-17-jdk
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
            JDK_VER="$2"
            shift 2
            ;;
        [0-9]*)
            JDK_VER="$1"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

echo "[+] Starting installation/setup for openjdk..."

sudo apt-get update
sudo apt-get install -y software-properties-common ca-certificates

echo "[+] Adding OpenJDK PPA..."
sudo add-apt-repository -y ppa:openjdk-r/ppa
sudo apt-get update

if [[ -n "$JDK_VER" ]]; then
    PKG="openjdk-${JDK_VER}-jdk"
else
    PKG="default-jdk"
fi

echo "[+] Installing $PKG..."
sudo apt-get install -y "$PKG"
java -version

echo "[✓] openjdk setup completed successfully!"
