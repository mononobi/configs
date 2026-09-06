#!/usr/bin/env bash
# Description: Install Microsoft SQL Server ODBC Driver & Command-Line Tools
# Note: Configures official Microsoft repository dynamically for the host Ubuntu version; registers drivers automatically.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs the official Microsoft SQL Server ODBC Driver (msodbcsql18) and SQL Server
  command-line tools (mssql-tools18 including sqlcmd and bcp).
  Automatically detects the host Ubuntu version, adds the official Microsoft repository
  using modern GPG keyrings, and updates PATH in ~/.bashrc.

Options:
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
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

echo "[+] Starting installation for Microsoft SQL Server ODBC Driver & Tools..."

# 1. Update system and install essential prerequisites
sudo apt-get update
sudo apt-get install -y curl ca-certificates gnupg lsb-release

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
echo "[+] Installing Microsoft SQL Server ODBC Driver and unixodbc-dev..."
sudo ACCEPT_EULA=Y apt-get install -y msodbcsql18 || sudo ACCEPT_EULA=Y apt-get install -y msodbcsql17

echo "[+] Installing Microsoft SQL Server command-line tools (sqlcmd, bcp)..."
sudo ACCEPT_EULA=Y apt-get install -y mssql-tools18 || sudo ACCEPT_EULA=Y apt-get install -y mssql-tools || true
sudo apt-get install -y unixodbc-dev

# 6. Add mssql-tools to PATH in ~/.bashrc and current shell
for tools_dir in /opt/mssql-tools18/bin /opt/mssql-tools/bin; do
    if [[ -d "$tools_dir" ]]; then
        if ! grep -qs "$tools_dir" "$HOME/.bashrc"; then
            echo "export PATH=\"\$PATH:${tools_dir}\"" >> "$HOME/.bashrc"
            echo "[+] Added $tools_dir to PATH in ~/.bashrc"
        fi
        export PATH="$PATH:$tools_dir"
    fi
done

# 7. Verification
echo "[+] ODBC Environment and Registered Drivers:"
odbcinst -j
echo "[+] Registered Drivers in /etc/odbcinst.ini:"
odbcinst -q -d || true

echo "[✓] Microsoft SQL Server ODBC Driver and Tools setup completed successfully!"
