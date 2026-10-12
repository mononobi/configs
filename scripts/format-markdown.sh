#!/usr/bin/env bash
# format-markdown.sh
# Formats Markdown files using Prettier and the XML plugin.

set -euo pipefail

# Resolve the root directory (one level up from this script)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [FILES...]

Description:
  Formats Markdown (.md) files using Prettier and the XML plugin according
  to repository formatting rules.

Arguments:
  [FILES...]   One or more Markdown (.md) files to format. Non-.md files are ignored.
               If no files are provided, all Markdown files across the repository
               are formatted.

Options:
  -h, --help   Show this help message and exit
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_help
    exit 0
fi

TARGET_FILES=()

if [[ $# -gt 0 ]]; then
    for file in "$@"; do
        # Only process .md files
        if [[ "$file" == *.md ]]; then
            if [[ -L "$file" ]]; then
                echo "Skipping symbolic link: $file" >&2
                continue
            fi
            if [[ -f "$file" ]]; then
                TARGET_FILES+=("$(realpath -s "$file")")
            else
                echo "Warning: File not found, skipping: $file" >&2
            fi
        fi
    done

    if [[ ${#TARGET_FILES[@]} -eq 0 ]]; then
        echo "No valid Markdown (.md) files provided to format."
        exit 0
    fi

    echo "Running Prettier on specified Markdown file(s)..."
else
    TARGET_FILES=("$ROOT_DIR/**/*.md")
    echo "Running Prettier on all Markdown files..."
fi

# We create a temporary directory to install Prettier and its plugins.
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
cd "$TMP_DIR" || exit

npm init -y > /dev/null 2>&1
npm install prettier @prettier/plugin-xml > /dev/null 2>&1

npx prettier --write --ignore-path "$ROOT_DIR/.prettierignore" --plugin=@prettier/plugin-xml \
  "${TARGET_FILES[@]}"

# Clean up
rm -rf "$TMP_DIR"
trap - EXIT
cd "$ROOT_DIR" || exit

echo "Formatting complete."
