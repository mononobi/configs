# Signal Desktop Installation Guide

Follow these steps to install the official Signal Desktop application.

## 1. Install the Official Public Software Signing Key

Run the following commands to download and install the official software signing key:

```bash
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg;
cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
```

## 2. Add the Repository to Your List of Repositories

Run the following commands to add the Signal repository to your system:

```bash
wget -O signal-desktop.sources https://updates.signal.org/static/desktop/apt/signal-desktop.sources;
cat signal-desktop.sources | sudo tee /etc/apt/sources.list.d/signal-desktop.sources > /dev/null
```

## 3. Update the Package Database and Install Signal

Finally, update your local package database and install Signal Desktop:

```bash
sudo apt update && sudo apt install signal-desktop
```
