# Poetry Installation Guide

Poetry is a Python package and dependency manager. It serves as an alternative to tools like
Pipenv.

## Prerequisites

> **Important:** You must install the required dependencies first; otherwise, the Poetry
> installation will fail.

```bash
sudo apt-get install python3-venv
```

## Installation

Run the following command to install Poetry:

```bash
curl -sSL https://install.python-poetry.org | python3 -
```

## Updating Poetry

To update Poetry itself to the latest version, run:

```bash
poetry self update
```

## Verification

Check the installed version to ensure the installation was successful:

```bash
poetry --version
```

## Uninstallation

If you need to uninstall Poetry, use the following command:

```bash
curl -sSL https://install.python-poetry.org | python3 - --uninstall
```

## Additional Information

- **Default Executable Path:** `~/.local/bin/poetry`

### Adding Dependencies

To add dependencies via the command line, execute the following command while inside an active
virtual environment:

```bash
poetry add DEPENDENCY_NAME
```

**Example:**

```bash
poetry add Pillow
```
