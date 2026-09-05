#!/usr/bin/env bash
# Description: Install and configure .NET Core
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs .NET Core runtime and SDK dependencies.

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

echo "[+] Starting installation/setup for .NET Core..."

sudo apt-get update
sudo apt-get install -y libc6 libgcc1 libgssapi-krb5-2 libicu74 || sudo apt-get install -y libicu-dev || true
sudo apt-get install -y dotnet-runtime-6.0 dotnet-sdk-6.0 || sudo apt-get install -y dotnet-sdk-8.0 || true
dotnet --list-runtimes || true

echo "[✓] .NET Core setup completed successfully!"
