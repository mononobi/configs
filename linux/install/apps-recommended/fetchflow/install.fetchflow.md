# FetchFlow Download Manager Installation & Setup

FetchFlow is a modern, high-performance download accelerator and video downloader built on
**.NET 8 and native GTK3**. It is the active, modernized continuation and fork of the original
XDM (Xtreme Download Manager) codebase, replacing legacy Java Swing with native Linux Wayland
and HiDPI display scaling support.

---

## Installation

Run the installer recipe:

```bash
cd linux/install/apps-recommended/fetchflow
./install.fetchflow.sh
```

### Options

```bash
./install.fetchflow.sh --help
./install.fetchflow.sh --version 9.1.16.0   # Install an explicit version
./install.fetchflow.sh --force              # Force reinstallation
```

---

## Browser Integration (Manifest V3)

FetchFlow integrates with web browsers via local loopback IPC (`127.0.0.1:8597`) without any
cloud telemetry.

### 1. Mozilla Firefox (and Gecko-based browsers)

Install the signed extension directly with one click from Mozilla Add-ons:

- **AMO Page:**
  [FetchFlow Browser Helper on Mozilla Add-ons](https://addons.mozilla.org/en-US/firefox/addon/fetchflow-browser-helper/)
- Ensure you enable **Allow in Private Windows** in extension settings if you download in
  private browsing mode.

### 2. Google Chrome / Chromium-based browsers

1. Download the extension archive (`fetchflow-chrome-extension-<version>.zip`) from
   [FetchFlow Releases](https://github.com/Mayanktaker/fetchflow/releases).
2. Extract the archive into a permanent directory (e.g.
   `~/.config/fetchflow-chrome-extension`).
3. Open `chrome://extensions` in your browser and enable **Developer mode** (top-right toggle).
4. Click **Load unpacked** and select the extracted folder containing `manifest.json`.
5. Under extension details, enable **Allow in Incognito**.

---

## File & Configuration Paths

- **Application Binary:** `/usr/bin/fetchflow`
- **Installation Root:** `/opt/fetchflow/`
- **Application Data & SQLite DB:** `~/.fetchflow-app-data/`
- **Crash & Diagnostic Logs:** `~/.fetchflow-app-data/crash.log`
