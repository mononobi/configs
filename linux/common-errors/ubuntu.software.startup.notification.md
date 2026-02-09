## Continues Successful Update Notification On Start Up From Ubuntu Software App

If you receive a successful update notification on start up (usually for the **UEFI dbx**), 
follow this guide to fix it.

```bash
sudo fwupdmgr refresh --force
sudo fwupdmgr update
```

Investigate the result of the last command and continue based on that.

### Scenario A: It says "No updates available"

```bash
pkill gnome-software
rm -rf ~/.cache/gnome-software
sudo rm -f /var/lib/fwupd/pending.db
rm -rf ~/.local/share/gnome-software
rm -rf ~/.cache/gnome-software
pkill gnome-software
sudo rm -f /var/lib/update-notifier/user.d/*
```

> Restart the PC and the notification should not appear again.
