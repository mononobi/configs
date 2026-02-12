## Important

The ExpressVPN Linux app has some issues that could be annoying.
If you want a stable connection to ExpressVPN, refer to the `express-open-vpn.md` guide.

## ExpressVPN Installation (GUI App)

### Step 1
Download the universal installer from your account page for Linux devices.

[Setup for Linux](https://portal.expressvpn.com/setup#linux)

### Step 2
Make the downloaded file executable.

```bash
chmod +x INSTALLER_NAME
```

### Step 3
Run the installer.

```bash
./INSTALLER_NAME
```

### Step 4
Open the app and login using an **Activation Code** or a **User & Password**.

> Full Installation Guide For The GUI App: [App for Linux](https://www.expressvpn.com/support/vpn-setup/app-for-linux/)

> Full Installation Guide For The CLI App: [App for Linux CLI](https://www.expressvpn.com/support/vpn-setup/app-for-linux-cli/)

## Uninstall
To uninstall the ExpressVPN app, run the following commands:

```bash
sudo /opt/expressvpn/bin/expressvpn-uninstall.sh
sudo rm -r /opt/expressvpn
```

> Also remove the **ExpressVPN** entry from the **Startup Applications**
