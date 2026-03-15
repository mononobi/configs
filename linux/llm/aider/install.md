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
> standard terminal wildcards.

## Useful Commands:

- **/add <filename>**: Adds a specific file to the chat. (e.g., /add app.py)

- **/add <folder>/**: Adds all supported files within a specific directory.

- **/add *.py**: You can use standard terminal wildcards to add multiple files of a specific type.

- **/read-only <filename>**: Adds a file as read-only. (e.g., /read-only instructions.md)

- **/read-only <folder>/**: Adds a whole directory as read-only context.

- **/drop <filename>**: Removes a specific file from the active chat memory. (e.g., /drop app.py)

- **/drop <folder>/**: Removes all previously added files from that specific folder.

- **/reset**: Drops all files (both added and read) and completely wipes the chat history.

- **/undo**: Instantly performs a git reset --hard to roll back your files exactly
  to how they were before the model's last response.

- **/diff**: If you want to see exactly what lines Aider just changed before you decide to
  undo, type this to see a standard terminal Git diff.

> Multiline mode is enabled by default. `Enter` adds a new line. To submit the prompt
> use `Alt + Enter`.
