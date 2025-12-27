# Global Chrome Fix for Wayland

## The Issue

On Ubuntu with Wayland with AMD Ryzen iGPUs, Google Chrome often displays a solid 
white screen where the video should be (YouTube, Plex, Netflix, etc.), even though the 
audio plays correctly. This is caused by a conflict between Chrome's GPU compositing and 
the AMD Wayland driver.

This guide uses `dpkg-divert` to permanently inject the `--disable-gpu-compositing` flag into 
all Chrome instances on Ubuntu. This fix survives `apt` updates and applies to all Web Apps 
(Netflix, YouTube, etc.) and system shortcuts.

## Prerequisites

* You are using the Google Chrome `.deb` package.
* You have `sudo` privileges.

## Step 1: Divert the Binaries

First, we tell Ubuntu to "divert" the official Google Chrome files. When Chrome 
updates, `apt` will now automatically install the official scripts to a `.real` filename 
instead of overwriting the custom ones.

Run these two commands:

```bash
# Divert the main system binary
sudo dpkg-divert --add --rename --divert /usr/bin/google-chrome-stable.real /usr/bin/google-chrome-stable
```

```bash
# Divert the internal Chrome binary (used by Web Apps/Shortcuts)
sudo dpkg-divert --add --rename --divert /opt/google/chrome/google-chrome.real /opt/google/chrome/google-chrome
```

## Step 2: Create the Persistent Wrappers

Now we create the custom scripts in the original locations. These scripts call the "real" binaries
but inject the required flag while preserving any other arguments (like `--app-id`).

### A. Create the `/usr/bin` wrapper

Open the file editor:

```bash
sudo nano /usr/bin/google-chrome-stable
```

Paste this content:

```bash
#!/bin/bash
exec /usr/bin/google-chrome-stable.real --disable-gpu-compositing "$@"
```

### B. Create the `/opt` wrapper

Open the file editor:

```bash
sudo nano /opt/google/chrome/google-chrome
```

Paste this content:

```bash
#!/bin/bash
exec /opt/google/chrome/google-chrome.real --disable-gpu-compositing "$@"
```

## Step 3: Set Permissions

Make both of the new scripts executable so the system can run them:

```bash
sudo chmod +x /usr/bin/google-chrome-stable
sudo chmod +x /opt/google/chrome/google-chrome
```

## How it works

* **`$@` Propagation**: The "`$@`" at the end of the scripts ensures that any arguments passed 
  by the Web Apps (like `--profile-directory` or `--app-id`) are passed through correctly.
* **`exec`**: We use `exec` so that the wrapper script replaces itself with the Chrome process,
  ensuring there's no extra "zombie" shell process hanging around.
* **Update Proof**: When you run `sudo apt upgrade`, Ubuntu will see the diversion and move 
  Google's new script to the `.real` path, leaving the custom wrappers untouched.

## How to Undo (If the bug is fixed in a future update)

If you ever want to return to the default behavior, run these commands:

```bash
# Remove the custom scripts
sudo rm /usr/bin/google-chrome-stable
sudo rm /opt/google/chrome/google-chrome
```

```bash
# Remove the diversions (this restores the .real files to their original names)
sudo dpkg-divert --remove --rename /usr/bin/google-chrome-stable
sudo dpkg-divert --remove --rename /opt/google/chrome/google-chrome
```
