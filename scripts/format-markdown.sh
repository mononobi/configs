#!/bin/bash
# format-markdown.sh

# Resolve the root directory (one level up from this script)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

normalize_alerts() {
  node -e '
const fs = require("fs");
const path = require("path");

const root = process.argv[1];

function walk(dir) {
  let files = [];
  for (const item of fs.readdirSync(dir)) {
    if (item === ".git" || item === ".idea" || item === "node_modules") continue;
    const fullPath = path.join(dir, item);
    const stat = fs.statSync(fullPath);
    if (stat.isDirectory()) {
      files = files.concat(walk(fullPath));
    } else if (item.endsWith(".md") && item !== "AGENTS.md") {
      files.push(fullPath);
    }
  }
  return files;
}

function processContent(content) {
  const lines = content.split("\n");
  let inCode = false;
  const out = [];

  for (let line of lines) {
    if (/^```/.test(line.trim())) {
      inCode = !inCode;
      out.push(line);
      continue;
    }

    if (!inCode) {
      // 1. Split alert tag if followed by text on same line
      const splitMatch = line.match(/^([ \t]*>[ \t]*)(\[!(?:NOTE|TIP|IMPORTANT|WARNING|CAUTION)\])[ \t]+(.*)$/);
      if (splitMatch) {
        out.push(`${splitMatch[1]}${splitMatch[2]}  `);
        out.push(`${splitMatch[1]}${splitMatch[3]}`);
        continue;
      }

      // 2. Ensure standalone alert tag ends with two trailing spaces (Markdown hard line break so Prettier preserves newline)
      const aloneMatch = line.match(/^([ \t]*>[ \t]*)(\[!(?:NOTE|TIP|IMPORTANT|WARNING|CAUTION)\])[ \t]*$/);
      if (aloneMatch) {
        out.push(`${aloneMatch[1]}${aloneMatch[2]}  `);
        continue;
      }
    }

    out.push(line);
  }

  return out.join("\n");
}

const files = walk(root);
for (const file of files) {
  const content = fs.readFileSync(file, "utf8");
  const updated = processContent(content);
  if (updated !== content) {
    fs.writeFileSync(file, updated);
  }
}
' "$ROOT_DIR"
}

echo "Preparing Markdown alert callouts..."
normalize_alerts

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

# Run safety pass after Prettier
normalize_alerts

echo "Formatting complete."
