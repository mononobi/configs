# Pandoc

Pandoc is a tool to export `Markdown` files (.md) to PDF or HTML.

## Installation

```bash
sudo apt update
sudo apt install pandoc
sudo apt install texlive-latex-base texlive-fonts-recommended texlive-latex-recommended texlive-latex-extra
```

## Usage

### PDF

```bash
pandoc input.md -o output.pdf
```

### HTML

```bash
pandoc input.md -s -o output.html
```

> Note: The `-s` flag creates a standalone HTML file with proper headers.
