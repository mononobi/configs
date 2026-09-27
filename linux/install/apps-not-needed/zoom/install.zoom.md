# Zoom Installation

Download the Zoom package from the
[official Zoom download page](https://zoom.us/download).

To install the downloaded package, execute the following command (replace `file_name.deb`
with the actual name of the downloaded file):

```bash
sudo dpkg -i file_name.deb
```

If the installation fails due to missing dependencies, execute this command to fix them:

```bash
apt --fix-broken install
```

Then, try to install the package again:

```bash
sudo dpkg -i file_name.deb
```
