# Permanent DNS Configuration via `resolvconf`

This guide explains how to set permanent DNS servers using `resolvconf`.

> [!WARNING] This method **does not prevent DNS leaks when connected to a VPN**. If you
> require complete protection against DNS leaks and query spoofing, refer to
> [permanent.dns.secure.md](file:///home/mono/Workspace/configs/linux/dns-config/permanent.dns.secure.md)
> instead.

---

## Installation & Setup

1. **Install and Enable `resolvconf`**:

   ```bash
   sudo apt update
   sudo apt install -y resolvconf

   sudo systemctl start resolvconf.service
   sudo systemctl enable resolvconf.service
   sudo systemctl status resolvconf.service
   ```

2. **Configure Custom DNS Servers**: Open the `/etc/resolvconf/resolv.conf.d/head` file:

   ```bash
   sudo nano /etc/resolvconf/resolv.conf.d/head
   ```

   Add your desired nameservers to the file:

   ```text
   nameserver IPv4-1
   nameserver IPv4-2
   nameserver IPv6
   ```

   > [!NOTE] `resolvconf` supports a maximum of 3 nameserver entries. Any additional
   > entries beyond the third will be ignored.

3. **Restart the Service**:

   ```bash
   sudo systemctl restart resolvconf.service
   ```

4. **Update and Lock `resolv.conf`**:

   ```bash
   sudo resolvconf --enable-updates
   sudo resolvconf -u
   ```

5. **Verify Configuration**: Verify that your configured nameservers appear at the top of
   `/etc/resolv.conf`:
   ```bash
   sudo cat /etc/resolv.conf
   ```
