# Resolving Display Backlight Sleep Issues on Screen Lock

On Ubuntu with GNOME (and certain display hardware), locking the screen turns the display
output black, but the monitor backlight remains powered on instead of entering low-power DPMS
sleep mode.

---

## Option 1: Automated Daemon Script (Recommended)

This solution reliably turns off the backlight across all scenarios: locking via menu, pressing
`Super + L`, and automatic system idle timeout.

1. Make the bundled script executable:

   ```bash
   sudo chmod 775 screen-lock
   ```

2. Add `screen-lock` to your **Startup Applications** (`gnome-session-properties`).

3. Restart your computer.

Whenever the session is locked manually or automatically by idle timeouts, the monitor
backlight will immediately power off into DPMS standby.

---

## Option 2: Custom Keyboard Shortcut (Alternative)

> [!NOTE]
>
> This workaround only triggers when locking the screen manually using the custom shortcut. It
> does not apply to idle timeouts or menu locks.

1. Ensure `gnome-screensaver` and X11 utilities are installed:

   ```bash
   sudo apt install -y gnome-screensaver
   ```

2. Open **Settings** -> **Keyboard** -> **Keyboard Shortcuts** -> **View and Customize
   Shortcuts** -> **Custom Shortcuts**.

3. Click **Add Shortcut (+)**:
   - **Name**: `Lock screen`
   - **Command**:
     ```bash
     bash -c "gnome-screensaver-command -l; sleep 0.5; xset dpms force off"
     ```
   - **Shortcut**: `Super + L`
