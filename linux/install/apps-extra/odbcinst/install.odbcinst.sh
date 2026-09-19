#!/usr/bin/env bash
# Description: Install Microsoft SQL Server ODBC Driver & Command-Line Tools
# Note: Configures official Microsoft repository dynamically for the host Ubuntu version; registers drivers automatically.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"

ODBC_VERSION=""
SKIP_UPDATE=false
FORCE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [VERSION]

Description:
  Installs the official Microsoft SQL Server ODBC Driver and command-line tools
  (sqlcmd and bcp). Automatically detects the host Ubuntu version and adds the
  official Microsoft repository using modern GPG keyrings.

Arguments:
  VERSION               Optional driver major version: 18 or 17 (default: 18)

Options:
  -v, --version VER     Specify driver major version: 18 or 17 (default: 18)
  -F, --force           Force reinstallation even if already installed
  --no-update           Skip apt update before installation
  -h, --help            Show this help message and exit

Examples:
  $(basename "$0")              # Installs latest version (v18)
  $(basename "$0") 17           # Installs version 17
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
        -F|--force)
            FORCE=true
            shift
            ;;
        -v|--version)
            ODBC_VERSION="$2"
            shift 2
            ;;
        [0-9]*)
            ODBC_VERSION="$1"
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Use -h or --help for usage information." >&2
            exit 1
            ;;
    esac
done

ODBC_VERSION="${ODBC_VERSION:-18}"
DRIVER_PKG="msodbcsql${ODBC_VERSION}"

if [[ "$ODBC_VERSION" == "17" ]]; then
    TOOLS_PKG="mssql-tools"
    TOOLS_DIR="/opt/mssql-tools/bin"
else
    TOOLS_PKG="mssql-tools${ODBC_VERSION}"
    TOOLS_DIR="/opt/mssql-tools${ODBC_VERSION}/bin"
fi

is_installed "$DRIVER_PKG" --name "Microsoft SQL Server ODBC Driver (v${ODBC_VERSION})" && exit 0

echo "[+] Starting installation for Microsoft SQL Server ODBC Driver v${ODBC_VERSION} & Tools..."

# 1. Install essential prerequisites
require_app curl ca-certificates gnupg lsb-release

# 2. Detect host OS version and codename
UBUNTU_VER=$(lsb_release -rs)
UBUNTU_CODENAME=$(lsb_release -cs)

echo "[+] Detected Ubuntu version: ${UBUNTU_VER} (${UBUNTU_CODENAME})"

# 3. Add Microsoft GPG Keyring
sudo install -m 0755 -d /usr/share/keyrings
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-prod.gpg > /dev/null
sudo chmod 644 /usr/share/keyrings/microsoft-prod.gpg

# 4. Add official Microsoft repository for this Ubuntu version
echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/ubuntu/${UBUNTU_VER}/prod ${UBUNTU_CODENAME} main" | sudo tee /etc/apt/sources.list.d/mssql-release.list > /dev/null

sudo apt-get update

# 5. Install Microsoft SQL Server ODBC driver and tools (auto-accepting EULA)
echo "[+] Installing ${DRIVER_PKG} and unixodbc-dev..."
sudo ACCEPT_EULA=Y apt-get install -y "$DRIVER_PKG" unixodbc-dev

echo "[+] Installing Microsoft SQL Server command-line tools (${TOOLS_PKG})..."
sudo ACCEPT_EULA=Y apt-get install -y "$TOOLS_PKG"

# 6. Add mssql-tools to PATH in ~/.bashrc and current shell
if [[ -d "$TOOLS_DIR" ]]; then
    if ! grep -qs "$TOOLS_DIR" "$HOME/.bashrc"; then
        echo "export PATH=\"\$PATH:${TOOLS_DIR}\"" >> "$HOME/.bashrc"
        echo "[+] Added $TOOLS_DIR to PATH in ~/.bashrc"
    fi
    export PATH="$PATH:$TOOLS_DIR"
fi

# 7. Verification
if is_installed --check "odbcinst"; then
    echo "[+] ODBC Environment and Registered Drivers:"
    odbcinst -j
    echo "[+] Registered Drivers in /etc/odbcinst.ini:"
    odbcinst -q -d || true
fi

echo "[✓] Microsoft SQL Server ODBC Driver v${ODBC_VERSION} and Tools setup completed successfully!"
