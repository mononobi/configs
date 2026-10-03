# RAM Information Commands

CLI commands to inspect physical RAM hardware specifications and real-time memory utilization.

## Physical Memory Hardware

Inspect installed physical memory modules, speeds, capacities, types, and slot form factors:

```bash
sudo dmidecode --type 17
```

## Memory Usage

View real-time physical memory and swap consumption in human-readable format:

```bash
free -h
```
