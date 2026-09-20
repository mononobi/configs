#!/usr/bin/env bash
# Description: Install and configure pandoc
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../utils.sh"
SKIP_UPDATE=\"${SKIP_UPDATE:-false}\"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Pandoc universal document converter and recommended LaTeX packages via APT.

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

is_installed "pandoc" --name "Pandoc" && exit 0

echo "[+] Starting installation/setup for pandoc..."

conditional_apt_update
sudo apt-get install -y pandoc texlive-latex-base texlive-fonts-recommended texlive-latex-recommended texlive-latex-extra

echo "[✓] pandoc setup completed successfully!"
