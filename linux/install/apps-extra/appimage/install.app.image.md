# Setting up AppImage Applications

There are two ways to create an application icon for an AppImage:

## Manual Method

Make the AppImage file executable:

```bash
chmod +x FILE.AppImage
```

Move it to your local bin directory:

```bash
cp FILE.AppImage ~/.local/bin
```

Extract the AppImage to get the icon and `.desktop` files from it:

```bash
./FILE.AppImage --appimage-extract
```

This will create a folder named `squashfs-root`. Navigate to this folder and open the
`.desktop` file.

Edit these lines in the file to point to the AppImage and the icon:

```ini
Exec=/home/USER_NAME/.local/bin/FILE.AppImage
Icon=ICON_NAME
```

Next, copy the `.desktop` file to the applications directory:

```bash
cp FILE.desktop ~/.local/share/applications
```

Locate the app icon inside the `squashfs-root` directory and execute this:

```bash
sudo cp ICON_NAME.png /usr/share/pixmaps/
```

Now press `Alt + F2`, type `r`, and press **Enter** (to restart the GNOME Shell). The app
icon will now be visible in the application menu.

## Automated Method

You can use AppImageLauncher to automate this process.

```bash
sudo add-apt-repository ppa:appimagelauncher-team/stable
sudo apt-get update
sudo apt-get install appimagelauncher
```

Run the installed package:

```bash
sudo appimagelauncher
```

Once it is running, executing any AppImage will prompt you with an option to create a
shortcut for it automatically.
