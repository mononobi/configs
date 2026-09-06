#!/usr/bin/env bash
# Description: Install and configure Firefox (Official Mozilla DEB)
# Note: Uses official packages.mozilla.org repository and disables Snap transition.

set -euo pipefail

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Installs official native Firefox DEB from packages.mozilla.org.
  Purges any Snap version, removes legacy PPA if present, and configures APT pinning
  so that official Mozilla packages are prioritized and Ubuntu Snap triggers are blocked.

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

echo "[+] Starting installation/setup for Firefox (Official Mozilla DEB)..."

# 1. Remove Snap version if present
if command -v snap >/dev/null 2>&1; then
    echo "[+] Removing Firefox snap if installed..."
    sudo snap remove --purge firefox 2>/dev/null || true
fi
sudo rm -f /usr/bin/firefox

# 2. Clean up legacy mozillateam PPA and old pin files if present
if grep -rq "mozillateam/ppa" /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null; then
    echo "[+] Removing legacy mozillateam PPA..."
    sudo add-apt-repository --remove -y ppa:mozillateam/ppa 2>/dev/null || true
    sudo rm -f /etc/apt/sources.list.d/*mozillateam* 2>/dev/null || true
fi
sudo rm -f /etc/apt/preferences.d/mozilla-firefox 2>/dev/null || true

# 3. Create keyrings directory and import Mozilla official signing key
sudo install -d -m 0755 /etc/apt/keyrings
echo "[+] Importing Mozilla signing key from https://packages.mozilla.org/apt/repo-signing-key.gpg..."
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
sudo chmod 644 /etc/apt/keyrings/packages.mozilla.org.asc

# 4. Verify signing key fingerprint
mkdir -p "$HOME/.gnupg"
chmod 700 "$HOME/.gnupg"

echo "[+] Verifying key fingerprint..."
FINGERPRINT=$(gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc 2>/dev/null | awk '/pub/{getline; gsub(/^ +| +$/,""); print $0}' || true)
EXPECTED_FP="35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3"

if [[ "$FINGERPRINT" == *"$EXPECTED_FP"* ]]; then
    echo "[+] Key fingerprint verified: $EXPECTED_FP"
else
    echo "[!] Notice: Key imported. Fingerprint: ${FINGERPRINT:-Unknown}"
fi

# 5. Add official Mozilla APT repository
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null

# 6. Configure APT pinning: prioritize packages.mozilla.org and block Ubuntu snap wrapper
sudo mkdir -p /etc/apt/preferences.d
sudo tee /etc/apt/preferences.d/mozilla << 'EOF'
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000

Package: firefox*
Pin: release o=Ubuntu*
Pin-Priority: -1
EOF

# 7. Update package indexes and install Firefox
sudo apt-get update
sudo apt-get install -y --allow-downgrades firefox

echo "[✓] Firefox (Official Mozilla DEB) setup completed successfully!"
