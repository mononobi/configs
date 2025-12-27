## Check if Firefox is using Wayland

* Open "about:support" in Firefox.
* Look for the "Window Protocol" entry; it should be "wayland".

## Force Firefox to Use Wayland

If Firefox is using "x11" or "xWayland", you should manually force it to use "Wayland".
Run Firefox with this environment variable to test:

```bash
MOZ_ENABLE_WAYLAND=1 firefox
```

If that switches "about:support" to "wayland", you can make it permanent by
adding "MOZ_ENABLE_WAYLAND=1" to your "/etc/environment" file (requires a
reboot to take effect system-wide).

Open the file:

```bash
sudo nano /etc/environment
```

Add this line to the file:

```dotenv
MOZ_ENABLE_WAYLAND=1
```

Restart the PC.
