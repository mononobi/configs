#!/usr/bin/env bash
# Description: Install and configure virt-manager
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

SKIP_UPDATE=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs Virt-Manager, QEMU/KVM virtualization stack, and adds current user to libvirt/kvm groups.

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

echo "[+] Starting installation/setup for virt-manager..."

if [[ "$SKIP_UPDATE" != "true" ]]; then
    sudo apt-get update
fi
sudo apt-get install -y virt-manager qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils ovmf spice-vdagent
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt "$USER"
sudo usermod -aG kvm "$USER"
echo "[+] Virtualization packages installed. User $USER added to libvirt and kvm groups (re-login required)."

echo "[✓] virt-manager setup completed successfully!"
