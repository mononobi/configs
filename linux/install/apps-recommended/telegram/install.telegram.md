# Telegram Desktop Installation

## Recommended Installation (Flatpak)

Flatpak is the recommended way to install Telegram Desktop:

```bash
flatpak install flathub org.telegram.desktop
```

Execute this command to let Telegram access your home directory (to be able to share or
save files):

```bash
sudo flatpak override --filesystem=home org.telegram.desktop
```

## Snap Installation (Not Recommended)

> **Warning:** You can also install using Snap, but it's not recommended at all as it has
> terrible performance.

```bash
sudo snap install telegram-desktop --channel=latest/stable
```

Always check for the latest channel before installing:

```bash
snap info telegram-desktop
```

## APT Installation (Not Recommended)

> **Note:** APT install is not recommended and has an obsolete version.

```bash
sudo apt-get install telegram-desktop
```
