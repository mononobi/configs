# Xtreme Download Manager (XDM) Installation

This guide walks you through downloading, installing, and integrating Xtreme Download Manager
(XDM) into your web browsers.

## Installation

1. Download the latest version from
   [xtremedownloadmanager.com](https://xtremedownloadmanager.com/).
2. Extract the downloaded archive and navigate into the extracted directory.
3. Execute the following commands to install:

```bash
sudo chmod 777 install.sh
sudo ./install.sh
```

## Integration for Firefox

Go to the Firefox Add-ons page and search for **XDM**. You can also find it at the following
URL:

[XDM Browser Monitor on Mozilla Add-ons](https://addons.mozilla.org/en-US/firefox/addon/xdm-browser-monitor/)

Install the XDM add-on and ensure you enable it in **Private Mode**.

## Integration for Google Chrome (and Chromium-based browsers)

The XDM extension is no longer available on the Chrome Web Store. You will have to install the
extension locally.

To do this, follow these steps:

1. Copy the `files/chrome-extension-random-id.zip` file into a permanent location and extract
   it (e.g., `~/.config/xdm-chrome-extension`).
2. On Chrome, go to **Settings -> Extensions** and enable **Developer mode**.
3. Click on the **Load unpacked** button on the top menu bar and select the root folder of the
   extension that you just extracted.
   > **Note:** Make sure you select the folder in which the `manifest.json` file is located.
4. After the extension has been installed successfully, go to the extension details, enable
   **Allow in Incognito**, and disable **Collect errors**.

> **Important Note:** You should keep the extension folder intact and do not move or rename it.
> Otherwise, it will be removed from Chrome, and you will need to repeat the steps above to
> reinstall it.

### Clarification on Extension Files

The difference between `chrome-extension-original.zip` and `chrome-extension-random-id.zip` is:

- The `chrome-extension-original.zip` file has the `key` in its `manifest.json` file and uses
  the original ID of the XDM extension from the Chrome Web Store.
- The `chrome-extension-random-id.zip` file has its `key` removed from the `manifest.json`
  file, and each time you install it on Chrome, it assigns a new ID to it.

**Why use the random ID version?** The problem with the `chrome-extension-original.zip` file is
that if you had already installed the XDM extension from the Chrome Web Store on any of your
devices before it was removed, and it had synced to your other devices, Chrome will silently
remove it without giving you any errors if you try to load it locally with the same ID. Thus,
you cannot install it with the same ID.

Because of this issue, the `chrome-extension-random-id.zip` file is provided.
