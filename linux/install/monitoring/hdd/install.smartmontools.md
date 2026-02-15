# Smartmontools Simple Setup Guide

## Strategy

- **Cron**: Runs the active self-tests (Simple, reliable scheduler). 
- **Smartd**: Passive monitoring only (Alerts you if a test fails).

## Part 1: Install & Notification Setup

### Install Packages

```bash
sudo apt update
sudo apt install smartmontools libnotify-bin
```

### Identify Drive IDs

Run this command and copy your drive IDs.

```bash
ls -l /dev/disk/by-id/
```

> NVMe: Use /dev/nvme0 (Controller Name)

> SATA: Use /dev/disk/by-id/ata-Name...

### Setup Notification Script

This is required so you get a notification if a drive has an issue.

Create the file:

```bash
sudo nano /usr/local/bin/smartd-notify.sh
```

Paste the content of the local `smartd-notify.sh` file into that file.

Make it executable:

```bash
sudo chmod +x /usr/local/bin/smartd-notify.sh
```

## Part 2: Configure Smartd (Passive Monitor Only)

Smartd will NOT run tests. It will only check health status every 3 hours.

Edit the config:

```bash
sudo nano /etc/smartd.conf
```

### Disable default scanning:

Find the line starting with `DEVICESCAN` and comment it out by adding a `#` at the start:

```
#DEVICESCAN -d removable -n standby ...
```

Paste the content of the corresponding `smartd.*.conf` file into that file.
Replace drive IDs with your actual drive IDs.

### Update Interval

```bash
sudo nano /etc/default/smartmontools
```

Set this in the file:

```bash
# Check every hour.
smartd_opts="--interval=3600"
```

## Part 3: Apply Changes

Enable the service for automatic startup:

```bash
sudo systemctl enable smartmontools
```

Restart the service to load the new schedule:

```bash
sudo systemctl restart smartmontools
```

Check the service status:

```bash
sudo systemctl status smartmontools
```

## Part 4: Configure Schedule (Cron)

We use the system scheduler to run tests. It runs as root, bypassing complex permission issues.

Open the root `crontab`:

```bash
sudo crontab -e
```

Paste the content of the local `crontab` file into that file.
Change the drive IDs to the actual drive IDs.

## Part 5: Allow Smartd to Read NVMe (AppArmor)

We need to let smartd (the monitor) read the NVMe status.

Edit profile:

```bash
sudo nano /etc/apparmor.d/local/usr.sbin.smartd
```

Add/Ensure these lines exist:

```bash
/dev/nvme0 r,
/dev/disk/by-id/ r,
/dev/disk/by-id/** r,
```

Apply:

```bash
sudo systemctl reload apparmor
sudo systemctl restart smartmontools
```

## Part 6: Verification

### Test the Notification:

Run:

```bash
/usr/local/bin/smartd-notify.sh
```

If you see a notification, alerts are working.

### Test the Schedule (Right Now):

To prove Cron works, run a test manually using the exact command from your crontab:

```bash
sudo /usr/sbin/smartctl -t short /dev/nvme0
```

If it says `Self-test has begun`, the scheduler will work perfectly.

## Part 7: Understanding Errors & Manual Testing

### 1. What a Notification Looks Like

If a problem is detected, a critical notification will pop up on your desktop:

*   **Headline:** "⚠️ HARD DRIVE WARNING"
*   **Body:** It will list the Device Name and the Specific Error.
    *   **Example:** Error: Device: ... 8 Sectors pending re-allocation
    *   **Example:** Error: Device: ... Self-Test Log error count increased

### 2. How to Investigate (See Details)

The notification only gives you the summary. To see exactly what is happening, open your
terminal and run the "Show All" command for the specific drive:

```bash
sudo smartctl -a /dev/disk/by-id/[DRIVE_ID]
```

*   **HDDs:** Look for "Reallocated_Sector_Ct" or "Current_Pending_Sector". Non-zero values are bad.
*   **SSDs:** Look for "Media_Wearout_Indicator" or "Percentage Used".

### 3. How to Run a Manual Test

If you suspect a drive is failing and want to force a test immediately (ignoring the schedule):

**Short Test (2 mins):**

```bash
sudo smartctl -t short /dev/disk/by-id/[DRIVE_ID]
```

**Long Test (20+ hours):**

```bash
sudo smartctl -t long /dev/disk/by-id/[DRIVE_ID]
```

**Check Test Progress:**

Run:

```bash
sudo smartctl -a /dev/disk/by-id/[DRIVE_ID]
```

Near the top, it will say:

```
Self-test execution status: (24%) Self-test routine in progress...
```

**Show Past Runs:**

```bash
sudo smartctl -l selftest /dev/disk/by-id/[DRIVE_ID]
```

**Show Current Power on Time:**

```bash
sudo smartctl -a /dev/disk/by-id/[DRIVE_ID] | grep "Power On Hours"
```

### Note On NVMe Drive ID

This tool has an issue using device ID of the NVMe drives, so the controller name
should be used instead.

- Instead Of: `/dev/disk/by-id/nvme-Samsung_SSD_990`
- Use: `/dev/nvme0` or `/dev/nvme1`
