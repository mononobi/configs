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
has_candidate() {
    local candidate
    candidate=$(apt-cache policy "$1" 2>/dev/null | awk '/Candidate:/ {print $2}')
    [[ -n "$candidate" && "$candidate" != "(none)" ]]
}

# Select concrete QEMU KVM package (in Ubuntu 24.04+, qemu-kvm is a virtual package provided by qemu-system-x86)
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)          QEMU_PKG="qemu-system-x86" ;;
    aarch64|arm64)   QEMU_PKG="qemu-system-arm" ;;
    *)               QEMU_PKG="qemu-system-x86" ;;
esac

if ! has_candidate "$QEMU_PKG"; then
    if has_candidate "qemu-kvm"; then
        QEMU_PKG="qemu-kvm"
    elif has_candidate "qemu-system"; then
        QEMU_PKG="qemu-system"
    fi
fi

sudo apt-get install -y virt-manager "$QEMU_PKG" libvirt-daemon-system libvirt-clients bridge-utils ovmf spice-vdagent qemu-guest-agent
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt "$USER"
sudo usermod -aG kvm "$USER"
echo "[+] Virtualization packages installed. User $USER added to libvirt and kvm groups (re-login required)."

echo "[✓] virt-manager setup completed successfully!"
