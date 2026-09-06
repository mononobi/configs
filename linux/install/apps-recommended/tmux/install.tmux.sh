#!/usr/bin/env bash
# Description: Install and configure tmux
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs tmux terminal multiplexer and configures sensible default settings (~/.tmux.conf).

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

echo "[+] Starting installation/setup for tmux..."

sudo apt-get update
sudo apt-get install -y tmux

# Configure ~/.tmux.conf if not already created
if [[ ! -f "$HOME/.tmux.conf" ]]; then
    cat << 'EOF' > "$HOME/.tmux.conf"
# Enable mouse mode (tmux 2.1 and above)
set -g mouse on
# Set default history limit
set -g history-limit 10000
# Enable 256 colors
set -g default-terminal "screen-256color"
EOF
    echo "[+] Created default ~/.tmux.conf"
fi

echo "[✓] tmux setup completed successfully!"
