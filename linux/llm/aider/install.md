# Aider

Aider is an open source AI coding agent that can connect to various AI models, specifically
local models.

## Installation

Install `pipx` and ensure its binaries are added to the system path, then install `Aider` itself.

```bash
sudo apt update && sudo apt install pipx -y
pipx ensurepath
pipx install aider-chat
```

> Note: If `ensurepath` tells it added directories to the PATH, completely close the
> terminal window and open a new one so the changes take effect.

## Configurations

Copy the `aider.conf.yml` file and then set your default model and modify other values if needed.

```bash
cp aider.conf.yml ~/.aider.conf.yml
```

> Note: This file is a global configuration file. If you want to use different configurations
> for different projects, create separate files in the project directory
> (It can also be pushed to the Git repo).

## Running

To run `Aider`, execute this command inside a project folder (Not home directory).

```bash
aider
```

## Updating

Run this command to upgrade the `Aider`:

```bash
aider --upgrade
```

## Commands:

When `Aider` is active, type `/` and you will see all the available commands.

> For file names, you can use relative file names to project root, it also supports
> wild-card names.

> Note: Aider creates a repo map of the entire project and its files, so it always has the
> context awareness of the entire project. only add files/folders as context when you want
> to give special focus on a given file.
