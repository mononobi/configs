#!/usr/bin/env bash
# Description: Install and configure Microsoft .NET SDK & Runtimes
# Note: Uses official Ubuntu/Canonical ppa:dotnet/backports per modern Microsoft & Ubuntu guidance.

set -euo pipefail

DOTNET_VER=""
INSTALL_MAUI=true

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [VERSION]

Description:
  Installs Microsoft .NET SDK, ASP.NET Core Runtime, and .NET Runtime using the official
  Canonical .NET Backports PPA (ppa:dotnet/backports) as specified in the guideline.
  Automatically detects and installs the latest stable version if no version is provided,
  or installs the specific version requested (e.g. 9.0, 10.0, 8.0).
  Configures HTTPS development certificates and the maui-android workload.

Arguments:
  VERSION               Specific .NET version (e.g. 9.0, 9, 10.0, 8.0). Default: auto-detects latest

Options:
  -v, --version VER     Specify .NET version to install
  --no-workload         Skip installing the maui-android workload
  --no-update           Skip apt update before installation
  -h, --help            Show this help message and exit

Examples:
  $(basename "$0")              # Auto-detects and installs the latest stable .NET SDK
  $(basename "$0") 9.0          # Installs .NET 9.0 SDK & runtimes
  $(basename "$0") -v 10.0      # Installs .NET 10.0 SDK & runtimes
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
        -v|--version)
            DOTNET_VER="$2"
            shift 2
            ;;
        --no-workload)
            INSTALL_MAUI=false
            shift
            ;;
        [0-9]*)
            DOTNET_VER="$1"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

echo "[+] Starting installation/setup for .NET SDK & Runtimes..."

# 1. Update system and add ppa:dotnet/backports (official Canonical / Microsoft supported feed)
if [[ "$SKIP_UPDATE" != "true" ]]; then
    sudo apt-get update
fi
sudo apt-get install -y software-properties-common ca-certificates curl

echo "[+] Adding official Canonical .NET Backports PPA..."
sudo add-apt-repository -y ppa:dotnet/backports
sudo apt-get update

# 2. Determine target .NET version
if [[ -z "$DOTNET_VER" ]]; then
    echo "[+] Auto-detecting latest stable .NET version in repository..."
    DETECTED_VER=$(apt-cache search "^dotnet-sdk-[0-9]+\.[0-9]+$" 2>/dev/null | awk "{print \$1}" | grep -Po "[0-9]+\.[0-9]+" | sort -V | tail -1 || true)
    DOTNET_VER="${DETECTED_VER:-9.0}"
fi

# Normalize "9" -> "9.0", "10" -> "10.0"
if [[ "$DOTNET_VER" =~ ^[0-9]+$ ]]; then
    DOTNET_VER="${DOTNET_VER}.0"
fi

echo "[+] Target .NET Version: $DOTNET_VER"

# 3. Install SDK and runtimes
echo "[+] Installing dotnet-sdk-${DOTNET_VER}, aspnetcore-runtime-${DOTNET_VER}, and dotnet-runtime-${DOTNET_VER}..."
sudo apt-get install -y "dotnet-sdk-${DOTNET_VER}" "aspnetcore-runtime-${DOTNET_VER}" "dotnet-runtime-${DOTNET_VER}"

# 4. Configure HTTPS development certificates
echo "[+] Configuring HTTPS development certificates..."
dotnet dev-certs https --trust 2>/dev/null || sudo dotnet dev-certs https --trust 2>/dev/null || true

# 5. Install MAUI Android workload if requested
if [[ "$INSTALL_MAUI" == "true" ]]; then
    echo "[+] Installing maui-android workload..."
    sudo dotnet workload install maui-android || true
fi

# 6. Verification
echo "[+] Verification:"
dotnet --info || true

echo "[✓] .NET ${DOTNET_VER} setup completed successfully!"
