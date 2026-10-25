# Flatpak Installation Guide

## Installation on Ubuntu 18.04 or Above

```bash
sudo apt install flatpak
```

## Installation on Older Ubuntu Systems

```bash
sudo add-apt-repository ppa:flatpak/stable
sudo apt update
sudo apt install flatpak
```

## Post-Installation Steps (All Systems)

Execute the following commands to add the Flathub repository and ensure user installation
integrity and desktop launcher exports:

```bash
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak repair --user
```

---

## Per-User (`--user`) vs. System-Wide Installation

All Flatpak application installations across this repository are configured to use the `--user`
flag. Understanding the differences between per-user and system-wide installations:

### Key Differences

- **Privilege & Authentication Requirements**:
  - **Per-User (`--user`)**: Installs completely inside the user's home directory. Does **not**
    require `sudo` or Polkit / `systemd-logind` authentication. Runs reliably in headless
    sessions, SSH environments, CI/CD pipelines, and Docker containers.
  - **System-Wide (Default without `--user`)**: Installs to `/var/lib/flatpak`. Requires
    administrative privileges via Polkit system helpers (`systemd-logind` seat authentication)
    or `sudo`.
- **Surviving OS Reinstallation**:
  - If your `/home` partition or directory is kept intact during an OS reinstall, all
    applications, runtimes, and local data installed via `--user` **survive intact**.
  - After reinstalling the base `flatpak` package on the new OS, all your user-installed apps
    and runtimes are immediately recognized and runnable without needing to re-download or
    reinstall them.
- **Maintenance & Updates (No `sudo` Required)**:
  - When managing per-user Flatpaks, **never use `sudo`**.
  - Commands such as `flatpak update -y`, `flatpak uninstall --unused -y`, and
    `flatpak override --user ...` must be executed as your regular user.
  - Running Flatpak commands with `sudo` against user installations creates root-owned files
    inside your home directory and breaks permissions.

### Filesystem Paths Comparison

| Component                                     | Per-User (`--user`)                                  | System-Wide (Default)                          |
| :-------------------------------------------- | :--------------------------------------------------- | :--------------------------------------------- |
| **App Binaries & Metadata**                   | `~/.local/share/flatpak/app/`                        | `/var/lib/flatpak/app/`                        |
| **Shared Runtimes (GNOME, KDE, Freedesktop)** | `~/.local/share/flatpak/runtime/`                    | `/var/lib/flatpak/runtime/`                    |
| **Repository Configuration**                  | `~/.local/share/flatpak/repo/config`                 | `/var/lib/flatpak/repo/config`                 |
| **Desktop Launchers (`.desktop`)**            | `~/.local/share/flatpak/exports/share/applications/` | `/var/lib/flatpak/exports/share/applications/` |
| **Application Data & State**                  | `~/.var/app/<application-id>/`                       | `~/.var/app/<application-id>/`                 |

> [!NOTE]
>
> Application sandbox state, app configs, cache, and downloads are always stored per-user in
> `~/.var/app/<application-id>/`, regardless of whether the app binary itself was installed
> with `--user` or system-wide.

---

## Desktop Menu Integration (`XDG_DATA_DIRS`)

### Modern Ubuntu Systems (Ubuntu 20.04+)

On modern Ubuntu releases, **no manual configuration is needed**. When Flatpak is installed, it
automatically deploys:

- `/etc/profile.d/flatpak.sh` (for interactive and login shells)
- `/usr/lib/systemd/user-environment-generators/60-flatpak` (for systemd user sessions, GNOME
  Shell, and Wayland/X11)

These native generators dynamically include both `/var/lib/flatpak/exports/share` and
`~/.local/share/flatpak/exports/share` into `XDG_DATA_DIRS`. A one-time session logout and
login after installing Flatpak for the first time is all that is required for newly installed
applications to populate the system application menu.

### Legacy Systems Workaround (Ubuntu 18.04 and Older Only)

> [!NOTE]
>
> This step is only relevant for legacy Ubuntu distributions (18.04 and older) or legacy
> desktop managers that lack systemd user-environment-generators. Do not apply this on modern
> Ubuntu installations, as hardcoding `XDG_DATA_DIRS` can override distribution-specific paths.

If installed Flatpak apps do not show up in the applications list on legacy systems after
relogging in:

```bash
sudo nano /etc/security/pam_env.conf
```

Add this line and save the file:

```text
XDG_DATA_DIRS DEFAULT=/usr/local/share:/usr/share:/var/lib/flatpak/exports/share:${HOME}/.local/share/flatpak/exports/share
```

### Ubuntu Software App Integration

Execute this command to install the Flatpak plugin for Ubuntu Software app integration:

```bash
sudo apt install gnome-software-plugin-flatpak
```

> **Note:** Installing the Flatpak plugin will also install a `.deb` version of the Ubuntu
> Software app, resulting in two Ubuntu Software apps being installed at the same time.

> **Note:** To disable annoying notifications from the Flatpak **Software** application, do the
> following:
>
> 1. Go to **Settings → Apps → Software**.
> 2. Turn the **Notifications** toggle off.
