# CPU Information & Frequency Commands

CLI commands to inspect CPU architecture, core counts, and real-time clock frequencies.

## System-Wide CPU Architecture

Display full processor specifications, flags, virtualization capabilities, and cache
sizes:

```bash
lscpu
```

Filter specifically for current operating clock frequencies:

```bash
lscpu | grep "MHz"
```

## Per-Core / Per-Thread Inspection

Inspect detailed kernel hardware descriptors for every individual logical core:

```bash
cat /proc/cpuinfo
```

Filter for real-time operating frequencies across all logical cores:

```bash
cat /proc/cpuinfo | grep "MHz"
```
