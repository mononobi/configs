# Operating System & Kernel Information

CLI commands to inspect the installed distribution, version, and running Linux kernel.

## Kernel Version

Inspect the active Linux kernel release and system architecture:

```bash
# Short release string (e.g., 6.8.0-45-generic)
uname -r

# Full system identification
uname -a
```

## OS Distribution & Release Information

View detailed release metadata using any of the following commands:

```bash
# Standard release identification files
cat /etc/*-release

# LSB (Linux Standard Base) release information
lsb_release -a

# System hostname and systemd architecture overview
hostnamectl

# Kernel build version and compiler information
cat /proc/version
```
