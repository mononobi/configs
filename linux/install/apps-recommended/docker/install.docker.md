# Docker Installation Guide

## Install Using Official Docker APT (Recommended)

This approach will install both `docker` and `docker compose` from the official Docker APT repository, which always provides the latest versions.

```bash
sudo apt-get update

sudo apt-get install ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## Install Using Official Script

Alternatively, you can install Docker using the official installation script:

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo ./get-docker.sh
```

## Post-Installation Steps

The following steps apply to both installation methods.

> **Note:** The following packages are required for `docker login` to work properly.

```bash
sudo apt-get install gnupg2 pass
```

After installation, execute the following command to be able to run Docker commands without root access. Replace `USER_NAME` with your actual username:

```bash
sudo usermod -aG docker USER_NAME
```

> **Warning:** You need to restart the PC for this change to take effect.

### Verify Installation

Check the installed versions to confirm a successful installation:

```bash
docker version
docker --version
docker compose version
```
