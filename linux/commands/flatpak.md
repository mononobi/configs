# Flatpak Management & Troubleshooting Commands

Commands for repairing Flatpak installations, managing runtimes, and locating application
paths.

---

## Troubleshooting & Repairing Installations

If you encounter errors while installing or updating Flatpak applications:

```bash
# User level repair:
flatpak update --appstream
flatpak repair --user
flatpak repair

# System level repair:
sudo flatpak update --appstream
sudo flatpak repair --user
sudo flatpak repair
```

_After running these commands, restart your terminal._

---

## Package Queries & Cleanup

```bash
# List all installed Flatpak packages and runtimes:
flatpak list

# Search installed packages by name:
flatpak list | grep -i <NAME>

# Example:
flatpak list | grep -i nvidia

# Remove unused Flatpak runtimes to free disk space:
flatpak uninstall --unused
```

---

## Installation & Data Paths

### Application Binaries

- **System-Wide (Installed with `sudo`)**: `/var/lib/flatpak/app`
- **Per-User (Installed without `sudo`)**: `~/.local/share/flatpak/app`

### Application Desktop Shortcuts (`.desktop`)

- **System-Wide**: `/var/lib/flatpak/exports/share/applications`
- **Per-User**: `~/.local/share/flatpak/exports/share/applications`

### Application Sandbox Data

- **User Data & Configurations**: `~/.var/app`
