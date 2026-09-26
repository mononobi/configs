# FUSE Installation Guide for AppImages

> **Note:** FUSE (Filesystem in Userspace) is required to support running AppImages on your system.

## For Ubuntu 21.10 and Older

Run the following commands to install FUSE, load the module, and add your user to the `fuse` group:

```bash
sudo apt install fuse libfuse2
sudo modprobe fuse
sudo groupadd fuse

user="$(whoami)"
sudo usermod -a -G fuse $user
```

## For Ubuntu 22.04 and Newer

For newer versions of Ubuntu, FUSE is handled differently. Install the necessary packages using these commands:

```bash
sudo add-apt-repository universe
sudo apt install libfuse2
sudo apt-get install libxi6 libxrender1 libxtst6 mesa-utils libfontconfig libgtk-3-bin tar dbus-user-session
```
