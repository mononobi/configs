# Install Slack

You have two main options for installing Slack on Linux:

## Option 1: Using Flatpak (Recommended for Universal Support)

You can easily install Slack using Flatpak by running:

```bash
flatpak install flathub com.slack.Slack
```

## Option 2: Using the Official DEB Package

Alternatively, you can manually download and install the package:

1. Go to the [Slack Downloads page for Linux](https://slack.com/downloads/linux) and
   download the Debian (`.deb`) installer.
2. Open your terminal in the directory where the file was downloaded and execute this
   command (replace `FILE_NAME.deb` with the actual file name):

```bash
sudo apt install ./FILE_NAME.deb
```
