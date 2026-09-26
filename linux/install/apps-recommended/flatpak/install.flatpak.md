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

Execute the following command to add the Flathub repository:

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

Open the following file and add the specified line to it to allow installed Flatpak apps to show up immediately in the applications list after installation:

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

> **Note:** Installing the Flatpak plugin will also install a `.deb` version of the Ubuntu Software app, resulting in two Ubuntu Software apps being installed at the same time.

> **Note:** To disable annoying notifications from the Flatpak **Software** application, do the following:
> 1. Go to **Settings -> Apps -> Software**.
> 2. Turn the **Notifications** toggle off.
