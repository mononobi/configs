# Google Drive Mount via Rclone

Mount Google Drive as a local filesystem directory at `~/Google-Drive` using Rclone and
`systemd --user`.

## Installation

Run the interactive installer script:

```bash
./install.google.drive.mount.sh
```

## Set up Google Account Access

### Step 1: Set up Google Account Access

1. Log into the [Google Cloud Console](https://console.cloud.google.com) with your Google
   account.
2. **Create a Project**: Click the project dropdown in the top bar, click **New Project**, name
   it (e.g., `RcloneSync`), and click **Create**. Ensure this project is active.
3. **Enable the Google Drive API**:
   - In the navigation menu or top search bar, search for **Google Drive API** (under **APIs &
     Services** → **Library**).
   - Click **Google Drive API** and click the blue **Enable** button.
4. **Configure OAuth Consent Screen & Branding**:
   - Navigate to **APIs & Services** → **OAuth consent screen**.
   - Under **User Type**, choose **External** and click **Create**.
   - In the **Branding** tab, fill in the required fields:
     - **App name**: Enter a name (e.g., `Rclone Desktop`).
     - **User support email**: Select your Google email address.
     - **Application home page**: Enter your personal GitHub profile or website (e.g.,
       `https://github.com/<username>`).
     - **Application privacy policy link**: Enter your GitHub profile or repository URL (e.g.,
       `https://github.com/<username>`).
     - **Authorized domains**: Add the top-level domain matching the URLs provided above (e.g.,
       `github.com`). Google Cloud Console requires the authorized domain to match your links
       before allowing you to save or publish the app.
     - **Developer contact information**: Enter your email address.
   - Click **Save and Continue** through the Scopes step (dynamic scopes like
     `https://www.googleapis.com/auth/drive` are requested automatically during Rclone OAuth).
   - Under **Audience / Publishing status**, set the app to **In production** (click **Publish
     App** and confirm).

   > **Important**: Setting the publishing status to **In production** is critical for personal
   > Google Drive access. If left in **Testing** mode, Google automatically expires OAuth
   > refresh tokens after 7 days, forcing frequent re-authorization. In production, personal
   > tokens persist indefinitely without requiring formal app verification.

5. **Create OAuth 2.0 Client Credentials**:
   - Go to **APIs & Services** → **Credentials**.
   - Click **+ Create Credentials** at the top and select **OAuth client ID**.
   - Under **Application type**, choose **Desktop app**.
   - Set a name (e.g., `Rclone Desktop`) and click **Create**.
   - A modal dialog displays your **Client ID** and **Client Secret**. Copy both values
     immediately.

   > **Note**: Google Cloud Console permanently hashes and masks the Client Secret (`****xxxx`)
   > once you close the creation modal. The secret cannot be viewed or downloaded again from
   > the console UI. If you lose the secret, you can generate a new one anytime by opening the
   > client in the Credentials list and clicking **Add client secret**.

### Step 2: Run Installer

Run the installer script:

```bash
./install.google.drive.mount.sh
```

When prompted:

1. Paste your **Client ID**.
2. Paste your **Client Secret**.

The installer will:

- Automatically invoke `rclone config create gdrive drive ...` and launch a local browser
  window for Google OAuth sign-in.
- Create the local mount directory at `$HOME/Google-Drive`.
- Install, enable, and start the user systemd service (`rclone-gdrive.service`).

## Service Management

Check service status:

```bash
systemctl --user status rclone-gdrive.service
```

Stop, start, or restart the mount service:

```bash
systemctl --user restart rclone-gdrive.service
systemctl --user stop rclone-gdrive.service
systemctl --user start rclone-gdrive.service
```

View live logs:

```bash
journalctl --user -u rclone-gdrive.service -f
```
