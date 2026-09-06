# How to Permanently Fix the DMZ-White Cursor on Ubuntu 26.04 and Later

When running Ubuntu 26.04 with GNOME on Wayland, cursor themes can sometimes fail to apply 
consistently across the desktop, login screen (GDM3), and sandboxed applications like Flatpak. 

Follow these steps to apply the DMZ-White cursor universally across your system.

## 1. Ensure the Theme is Installed System-Wide
For the login screen (which runs as the isolated `gdm` user) to access the cursor, it must be 
located in the system directory (`/usr/share/icons/`), not in your personal home folder. 
Install the official `.deb` package to guarantee this:

```bash
sudo apt update
sudo apt install xcursor-themes
```

## 2. Set the System-Wide Fallback
Wayland relies heavily on the core system default. Update it by running:

```bash
sudo update-alternatives --config x-cursor-theme
```
*Type the selection number that corresponds to `/usr/share/icons/DMZ-White/cursor.theme` 
and press **Enter**.*

## 3. Apply the Theme to Your User Desktop
Force your GNOME session to use the new cursor by writing directly to your configuration database:

```bash
gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-White'
```

## 4. Apply the Theme for Flatpak Apps (e.g., GIMP)
Because Flatpak applications are strictly sandboxed, they often fail to see the host system's 
cursor configuration. This causes the cursor to revert to black when hovering over the app. 
Grant Flatpak read-only access to the system icons directory:

```bash
sudo flatpak override --filesystem=/usr/share/icons/:ro
```

## 5. Apply the Theme to the Login Screen (GDM)
Execute these commands to make sure these directories exist and owned by the `gdm` user:

```bash
sudo mkdir -p /var/lib/gdm3/.cache/dconf /var/lib/gdm3/.config/dconf
sudo chown -R gdm:gdm /var/lib/gdm3/.cache /var/lib/gdm3/.config
```

To fix the login screen, you must temporarily open a communication bus for the hidden `gdm` 
system user and inject the setting into its isolated database:

```bash
sudo -u gdm -s /bin/bash -c "dbus-run-session gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-White'"
```

## 6. Restart the Display Manager
To apply all these changes—especially for Wayland and GDM—you need to restart the display manager. 

**⚠️ Warning:** This will instantly close all open applications and log you out. Save your 
work first.

```bash
sudo systemctl restart gdm3
```
*(Alternatively, you can just reboot your machine).*

When your system starts back up, DMZ-White will be applied consistently across your 
login screen, desktop session, and applications.
