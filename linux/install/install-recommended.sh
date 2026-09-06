#!/usr/bin/env bash
# Description: Install all recommended applications

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/install-apps.sh" "apps-recommended" "$@"
