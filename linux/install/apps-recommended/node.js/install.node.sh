#!/usr/bin/env bash
# Description: Install and configure Node.js, NPM & Yarn
# Note: Modernized for Ubuntu with best practices.

set -euo pipefail

NODE_MAJOR=""

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [VERSION]

Description:
  Automatically queries and installs the latest stable LTS release of Node.js via
  the official NodeSource repository, updates npm, and installs Yarn and serve.

Arguments:
  VERSION               Optional specific major version (default: auto-detects latest LTS, e.g. 24)

Options:
  -v, --version VER     Specify a custom Node.js major version (e.g. 24, 22, 20)
  -h, --help            Show this help message and exit

Examples:
  $(basename "$0")              # Auto-detects and installs the latest stable LTS version
  $(basename "$0") 22           # Installs Node.js v22
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            NODE_MAJOR="$2"
            shift 2
            ;;
        [0-9]*)
            NODE_MAJOR="$1"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

echo "[+] Starting installation/setup for Node.js, NPM & Yarn..."

# Auto-detect latest stable LTS if not manually specified
if [[ -z "$NODE_MAJOR" ]]; then
    echo "[+] Auto-detecting latest stable Node.js LTS version..."
    DETECTED_LTS=$(python3 -c '
import json, urllib.request
try:
    with urllib.request.urlopen("https://nodejs.org/dist/index.json", timeout=5) as r:
        data = json.loads(r.read().decode())
        for rel in data:
            if rel.get("lts"):
                print(rel["version"].lstrip("v").split(".")[0])
                break
except Exception:
    pass
' 2>/dev/null || true)

    if [[ -z "$DETECTED_LTS" ]]; then
        DETECTED_LTS=$(curl -fsSL https://nodejs.org/download/release/index.tab 2>/dev/null | awk -F'\t' '$10 != "-" && $10 != "lts" {gsub(/^v|\..*$/, "", $1); print $1; exit}' || true)
    fi

    NODE_MAJOR="${DETECTED_LTS:-24}"
    echo "[+] Latest stable LTS version detected: Node.js v${NODE_MAJOR}.x"
fi

sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# 1. Install NodeSource repository
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/nodesource.gpg > /dev/null
sudo chmod 644 /etc/apt/keyrings/nodesource.gpg

echo "[+] Setting up NodeSource repository for Node.js v${NODE_MAJOR}.x..."
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

sudo apt-get update
sudo apt-get install -y nodejs build-essential

# 2. Install Yarn repository
curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/yarn.gpg > /dev/null
sudo chmod 644 /etc/apt/keyrings/yarn.gpg
echo "deb [signed-by=/etc/apt/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

sudo apt-get update
sudo apt-get install -y yarn

# 3. Install global utilities (serve)
sudo npm install -g serve || true

node -v
npm -v
yarn -v

echo "[✓] Node.js, NPM & Yarn setup completed successfully!"
