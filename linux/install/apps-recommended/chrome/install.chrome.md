# Google Chrome Installation Guide

## Recommended Method

**1. Download the signing key and add it to the keyring**

```bash
wget -qO - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/google-chrome.gpg > /dev/null
```

**2. Add the Google Chrome repository**

```bash
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null
```

**3. Update package lists and install**

```bash
sudo apt update
sudo apt install google-chrome-stable
```

## Alternate Method (Not Recommended)

```bash
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i ./google-chrome*.deb
sudo apt-get install -f
```

## Troubleshooting

### White Banner on Video Players (Wayland)

> **Note:** If you are using Wayland and you see a white banner on video players on different websites (YouTube, Netflix, ...) when playing a video, you need to follow the fix provided in the `wayland/chrome.wayland.issues.md` file.

### Chrome Not Rendering UI or Webpages

> **Warning:** If after some updates to the OS, Google Chrome failed to render its own UI or websites, you should close the app and delete these two folders to fix the issue:

```text
~/.config/google-chrome/Default/GPUCache
~/.config/google-chrome/Guest Profile/GPUCache
```
