## Ubuntu Connectivity Check

By default, Ubuntu's NetworkManager periodically tries to ping a specific Canonical server 
(usually http://connectivity-check.ubuntu.com./). It expects a specific, blank "204 No Content" 
response back.

If it doesn't get that exact response—either because Canonical's server is temporarily down, 
there's a DNS routing glitch with your ISP, or the request timed out—GNOME assumes 
you are stuck behind a public Wi-Fi login screen (like at a hotel or airport) and prompts 
you to "Sign into network."

To prevent false prompts, you can use a more reliable ping URL which relies on the response 
body rather than the exact status code.

### Reliable Ping URLs

- **Arch Linux:** http://ping.archlinux.org/nm-check.txt

### Configuring The URL

Open (or create) the NetworkManager connectivity override file:

```bash
sudo nano /etc/NetworkManager/conf.d/20-connectivity.conf
```

Paste the following configuration into the file:

```ini
[connectivity]
uri=http://ping.archlinux.org/nm-check.txt
response=NetworkManager is online
interval=300
```

Save the file and restart the NetworkManager:

```bash
sudo systemctl restart NetworkManager
```

### Default Ubuntu Configuration

If you want to see Ubuntu's original configuration file, you can read it in the terminal 
using this command:

```bash
cat /usr/lib/NetworkManager/conf.d/20-connectivity-ubuntu.conf
```

> **Note:** Never edit this specific file directly, as Ubuntu updates will just overwrite the 
> changes. That is why creating an override file in /etc/NetworkManager/conf.d/, like we 
> discussed, is the correct way to change the configuration.

### Confirm The Change

Check the "Effective" Configuration:

```bash
NetworkManager --print-config | grep -A 5 '\[connectivity\]'
```

Check the NetworkManager Logs:

```bash
journalctl -u NetworkManager --since "1 hour ago" | grep -i connectivity
```

Test the Ping Manually:

```bash
curl -I http://ping.archlinux.org/nm-check.txt
```
