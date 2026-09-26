# Install Ventoy (Local)

> **Note:** This will install Ventoy in the user's local path, so each user will need to have their own installation. However, if you reinstall the OS, the installation will be preserved as long as you have `/home` mounted on a separate partition.

Ventoy is a cross-platform USB multiboot creator. It works on Windows and Linux and can create bootables for both operating systems.

## Download and Extract

First, head over to [Ventoy Releases on GitHub](https://github.com/ventoy/Ventoy/releases) and download the latest version.

Execute this command to extract the downloaded file (replace `X.Y.Z` with the downloaded version):

```bash
tar -xf ventoy-X.Y.Z-linux.tar.gz
```

## Installation

Execute this command to make a directory for Ventoy:

```bash
mkdir ~/.local/share/ventoy
```

Copy the extracted directory into the created directory:

```bash
cp -r ventoy-X.Y.Z ~/.local/share/ventoy
```

Rename the copied directory:

```bash
mv ~/.local/share/ventoy/ventoy-X.Y.Z ~/.local/share/ventoy/ventoy-current
```

## Desktop Entry Configuration

Open the `files/ventoy.desktop` file and replace `USER_NAME` with your actual username.

Copy the modified `files/ventoy.desktop` file into `~/.local/share/applications`:

```bash
cp files/ventoy.desktop ~/.local/share/applications
```

Create the icon directory if it does not exist:

```bash
mkdir -p ~/.local/share/icons/hicolor/512x512/apps
```

Copy the icon image:

```bash
cp files/ventoy.png ~/.local/share/icons/hicolor/512x512/apps
```

Execute this to make the app file executable:

```bash
sudo chmod 755 ~/.local/share/ventoy/ventoy-current/VentoyGUI.x86_64
```

## Final Steps

Press `Alt + F2`, input `r`, and hit `Enter` to reload the shell. Now the app should be visible in your application menu.

## Updating

If you want to update the Ventoy app, you only need to download the newer version, extract it into `~/.local/share/ventoy/ventoy-current`, and make the `~/.local/share/ventoy/ventoy-current/VentoyGUI.x86_64` file executable.
