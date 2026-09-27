# Restoring Missing Ubuntu Desktop UI

If the graphical desktop environment disappears or fails to launch after a system update,
reinstall the core `ubuntu-desktop` metapackage:

```bash
sudo apt-get install --reinstall ubuntu-desktop
```

Once installation finishes, restart the display manager or reboot the system:

```bash
sudo systemctl restart gdm3
# or
sudo reboot
```
