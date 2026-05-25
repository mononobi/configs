# Rclone

Rclone is a command-line program to manage files on cloud storage. It is a feature-rich 
alternative to cloud vendors' web storage interfaces. It can be configured to mount cloud 
storages as local drives with automatic syncing.

## Installation

```bash
sudo -v ; curl https://rclone.org/install.sh | sudo bash
```

> Note: To get the latest installation command or try the other installation methods, visit 
> the official webpage at: https://rclone.org/install

## Set up a Remote Cloud Storage (Google Drive, Dropbox, etc.)

> For the purpose of this guide, we will set up a Google Drive sync.

### Step 1: Set up Google Account Access:

1. Log into the [Google Cloud Console](https://console.cloud.google.com) with your Google account.
2. Create a Project: Click the project dropdown in the top-left corner, select 
   `New Project`, name it (e.g., `RcloneSync`), and click Create.
3. Enable the API by:
   - In the top search bar, search for `Google Drive API`.
   - Click on it and click the blue `Enable` button.
4. Configure the `OAuth` Consent Screen:
   - On the left sidebar, click `OAuth consent screen`.
   - On the `OAuth Overview` page, select `Get Started` and follow the steps.
   - Fill in the mandatory fields: `App name` (e.g., `Rclone`), `User support email` (your email). 
   - Choose User Type: `External` and click Create.
   - Fill the `Developer contact information` (your email). Click `Save and Continue`. 
   - Skip Scopes by clicking `Save and Continue`. 
   - On the `Audience` page, under `Test users`, click `Add Users`, type your own Google email 
     address, click `Add`, and click `Save and Continue`.
   - On the same `Audience` page, under `Publishing status` click on `Publish` to set the app
     environment to `Production` so that tokens are not expired every 7 days.
5. Create Credentials:
   - On the left sidebar, click `Clients`. 
   - Click `+`, `Create client` at the top. 
   - Set `Application type` to `Desktop app`. 
   - Name it (e.g., `Rclone Desktop`) and click `Create`.
6. Copy the Keys or download the JSON: A box will pop up displaying your `Client ID` and 
   `Client Secret`. Copy these into a text file temporarily.

> Note: Inactive OAuth clients are subject to deletion if they are not used for 6 months. 
> You will be notified of deletion due to inactivity, and can restore clients up to 30 days 
> after deletion.

### Step 2: Configure Rclone

```bash
rclone config
```

Create a new remote, name it `gdrive`, select `Google Drive` and follow the steps.

Set these values for different configs when asked:

- `client_id` → Paste your copied Client ID.
- `client_secret` → Paste your copied Client Secret.
- `scope` → Select option `1` (drive - Full access to all files, excluding Application Data Folder).
- `service_account_file` → Leave blank (press Enter).
- `Edit advanced config?` → Type `n` (No). 
- `Use web browser to automatically authenticate rclone with remote?` → Type `y` (Yes).
- Follow the browser prompts to authenticate and allow to `grant permission`.
- The browser will display `Success! All done. Please go back to rclone.` You can now close 
  the browser tab.
- Go back to your terminal window to finish the configuration.
- `Configure this as a Shared Drive (Team Drive)?` → Type `n` (No).
- Keep this `gdrive` remote? → Type `y` (Yes, or to accept the configuration).
- Type `q` to quit the configuration menu.

Rclone configuration is complete, and you are ready to proceed to the next step.

### Step 3: Create the Mount Directory

Create an empty folder in your home directory where the Drive will be mounted.

```bash
mkdir ~/Google-Drive
```

### Step 4: Create a Systemd Service for Auto-Mounting

To ensure Google Drive is mounted seamlessly in the background every time you boot 
your PC, create a user systemd service and copy the service file from the `files` directory to 
the specified location.

```bash
mkdir -p ~/.config/systemd/user/
cp rclone-gdrive.service ~/.config/systemd/user/
```

### Step 5: Enable and Start the Service

Reload the systemd daemon and enable the service so it runs automatically.

```bash
systemctl --user daemon-reload
systemctl --user enable --now rclone-gdrive.service
```

Check the service status.

```bash
systemctl --user status rclone-gdrive.service
```

### Step 6: Bookmark in Nautilus

1. Open Files (Nautilus).
2. You will see your new `Google-Drive` folder populated with your cloud files.
3. Drag the `Google-Drive` folder to the left sidebar (or select it and press Ctrl + D) to 
   bookmark it.

## Add a Link To a Folder That is Shared With You

To add a link to a folder that is shared with you by another user, go to the Google Drive
web app, right-click on that folder, select `Organise` and then `Add shortcut`. Navigate to
the `My Drive` folder or any subfolder under it and add the shortcut there.
Now in your local mount, the shortcut will be visible and Rclone can correctly
navigate to it.
