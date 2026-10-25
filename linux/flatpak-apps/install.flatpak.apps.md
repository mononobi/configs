# Recommended Flatpak Applications Installation

Install popular desktop applications and developer tools via Flathub using Flatpak.

## Batch Installation

To install all recommended applications in one command, execute:

```bash
flatpak install --user -y flathub \
  org.mozilla.firefox \
  org.videolan.VLC \
  org.libreoffice.LibreOffice \
  org.gnome.Shotwell \
  com.transmissionbt.Transmission \
  org.remmina.Remmina \
  net.poedit.Poedit \
  org.atheme.audacious \
  org.gimp.GIMP \
  org.kde.kolourpaint \
  org.mypaint.MyPaint \
  com.getpostman.Postman \
  org.signal.Signal \
  org.telegram.desktop \
  com.visualstudio.code \
  org.chromium.Chromium \
  us.zoom.Zoom \
  net.sourceforge.squirrel_sql \
  fr.handbrake.ghb \
  org.blender.Blender \
  com.anydesk.Anydesk \
  org.gnome.Maps \
  nl.g4d.Girens \
  io.qt.QtCreator \
  chat.delta.desktop \
  org.gnome.Weather \
  nl.hjdskes.gcolor3 \
  com.usebottles.bottles \
  com.github.tchx84.Flatseal \
  org.gnome.NetworkDisplays
```

## Individual Installation Commands

### Web Browsers

```bash
flatpak install --user flathub org.mozilla.firefox
flatpak install --user flathub org.chromium.Chromium
```

### Media & Video

```bash
flatpak install --user flathub org.videolan.VLC
flatpak install --user flathub org.atheme.audacious
flatpak install --user flathub fr.handbrake.ghb
```

### Office & Productivity

```bash
flatpak install --user flathub org.libreoffice.LibreOffice
flatpak install --user flathub net.poedit.Poedit
```

### Graphics & Design

```bash
flatpak install --user flathub org.gnome.Shotwell
flatpak install --user flathub org.gimp.GIMP
flatpak install --user flathub org.kde.kolourpaint
flatpak install --user flathub org.mypaint.MyPaint
flatpak install --user flathub org.blender.Blender
flatpak install --user flathub nl.hjdskes.gcolor3
```

### Communication & Messaging

```bash
flatpak install --user flathub org.signal.Signal
flatpak install --user flathub org.telegram.desktop
flatpak install --user flathub chat.delta.desktop
flatpak install --user flathub us.zoom.Zoom
```

### Developer Tools & Editors

```bash
flatpak install --user flathub com.visualstudio.code
flatpak install --user flathub com.getpostman.Postman
flatpak install --user flathub io.qt.QtCreator
flatpak install --user flathub net.sourceforge.squirrel_sql
```

### Remote Access & Networking

```bash
flatpak install --user flathub com.anydesk.Anydesk
flatpak install --user flathub org.remmina.Remmina
flatpak install --user flathub com.transmissionbt.Transmission
flatpak install --user flathub org.gnome.NetworkDisplays
```

### Utilities & System Management

```bash
flatpak install --user flathub com.github.tchx84.Flatseal
flatpak install --user flathub com.usebottles.bottles
flatpak install --user flathub org.gnome.Maps
flatpak install --user flathub org.gnome.Weather
flatpak install --user flathub nl.g4d.Girens
```
