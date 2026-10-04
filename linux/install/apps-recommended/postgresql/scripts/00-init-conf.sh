#!/usr/bin/env bash
# Description: Automatically inject include_dir into postgresql.conf during initialization
set -euo pipefail

CONF_FILE="${PGDATA}/postgresql.conf"
if [[ -f "$CONF_FILE" ]]; then
    if ! grep -q "include_dir = '/etc/postgresql/conf.d'" "$CONF_FILE"; then
        echo "" >> "$CONF_FILE"
        echo "# Custom configuration drops" >> "$CONF_FILE"
        echo "include_dir = '/etc/postgresql/conf.d'" >> "$CONF_FILE"
    fi
fi
