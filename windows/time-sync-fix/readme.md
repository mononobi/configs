# Windows Dual-Boot Time Synchronization Fix

Ensure clock synchronization across dual-boot environments (e.g., Linux and Windows
hardware clock desynchronization).

---

## Setup Instructions

1. Copy the `TimeSync` folder to a permanent local path:

   ```text
   C:\Users\<username>\AppData\Local\
   ```

2. Create a shortcut to `TimeSyncInvoke.exe` and place it in the Windows Startup
   directory:

   ```text
   C:\Users\<username>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\
   ```

3. **Antivirus Exclusions**: Add `TimeSync.exe` and `TimeSyncInvoke.exe` to your Windows
   Defender / Antivirus exclusions list to prevent background sync execution from being
   blocked.
