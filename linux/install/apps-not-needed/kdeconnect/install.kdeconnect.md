# KDE Connect Installation

> **Note:** If you're using GNOME Shell, it is recommended to install the `gsconnect`
> GNOME extension instead.

## Installation

Run the following command to install KDE Connect:

```bash
sudo apt install kdeconnect
```

## Startup Configuration

To run the KDE Connect indicator on startup, add a new entry in the `Startup Applications`
app and set the command to:

```bash
/usr/bin/kdeconnect-indicator
```

## Uninstallation

To remove KDE Connect and its dependencies, execute these commands:

```bash
sudo killall kdeconnectd
sudo apt-get remove kdeconnect
sudo apt-get autoremove
```
