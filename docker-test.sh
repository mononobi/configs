#!/usr/bin/env bash
# Description: Build the Ubuntu 26.04 test image and start an interactive test session in isolation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[+] Building and launching Ubuntu 26.04 test container..."

if [[ $# -gt 0 ]]; then
    exec docker compose run --rm --build test-env "$@"
else
    exec docker compose run --rm --build test-env /bin/bash
fi
