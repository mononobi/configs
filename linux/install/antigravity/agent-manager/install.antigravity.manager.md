# Antigravity Agent Manager

## Download Antigravity (Not the Antigravity IDE)

Go to this link and download the latest version:

[Antigravity](https://antigravity.google/download)

## Install

Create the folder:

```bash
mkdir -p ~/.antigravity-manager
```

Extract the downloaded file to the created folder:

```bash
tar -xzf Antigravity.tar.gz -C ~/.antigravity-manager
```

Set required permissions and ownership:

```bash
sudo chown root:root ~/.antigravity-manager/Antigravity-x64/chrome-sandbox
sudo chmod 4755 ~/.antigravity-manager/Antigravity-x64/chrome-sandbox
```

Copy the app shortcut:

```bash
cp files/antigravity-manager.desktop ~/.local/share/applications/
```

Copy the app icon:

```bash
cp files/antigravity.png ~/.local/share/icons/
```
