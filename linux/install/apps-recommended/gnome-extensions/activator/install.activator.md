# GNOME Extensions Installation Guide

## Installation Options

### Option 1: Support for Both Browser and App

Install the following packages if you want support in both the web browser and the Extension Manager application:

```bash
sudo apt install gnome-shell-extension-manager
sudo apt install gnome-shell-extensions
```

### Option 2: Support for Browser Only

Follow all steps below if you only require support in the web browser:

1. Install the GNOME shell extensions:

```bash
sudo apt install gnome-shell-extensions
```

2. Go to [https://extensions.gnome.org](https://extensions.gnome.org) and install the browser extension if it is not already installed.

3. Open a terminal and install the browser connector:

```bash
sudo apt install gnome-browser-connector
```

## Managing Extensions

To modify the settings of each installed extension:
- **Older GNOME versions:** Open the 'Gnome Tweaks' app and find the extension in the extensions tab.
- **Newer GNOME versions:** Open the standalone 'Extensions' app.

## Compatibility Workarounds

### Disable Version Validation Globally

To disable the extension version compatibility check for all extensions, execute the following command:

```bash
dconf write /org/gnome/shell/disable-extension-version-validation
```

### Manual Compatibility Fix for Older Extensions

To manually make older extensions compatible with a new GNOME version:

1. Navigate to the following location:

```bash
~/.local/share/gnome-shell/extensions
```

2. Go into the folder of the specific extension you want to update.
3. Open the `metadata.json` file and add the current GNOME version into the `shell-version` list.
