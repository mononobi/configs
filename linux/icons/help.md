# Custom Application Icons Guide

Follow these steps to assign a custom icon to any desktop application.

## 1. Copy the Icon File

Copy your custom icon image file (e.g., `.png` or `.svg`) to the system pixmaps directory:

```bash
sudo cp ICON_FILE /usr/share/pixmaps
```

## 2. Locate the Application's Desktop Entry

Find the `.desktop` shortcut file for the target application. It is typically located in one of
the following directories:

- `/usr/share/applications` (System-wide APT packages)
- `~/.local/share/applications` (User-specific custom shortcuts)
- `/var/lib/flatpak/exports/share/applications` (System-wide Flatpak applications)
- `~/.local/share/flatpak/exports/share/applications` (User-installed Flatpak applications)
- `~/.gnome/apps` (Legacy GNOME applications)

## 3. Edit the Desktop Shortcut

Open the `.desktop` file in a text editor (using `sudo` if the file is in
`/usr/share/applications` or `/var/lib/flatpak/`):

```bash
sudo nano /usr/share/applications/<app-name>.desktop
```

Locate the `Icon=` key and update its value to the name of your icon file without the file
extension. For example:

```ini
Icon=regex101
```

Save and close the file.

## 4. Reload the Desktop UI

Reload GNOME Shell to immediately apply the updated icon:

- Press `Alt + F2`.
- Type `r` into the command prompt.
- Press `Enter`.

_(Note: On Wayland sessions where `Alt + F2` + `r` is not supported, log out and log back in to
reload icons)._
