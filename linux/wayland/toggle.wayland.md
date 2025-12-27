# Wayland Toggle for GDM3 (Ubuntu 20.04+)

On recent Ubuntu versions (24.04 and up), Wayland offers superior performance compared to X11,
particularly with AMD GPUs.

To toggle Wayland availability on any distribution using `gdm3` (e.g., Ubuntu), follow
these steps:

## 1. Edit the GDM3 Custom Configuration

Open the `custom.conf` file:

```bash
sudo nano /etc/gdm3/custom.conf
```

### Disable Wayland

To disable Wayland, uncomment the line containing `WaylandEnable=false` in the file.

### Enable Wayland

To enable Wayland, comment out the line containing `WaylandEnable=false` in the file.

## 2. Restart the GDM3 Service

Restart the `gdm3` service to apply the changes:

```bash
sudo systemctl restart gdm3
```

## 3. Configure Display Settings

After restarting, go to your display settings and configure your monitors as desired for the
login screen (e.g., disable the internal laptop display). Click "Save" or "Apply" when finished.

## 4. Copy Monitor Configuration for GDM User

Execute the following commands to copy your user's `monitors.xml` file into the `gdm` user's
home directory, ensuring the display settings persist for the login screen:

```bash
sudo cp ~/.config/monitors.xml ~gdm/.config/monitors.xml
sudo chown gdm:gdm ~gdm/.config/monitors.xml
```
