# `pre-commit`

`pre-commit` is a multi-language package manager for Git pre-commit hooks. It allows developers
to define and manage linters, formatters, and repository checks in a declarative
`.pre-commit-config.yaml` file.

## Installation

### Automated Framework Install

Run the recipe directly (defaults to Python 3.14):

```bash
cd linux/install/apps-recommended/pre-commit && ./install.pre-commit.sh
```

Or specify a custom Python version:

```bash
./install.pre-commit.sh --python 3.12
```

Or invoke via `require_app`:

```bash
require_app "pre-commit"
require_app "pre-commit" --args --python 3.12
```

### Manual Installation (via `uv`)

```bash
uv tool install --python 3.14 pre-commit
```

The tool installs `pre-commit` into an isolated user environment and places the executable in
`~/.local/bin/pre-commit`.

## Getting Started

1. **Install hooks in a repository**:
   ```bash
   pre-commit install
   ```
2. **Run against all files manually**:
   ```bash
   pre-commit run --all-files
   ```
3. **Update hook repositories**:
   ```bash
   pre-commit autoupdate
   ```

## Documentation & References

- Official Website: [https://pre-commit.com/](https://pre-commit.com/)
- Supported Hooks: [https://pre-commit.com/hooks.html](https://pre-commit.com/hooks.html)
