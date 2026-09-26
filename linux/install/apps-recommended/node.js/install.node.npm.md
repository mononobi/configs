# Install Node.js and npm

This installation method is the recommended way to install Node.js and npm.

Update the version to the newest stable release if available. Note that even version numbers (e.g., 22, 24) are Long-Term Support (LTS) releases and are preferred.

Run the following commands to set up the NodeSource repository and install Node.js:

```bash
cd ~
curl -sL https://deb.nodesource.com/setup_24.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt install nodejs
node -v
npm -v
```

> **Note:** If you have already installed an older version of Node using this script, you can just update the version number in the `curl` line and execute the same script again to update the Node installation to a new version.
