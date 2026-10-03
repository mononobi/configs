# APT Package Manager Maintenance Commands

Essential commands for repairing broken package states, listing installed packages, and
switching repository mirrors.

---

## Repair & Query

### Fix Interrupted Package Installations

Resolve lock and post-installation state errors caused by interrupted updates:

```bash
sudo dpkg --configure -a
```

### List Installed Packages

Display all packages currently installed via APT:

```bash
sudo apt list --installed
```

---

## Switching Repository Mirrors (Regional to Main)

Switching from localized regional mirrors (e.g., `us.archive.ubuntu.com`) to canonical mirrors
(`archive.ubuntu.com`) resolves localized mirror outages and sync lag.

1. Open `/etc/apt/sources.list` (or files in `/etc/apt/sources.list.d/` on modern Ubuntu
   releases):

   ```bash
   sudo nano /etc/apt/sources.list
   ```

2. Replace regional prefixes from repository URLs:
   - **Original**: `http://us.archive.ubuntu.com/ubuntu`
   - **Updated**: `http://archive.ubuntu.com/ubuntu`

3. Refresh package metadata cache:
   ```bash
   sudo apt-get update
   ```
