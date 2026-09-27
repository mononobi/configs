# Windscribe Linux Client Installation

Install the official Windscribe VPN desktop client on Debian/Ubuntu.

---

## 1. Download Package

Download the `.deb` package from the official guide:

- [Windscribe Linux Guide](https://windscribe.com/guides/linux)

_(If blocked by regional firewalls, an installer package is mirrored in this repository)._

---

## 2. Installation

```bash
sudo dpkg -i <FILE_NAME>.deb
```

Resolve any missing dependencies if prompted:

```bash
sudo apt-get install -f
```

Launch Windscribe and sign in to connect.
