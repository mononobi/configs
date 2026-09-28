# Change Login Background (Legacy Method)

> **Warning:** This method no longer works on Ubuntu 22.04 and later. Use the guide in the
> [`install.gdm.settings.md`](/linux/install/apps-recommended/gdm-settings/install.gdm.settings.md)
> file for current Ubuntu versions.

## Installation and Usage

First, install the necessary dependencies:

```bash
sudo apt-get install libglib2.0-dev-bin
```

Then, execute the script to change the login background:

```bash
sudo ./ubuntu-gdm-set-background --image /PATH/TO/IMAGE.jpg
```

Now, press `Ctrl + Alt + F1` to view the login page. If the changes do not take effect
immediately, reboot your system.

> **Note:** There are two sample images in the `images` folder that you can use.

## Revert Changes

If anything goes wrong, you can restore the default theme by executing:

```bash
sudo update-alternatives --quiet --set gdm-theme.gresource /usr/share/gnome-shell/theme/Yaru/gnome-shell-theme.gresource
```
