# Modify UI Configs

> **Warning:** Run these commands with caution; they are not recommended on recent Ubuntu versions (>= 22.04).

## Commands for both root and non-root users

**Hide home icon from desktop:**
```bash
gsettings set org.gnome.shell.extensions.desktop-icons show-home false
```

**Hide mounted drives from taskbar:**
```bash
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
```

**Hide desktop icons:**
```bash
gsettings set org.gnome.desktop.background show-desktop-icons false
```

**Hide trash icon from taskbar:**
```bash
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
```

**Disable experimental views:**
```bash
gsettings set org.gnome.nautilus.preferences use-experimental-views false
```

**Make bottom dock transparent (only works on GNOME >= 40):**
```bash
gsettings set org.gnome.shell.extensions.dash-to-dock customize-alphas true
gsettings set org.gnome.shell.extensions.dash-to-dock min-alpha 0
gsettings set org.gnome.shell.extensions.dash-to-dock max-alpha 0
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0
```

## Commands for non-root users only

Set a custom value for screen blank timeout (3600 is the value in seconds), set a custom value for screen to lock after going blank (5 is the value in seconds), and enable the lock after the screen goes blank.

> **Note:** If these commands issue any errors or warnings, try to install `install.dbus.x11.txt` first and then execute these commands.

```bash
gsettings set org.gnome.desktop.session idle-delay 3600
gsettings set org.gnome.desktop.screensaver lock-delay 5
gsettings set org.gnome.desktop.screensaver lock-enabled true
```
