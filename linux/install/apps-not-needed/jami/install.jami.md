# Install Jami

Jami is a distributed communication application without a central server.

> **Warning:** This app may cause an issue preventing the screen from going blank.

## Install using APT

Go to the [Jami Linux Download Page](https://jami.net/download-jami-linux/), choose your OS
version, and replace `ubuntu_21.10` in the commands below with your correct OS version.

```bash
sudo apt install gnupg dirmngr ca-certificates curl --no-install-recommends
curl -s https://dl.jami.net/public-key.gpg | sudo tee /usr/share/keyrings/jami-archive-keyring.gpg > /dev/null
sudo sh -c "echo 'deb [signed-by=/usr/share/keyrings/jami-archive-keyring.gpg] https://dl.jami.net/nightly/ubuntu_21.10/ jami main' > /etc/apt/sources.list.d/jami.list"
sudo apt-get update
sudo apt-get install jami
```

## Install using Flatpak

Alternatively, you can install Jami using Flatpak:

```bash
flatpak install flathub net.jami.Jami
```
