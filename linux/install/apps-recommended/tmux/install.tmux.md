# tmux Installation and Usage Guide

`tmux` is a tool that lets you run a command in the background and attach to it later for monitoring.

## Installation

```bash
sudo apt install tmux
```

## Basic Usage

### Create a Session

Create a session for a command in the background:

```bash
tmux new-session -d -s "SESSION_NAME" /opt/my_script.sh
```

> **Note:** The script path must be provided as an absolute path, otherwise it won't work.

### Attach to a Session

Attach to an already running command:

```bash
tmux attach-session -t SESSION_NAME
```

### Detach from a Session

When attached to a session, to detach it, press:

`Ctrl + B` and then `D`

### End a Command

To end a command, first attach to it and then press:

`Ctrl + C`

### List Active Sessions

List all active sessions:

```bash
tmux ls
```

### Kill All Active Sessions

Kill all active sessions:

```bash
tmux kill-server
```
