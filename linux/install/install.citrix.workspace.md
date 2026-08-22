## Citrix Workspace App

Download the `.deb` package from here:
[Citrix Workspace for Linux](https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html)

> You only need the `Full Package (Self-Service Support)` and NOT the `USB Support Package`.

Always read the system requirements to make sure your current Ubuntu version is supported:
[System Requirements and Compatibility](https://docs.citrix.com/en-us/citrix-workspace-app-for-linux/system-requirements.html)

> If your current Ubuntu version is not yet on the list of supported versions, follow the 
> `Compatibility Installation` before performing the `Citrix App Installation`.

### Compatibility Installation (Only If Ubuntu Version Is Not Supported Yet)

```bash
sudo apt install libsoup2.4-1 libwebkit2gtk-4.1-0 ca-certificates -y
```

### Citrix App Installation

To ensure your system stays stable, run these commands in sequence to install the bare-minimum 
core package:

1. Pre-create the core user account to prevent the logging service error:

```bash
sudo groupadd -r ctxcwa 2>/dev/null || true
sudo useradd -r -g ctxcwa -d /var/run/ctxcwa -s /usr/sbin/nologin ctxcwa 2>/dev/null || true
```

2. Install the package:

```bash
sudo dpkg -i FILE_NAME.deb
```

3. During the prompts:
   * App Protection? No
   * deviceTRUST? No
   * EPA / Endpoint Analysis? No

### Citrix App Removal

If you want to remove the installed Citrix app or perform a new installation or fix a broken 
installation, follow these steps to remove the current installation:

- Step 1: Force-Clear the Broken Package Status
```bash
sudo dpkg --purge --force-all icaclient
```

- Step 2: Clear Out Systemd Service Handlers

```bash
sudo systemctl stop ctxcwalogd.service 2>/dev/null
sudo systemctl disable ctxcwalogd.service 2>/dev/null
sudo rm -f /usr/lib/systemd/system/ctxcwalogd.service
sudo systemctl daemon-reload
```

- Step 3: Clear the Local APT/DPKG Error Status

```bash
sudo rm -f /var/lib/dpkg/info/icaclient.*
sudo apt-get update
sudo apt-get install -f
```

- Step 4: Clean the Disk Traces
```bash
sudo rm -rf /opt/Citrix/
rm -rf ~/.ICAClient/
```
