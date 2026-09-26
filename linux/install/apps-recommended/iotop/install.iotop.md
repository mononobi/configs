# Install and Use iotop

`iotop` is a command-line application used for monitoring disk I/O usage by processes.

## Installation

Depending on your Linux distribution, choose the appropriate command to install `iotop`:

### Debian/Ubuntu-based Systems

```bash
sudo apt-get install iotop
```

### Arch-based Systems

```bash
sudo pacman -S iotop
```

## Usage

To monitor I/O access (showing only processes or threads actually doing I/O), run:

```bash
sudo iotop -o
```
