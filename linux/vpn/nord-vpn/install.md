# NordVPN Linux CLI Installation & Usage

Install and control NordVPN on Linux using the official CLI client.

---

## 1. Installation

Run the official NordVPN Linux installer script:

```bash
sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)
```

Add your user to the `nordvpn` system group and reboot:

```bash
sudo usermod -aG nordvpn $(whoami)
sudo reboot
```

---

## 2. Authentication & Settings

```bash
# Log in to account:
nordvpn login

# Enable autoconnect on boot:
nordvpn set autoconnect on

# Disable autoconnect:
nordvpn set autoconnect off
```

---

## 3. Connection Commands

```bash
# Connect to recommended server:
nordvpn connect

# Connect to a specific country (e.g., Germany):
nordvpn connect de

# Disconnect active VPN session:
nordvpn disconnect
```
