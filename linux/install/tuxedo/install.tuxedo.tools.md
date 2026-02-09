## Tuxedo Tools

### Add Tuxedo Repository

```bash
# 1. Add the repo signing key
wget -O - https://deb.tuxedocomputers.com/0x54840598.pub.asc | sudo gpg --dearmor -o /usr/share/keyrings/tuxedo-archive-keyring.gpg

# 2. Add the repo source (For Ubuntu 24.04)
echo "deb [signed-by=/usr/share/keyrings/tuxedo-archive-keyring.gpg arch=amd64] https://deb.tuxedocomputers.com/ubuntu noble main" | sudo tee /etc/apt/sources.list.d/tuxedo-computers.list

# 3. Update
sudo apt update
```

### Install

```bash
sudo apt install tuxedo-tomte tuxedo-control-center
```
