# Font Installation Guide

Instructions for installing custom fonts system-wide or for a single user on Linux.

## 1. System-Wide Installation (All Users)

Install fonts globally so they are available to all users and system services:

1. **Target Directory**:

   ```bash
   /usr/local/share/fonts
   ```

   Copy your font files (`.ttf`, `.otf`) into this directory (or a subfolder inside it):

   ```bash
   sudo cp -r /path/to/my-fonts /usr/local/share/fonts/
   ```

2. **Install fontconfig** (if font utilities like `fc-cache` are not installed):

   ```bash
   sudo apt-get install fontconfig
   ```

3. **Reload Font Cache**:

   ```bash
   fc-cache -f -v
   ```

4. **Apply Fonts**: Open the **GNOME Tweaks** application (`gnome-tweaks`) and navigate to the
   **Fonts** section to select your preferred interface, document, and monospace fonts.

5. **Restart System**: Restart your system (or log out and back in) to ensure all running
   applications recognize the new fonts.

---

## 2. Per-User Installation (Current User Only)

Install fonts locally without requiring root or administrative privileges:

1. **Target Directory**:

   ```bash
   ~/.fonts
   ```

   _(Alternatively: `~/.local/share/fonts`)_

   Copy your font files into this directory:

   ```bash
   mkdir -p ~/.fonts
   cp -r /path/to/my-fonts ~/.fonts/
   ```

2. **Font Cache**: Per-user fonts are typically detected automatically without needing a manual
   cache reload.

3. **Apply Fonts**: Open **GNOME Tweaks** and set the fonts in the **Fonts** section.

4. **Restart System**: Restart your system (or log out and back in).
