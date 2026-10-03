# Troubleshooting UI Crashes and Freezes on Wayland

If you experience a UI crash or unresponsiveness on a Wayland session, use the following
methods to recover.

> [!CAUTION]
>
> **Never execute `Alt + F2` then `r` on Wayland.** In Wayland, the display server and the
> compositor/UI (GNOME Shell) run inside the same process. Restarting or terminating that
> process immediately terminates your entire user session and closes all running applications.

---

## Recovery Options

### Scenario 1: Mouse Still Works

- Press `Super + L` to lock the screen.
- Log back in to refresh the display session.

### Scenario 2: Mouse Unresponsive, Keyboard Responds

1. Press `Ctrl + Alt + F3` (or `F4` / `F5`) to switch to a virtual console (TTY).
2. Log in with your username and password.
3. Restart GNOME Shell gracefully by running:
   ```bash
   killall -HUP gnome-shell
   ```
4. If the screen does not automatically switch back to the graphical session, press:
   - `Ctrl + Alt + F2` (or whichever VT hosts your desktop session, typically F1 or F2).

### Scenario 3: Neither Mouse Nor Keyboard Responds (REISUB Emergency Reboot)

If the entire system is completely frozen, perform a safe SysRq reboot sequence:

1. Press and hold `Alt + SysRq` (the `Print Screen` key on many keyboards).
2. While holding both keys, slowly and deliberately type: **`R` `E` `I` `S` `U` `B`**
   - **R**: Switch keyboard from raw mode to XLATE
   - **E**: Send `SIGTERM` to all processes (except init)
   - **I**: Send `SIGKILL` to all processes (except init)
   - **S**: Sync all mounted filesystems to disk
   - **U**: Remount all filesystems as read-only
   - **B**: Reboot the machine immediately

This safely flushes data to disk, unmounts drives, and reboots the computer without data
corruption.
