# Fritz!Box NAS Storage Mount via Rclone

Mount your Fritz!Box NAS storage (SMB) into `$HOME/Fritzbox-Storage` automatically using Rclone
and `systemd --user`.

## Prerequisites on Fritz!Box

1. Open your browser and navigate to `http://192.168.178.1` (or `http://fritz.box`).
2. Log into the Fritz!Box administration interface.
3. Verify NAS is enabled:
   - Navigate to **Home Network** → **Storage (NAS)**.
   - Ensure **Storage (NAS) enabled** is checked.
4. Verify user permissions:
   - Navigate to **System** → **FRITZ!Box Users**.
   - Edit your user (or create a dedicated user for NAS access).
   - Ensure the option **Access to NAS contents** is checked with **Read and write**
     permissions on the desired directories.

## Installation

Run the installer script:

```bash
./install.fritzbox.mount.sh
```

You will only be prompted for:

- Fritz!Box Username
- Fritz!Box Password (input will be hidden)

The script automatically:

- Connects to the default IP `192.168.178.1` (or your custom IP if `--ip` is specified).
- Creates the Rclone remote `fritzbox:`.
- Creates the local mount directory `$HOME/Fritzbox-Storage`.
- Installs and enables the user systemd service `rclone-fritzbox.service`.

### Custom Options

If your Fritz!Box uses a non-default IP address:

```bash
./install.fritzbox.mount.sh --ip 192.168.1.1
```

If you only want to mount a specific folder or attached USB drive:

```bash
./install.fritzbox.mount.sh --share FRITZ.NAS
```

To reconfigure or update existing credentials:

```bash
./install.fritzbox.mount.sh --force
```

## Service Management

Check service and mount status:

```bash
systemctl --user status rclone-fritzbox.service
```

Inspect mounted files:

```bash
ls -la ~/Fritzbox-Storage
```

Restart or stop the mount:

```bash
systemctl --user restart rclone-fritzbox.service
systemctl --user stop rclone-fritzbox.service
```
