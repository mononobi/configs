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
sudo apt update
sudo apt install libsoup2.4-1 libwebkit2gtk-4.1-0 ca-certificates libsecret-1-0 libsecret-common libsecret-tools libopengl0 libmanette-0.2-0 -y
```

These libraries should be manually downloaded & installed:

```bash
cd ~/Downloads
wget http://archive.ubuntu.com/ubuntu/pool/main/i/icu/libicu74_74.2-1ubuntu3.1_amd64.deb
wget http://archive.ubuntu.com/ubuntu/pool/main/libx/libxml2/libxml2_2.9.14+dfsg-1.3ubuntu3.8_amd64.deb
sudo dpkg -i libicu74_74.2-1ubuntu3.1_amd64.deb libxml2_2.9.14+dfsg-1.3ubuntu3.8_amd64.deb
rm libicu74_74.2-1ubuntu3.1_amd64.deb libxml2_2.9.14+dfsg-1.3ubuntu3.8_amd64.deb
```

> **Important:** Newer versions of Ubuntu (e.g. 26.04) ship with `libwebkit2gtk-4.1`, but 
> Citrix Workspace specifically looks for the `4.0` library. You must create symbolic 
> links to the `4.1` library so Citrix can find it. After installing the Citrix App, run:

```bash
sudo mkdir -p /opt/Citrix/ICAClient/gtk2/lib
sudo ln -s /usr/lib/x86_64-linux-gnu/libwebkit2gtk-4.1.so.0 /opt/Citrix/ICAClient/gtk2/lib/libwebkit2gtk-4.0.so.37
sudo ln -s /usr/lib/x86_64-linux-gnu/libjavascriptcoregtk-4.1.so.0 /opt/Citrix/ICAClient/gtk2/lib/libjavascriptcoregtk-4.0.so.18
```

> If the app still does not launch, run one of these commands from the terminal to see 
> what other dependencies might be missing.

```bash
# This will launch the Citrix Workspace app and will show the exact error that is 
# preventing it from opening.
/opt/Citrix/ICAClient/selfservice

# This will show a report on all required dependencies and whether they are installed or not.
/opt/Citrix/ICAClient/util/workspacecheck.sh
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

> NOTE: Always run the Citrix app before trying to connect to the remote workspace through 
> the web browser.
