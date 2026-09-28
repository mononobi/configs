#!/bin/bash
# format-markdown.sh

# Resolve the root directory (one level up from this script)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Running Prettier on all Markdown files..."

# We create a temporary directory to install Prettier and its plugins.
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
cd "$TMP_DIR" || exit

npm init -y > /dev/null 2>&1
npm install prettier @prettier/plugin-xml > /dev/null 2>&1

npx prettier --write --ignore-path "$ROOT_DIR/.prettierignore" --plugin=@prettier/plugin-xml \
  "$ROOT_DIR/**/*.md"

# Clean up
rm -rf "$TMP_DIR"
trap - EXIT
cd "$ROOT_DIR" || exit

echo "Formatting complete."
