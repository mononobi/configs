# Install Ventoy Globally

> **Note:**
> This will install Ventoy in a global path so that all available/future users can use the same installation. However, if you reinstall the OS, the installation will be removed.

Ventoy is a cross-platform USB multiboot creator. It works on both Windows and Linux and can create bootable drives for Windows and Linux.

## Prerequisites

First, head over to the [Ventoy Releases page on GitHub](https://github.com/ventoy/Ventoy/releases) and download the latest version.

## Installation Steps

1. **Extract the downloaded file:**
   ```bash
   tar -xf ventoy-X.Y.Z-linux.tar.gz
   ```

2. **Create a directory for Ventoy in `/opt`:**
   ```bash
   sudo mkdir /opt/ventoy
   ```

3. **Copy the extracted directory into the created directory:**
   ```bash
   sudo cp -r ventoy-X.Y.Z /opt/ventoy/
   ```

4. **Rename the copied directory:**
   ```bash
   sudo mv /opt/ventoy/ventoy-X.Y.Z /opt/ventoy/ventoy-current
   ```

5. **Configure the desktop entry:**
   Open the `files/ventoy.desktop` file and replace the line which starts with `Exec` with:
   ```ini
   Exec=/opt/ventoy/ventoy-current/VentoyGUI.x86_64
   ```

6. **Install the desktop entry:**
   Copy the modified `files/ventoy.desktop` file into `/usr/share/applications`:
   ```bash
   sudo cp files/ventoy.desktop /usr/share/applications
   ```

7. **Change the access level of the copied desktop file:**
   ```bash
   sudo chmod 644 /usr/share/applications/ventoy.desktop
   ```

8. **Create the icon directory if it does not exist:**
   ```bash
   sudo mkdir -p /usr/share/icons/hicolor/512x512/apps
   ```

9. **Copy the icon image:**
   ```bash
   sudo cp files/ventoy.png /usr/share/icons/hicolor/512x512/apps
   ```

10. **Make the app file executable:**
    ```bash
    sudo chmod 755 /opt/ventoy/ventoy-current/VentoyGUI.x86_64
    ```

11. **Make your user the owner of the app folder:**
    ```bash
    sudo chown -R USER:USER /opt/ventoy
    ```

12. **Reload the shell:**
    Press `Alt + F2`, input `r`, and hit `Enter` to reload the shell. Now the app should be visible on your application menu.

## Updating Ventoy

If you want to update the version of Ventoy, you only need to download the newer version, extract it into `/opt/ventoy/ventoy-current`, and make the `/opt/ventoy/ventoy-current/VentoyGUI.x86_64` file executable.
