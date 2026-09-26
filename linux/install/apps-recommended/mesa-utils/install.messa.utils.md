# Mesa-utils

`mesa-utils` is a tool to show different graphic card information.

## Installation

```bash
sudo apt-get install mesa-utils
```

## Usage

### Show all information

```bash
glxinfo
```

### Show info about video memory

```bash
glxinfo | grep 'memory'
```
