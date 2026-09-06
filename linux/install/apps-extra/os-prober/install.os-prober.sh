#!/usr/bin/env bash
# Description: Install and configure os-prober
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs and enables os-prober in GRUB to detect other operating systems (dual-boot).

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

echo "[+] Starting installation/setup for os-prober..."

sudo apt-get update
sudo apt-get install -y os-prober

# Enable GRUB_DISABLE_OS_PROBER=false in /etc/default/grub if disabled
if grep -q "GRUB_DISABLE_OS_PROBER" /etc/default/grub; then
    sudo sed -i 's/^.*GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
else
    echo 'GRUB_DISABLE_OS_PROBER=false' | sudo tee -a /etc/default/grub
fi

sudo os-prober
sudo update-grub

echo "[✓] os-prober setup completed successfully!"
