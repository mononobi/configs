# Install TeamViewer

Run the following commands to download and install TeamViewer:

```bash
wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
sudo apt install ./teamviewer_amd64.deb
```

## Check for Auto-Updating

To verify the auto-update repository, run:

```bash
cat /etc/apt/sources.list.d/teamviewer.list
```

## Add PGP Key

Execute this command to add the PGP key to the recommended place:

```bash
wget --quiet -O - https://dl.teamviewer.com/download/linux/signature/TeamViewer2017.asc | sudo tee /etc/apt/trusted.gpg.d/teamviewer.asc
```
