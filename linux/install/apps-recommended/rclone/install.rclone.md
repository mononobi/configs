# Rclone

Rclone is a command-line program to manage files on cloud storage. It is a feature-rich
alternative to cloud vendors' web storage interfaces, supporting over 70 cloud storage
providers as well as standard protocols including SFTP, WebDAV, FTP, and SMB.

## Installation

Run the automated installer script:

```bash
./install.rclone.sh
```

Or install manually via the official script:

```bash
sudo -v ; curl https://rclone.org/install.sh | sudo bash
```

> Note: To get the latest installation command or try other installation methods, visit the
> official webpage at: https://rclone.org/install

## Mounting Cloud and Network Storage

For automated storage mounts using user-space systemd services, see the dedicated recipes:

- **Google Drive**: [`google-drive-mount`](linux/install/apps-recommended/google-drive-mount/)
- **Fritz!Box NAS (SMB)**: [`fritzbox-mount`](linux/install/apps-recommended/fritzbox-mount/)
