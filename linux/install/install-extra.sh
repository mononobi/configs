#!/usr/bin/env bash
# Description: Install all extra applications

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/installer.sh" "apps-extra" "$@"
