# Farsi Keyboard Layout Correction Startup Setup

Configure the Farsi keyboard layout utility to run automatically at Windows startup.

---

## Installation Steps

1. Copy the `FarsiKeyboard` directory into a permanent local directory:

   ```text
   C:\Users\<username>\AppData\Local\
   ```

2. Create a shortcut to `FarsiKeyboard.exe` and place it in the Windows Startup folder:

   ```text
   C:\Users\<username>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\
   ```

3. **Compatibility Settings**:
   - Right-click `KeyChanger.exe` -> **Properties** -> **Compatibility**.
   - Check **Run this program in compatibility mode for:** and select **Windows XP
     (Service Pack 3)**.
   - Click **Change settings for all users** and save. _(This compatibility mode is
     required for the hook process to start)._
