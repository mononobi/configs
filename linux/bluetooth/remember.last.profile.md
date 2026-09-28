# Remember Last Used Bluetooth Profile (PulseAudio)

This guide configures PulseAudio to remember the last profile in use (e.g., A2DP vs.
HSP/HFP) for connected Bluetooth devices.

> [!NOTE]
>
> Starting with Ubuntu 24.04, this configuration is no longer required because PipeWire is
> used by default and automatically remembers device profiles.

## Configuration Steps

1. Open `/etc/pulse/default.pa` in a text editor with root privileges:

   ```bash
   sudo nano /etc/pulse/default.pa
   ```

2. Search for the following line:

   ```text
   load-module module-card-restore
   ```

3. Modify it to append `restore_bluetooth_profile=true`:

   ```text
   load-module module-card-restore restore_bluetooth_profile=true
   ```

   > **Note**: If the line `load-module module-card-restore` does not exist in the file,
   > add the complete line at the end:
   >
   > ```text
   > load-module module-card-restore restore_bluetooth_profile=true
   > ```

4. Save the file and reboot your system:

   ```bash
   sudo reboot
   ```

After rebooting, PulseAudio will remember your selected Bluetooth profile across
connections.
