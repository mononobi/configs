# Fixing "Oh no! Something has gone wrong" Error Screen

If Ubuntu boots into a white error screen stating **"Oh no! Something has gone wrong. A
problem has occurred and the system can't recover. Please contact a system
administrator"**, this is commonly caused by interrupted, deferred, or partially applied
package updates.

Follow these steps to recover via virtual terminal.

---

## Recovery Steps

### 1. Open a Virtual Console (TTY)

On the error screen, switch to a text terminal using one of the following key
combinations:

- `Ctrl + Alt + F6` (Default)
- `Ctrl + Alt + F3`
- `Ctrl + Shift + F4`

### 2. Authenticate

Log in with your standard user account credentials.

### 3. Repair and Complete Pending Updates

Run the following package repair and upgrade sequence:

```bash
# Update repository indices and complete deferred system upgrades
sudo apt-get update && sudo apt-get dist-upgrade

# Clean up cached packages and remove orphaned dependencies
sudo apt-get clean && sudo apt-get autoremove

# Reboot system
sudo reboot
```

After rebooting, the desktop environment should load normally.
