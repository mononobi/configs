# Flatpak Management & Troubleshooting Commands

Commands for repairing Flatpak installations, managing runtimes, and locating application
paths.

---

## Troubleshooting & Repairing Installations

If you encounter errors while installing or updating Flatpak applications:

```bash
# User level repair (for apps installed with --user):
flatpak update --appstream --user
flatpak repair --user

# System level repair (for system-wide apps):
sudo flatpak update --appstream --system
sudo flatpak repair
```

_After running these commands, restart your terminal._

---

## Package Queries & Cleanup

```bash
# List all installed Flatpak packages and runtimes:
flatpak list

# List user-installed Flatpaks only:
flatpak list --user

# Search installed packages by name:
flatpak list | grep -i <NAME>

# Example:
flatpak list | grep -i nvidia

# Update installed Flatpak apps (no sudo needed for user-installed apps):
flatpak update -y

# Remove unused Flatpak runtimes to free disk space:
flatpak uninstall --unused -y
```

---

## Installation & Data Paths

### Application Binaries & Runtimes

- **Per-User (Installed with `--user`)**: `~/.local/share/flatpak/app` and
  `~/.local/share/flatpak/runtime`
- **System-Wide (Installed without `--user`)**: `/var/lib/flatpak/app` and
  `/var/lib/flatpak/runtime`

### Application Desktop Shortcuts (`.desktop`)

- **Per-User**: `~/.local/share/flatpak/exports/share/applications`
- **System-Wide**: `/var/lib/flatpak/exports/share/applications`

### Application Sandbox Data

- **User Data, Cache & Configurations**: `~/.var/app/<application-id>` (always per-user)
