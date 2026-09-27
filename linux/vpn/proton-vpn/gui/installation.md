# ProtonVPN Desktop GUI Client Installation

Instructions for installing the official ProtonVPN graphical desktop client.

---

## 1. Download Package

Download the official Debian installer package from Proton:

- [ProtonVPN Linux Setup](https://protonvpn.com/support/linux-ubuntu-vpn-setup/)

_(If blocked by ISP censorship, a copy of the installer `.deb` is kept in this
repository)._

---

## 2. Install Repository & Application

```bash
# Add ProtonVPN repository package:
sudo dpkg -i <FILE_NAME>.deb

# Update package indices and install desktop client:
sudo apt-get update
sudo apt-get install -y protonvpn
```

Log in with your Proton credentials to establish connections.
