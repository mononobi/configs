# Google Drive Mount via Rclone

Mount Google Drive as a local filesystem directory at `~/Google-Drive` using Rclone and
`systemd --user`.

## Installation

Run the interactive installer script:

```bash
./install.google.drive.mount.sh
```

## Set up Google Account Access

### Step 1: Set up Google Account Access:

1. Log into the [Google Cloud Console](https://console.cloud.google.com) with your Google
   account.
2. Create a Project: Click the project dropdown in the top-left corner, select `New Project`,
   name it (e.g., `RcloneSync`), and click Create.
3. Enable the API:
   - In the top search bar, search for `Google Drive API`.
   - Click on it and click the blue `Enable` button.
4. Configure the OAuth Consent Screen:
   - On the left sidebar, click `OAuth consent screen`.
   - Select `External` and click Create.
   - Fill in `App name` (e.g., `Rclone`) and user support email.
   - On the `Audience` page under `Test users`, add your own Google email address.
   - Under `Publishing status`, set to `Production` to avoid 7-day token expiration.
5. Create Credentials:
   - On the left sidebar, click `Credentials` -> `Create Credentials` -> `OAuth client ID`.
   - Select `Desktop app` and click Create.
   - Copy the `Client ID` and `Client Secret`.

### Step 2: Run Installer

Run `./install.google.drive.mount.sh` and enter your Client ID and Client Secret when prompted.
The installer will:

- Automatically authenticate via browser OAuth.
- Create `$HOME/Google-Drive`.
- Install and start the user systemd unit `rclone-gdrive.service`.

## Service Management

Check service status:

```bash
systemctl --user status rclone-gdrive.service
```

Stop or restart the mount:

```bash
systemctl --user restart rclone-gdrive.service
systemctl --user stop rclone-gdrive.service
```
