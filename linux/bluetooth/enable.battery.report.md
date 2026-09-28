# Enable Bluetooth Battery Reporting in Settings

This guide enables battery level reporting for connected Bluetooth devices in the GNOME
Settings Power menu.

> [!NOTE]
> Starting with Ubuntu 24.04, this configuration is no longer required because
> PipeWire and modern BlueZ handle Bluetooth battery reporting out of the box.

## Configuration Steps

1. Open the Bluetooth systemd service file:

   ```bash
   sudo nano /lib/systemd/system/bluetooth.service
   ```

2. Locate the `ExecStart` line and append `--experimental` at the end:

   ```ini
   ExecStart=/usr/local/libexec/bluetooth/bluetoothd --experimental
   ```

3. Reload the systemd daemon and restart the Bluetooth service:

   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart bluetooth
   ```
