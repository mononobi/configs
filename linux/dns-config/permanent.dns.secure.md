# Permanent Leak-Free DNS Configuration with `dnsmasq`

This guide provides a comprehensive setup for configuring a permanent, leak-proof local
DNS caching resolver using `dnsmasq`. It eliminates DNS leaks when connected to VPN
tunnels and accelerates browsing via localized response caching.

> [!IMPORTANT]
>
> **Captive Portal / ISP Activation Note**: By following this guide, you may temporarily
> lose access to ISP-specific captive portals or captive web activation pages (e.g.,
> initial network activation URLs provided by an ISP before general internet access is
> established).

---

## Why Replace `systemd-resolved` with `dnsmasq`?

- **Leak Prevention**: `systemd-resolved` frequently bypasses routing tables and firewall
  rules, sending queries directly through the default gateway interface rather than
  through active VPN tunnel interfaces (such as `tun0` or `nekoray-tun`), resulting in
  severe DNS leaks.
- **High-Performance Caching**: `dnsmasq` is a lightweight, low-latency caching resolver
  that speeds up recurring DNS queries.
- **Full Compatibility**: By binding `dnsmasq` to `127.0.0.53:53`, applications expecting
  Ubuntu default resolver address continue to function seamlessly without leaks.

---

## Step 1: Remove Conflicting Packages and Disable `systemd-resolved`

1. Remove `resolvconf` if installed:

   ```bash
   sudo apt remove resolvconf
   ```

2. Stop and disable `systemd-resolved`:

   ```bash
   sudo systemctl stop systemd-resolved
   sudo systemctl disable systemd-resolved
   ```

3. Reboot your system to apply these changes:

   ```bash
   sudo reboot
   ```

   > [!NOTE]
   >
   > Major system updates may re-enable `systemd-resolved`. If this occurs, disable it
   > again. The `pc-update` maintenance script in this repository automates this check.

---

## Step 2: Update Name Service Switch (`/etc/nsswitch.conf`)

Edit `/etc/nsswitch.conf`:

```bash
sudo nano /etc/nsswitch.conf
```

Find the `hosts:` line (or `files` lookup directive). If it contains `resolve` and
`[!UNAVAIL=return]`:

```text
hosts:          files mdns4_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] dns mymachines
```

Remove `resolve` and `[!UNAVAIL=return]` so that it reads:

```text
hosts:          files mdns4_minimal [NOTFOUND=return] dns mymachines
```

Save and exit.

> [!NOTE]
>
> Once `systemd-resolved` is disabled, DNS servers configured via the NetworkManager GUI
> will no longer be utilized.

---

## Step 3: Configure Static `/etc/resolv.conf`

Recreate `/etc/resolv.conf` as a regular file pointing to `dnsmasq` and your upstream
fallbacks:

```bash
# Remove existing file or symlink
sudo rm -f /etc/resolv.conf

# Create new file
sudo touch /etc/resolv.conf
sudo nano /etc/resolv.conf
```

Add your upstream DNS servers. The first entry **must always** be `127.0.0.53`:

```text
nameserver 127.0.0.53
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 2001:4860:4860::8888
nameserver 2001:4860:4860::8844
```

Unlike standard glibc resolvers (which only parse up to 3 entries), `dnsmasq` reads this
file and can utilize an unlimited number of upstream nameservers in order.

---

## Step 4: Install and Configure `dnsmasq`

1. Install `dnsmasq`:

   ```bash
   sudo apt-get install -y dnsmasq
   ```

2. Open `/etc/dnsmasq.conf`:

   ```bash
   sudo nano /etc/dnsmasq.conf
   ```

3. Add the following optimized configuration:
   ```ini
   listen-address=127.0.0.53
   port=53
   cache-size=5000
   max-cache-ttl=3600
   min-cache-ttl=3600
   dns-forward-max=50
   no-ping
   strict-order
   dns-loop-detect
   ```

### Configuration Parameters Explained

- `listen-address=127.0.0.53`: Binds to the standard loopback address on port 53.
- `cache-size=5000`: Sets the cache capacity to 5,000 records (maximum supported is
  10,000).
- `max-cache-ttl=3600` / `min-cache-ttl=3600`: Sets cache time-to-live to 3,600 seconds (1
  hour). In regions with aggressive censorship, spoofing, and ISP throttling, higher TTLs
  minimize repeat lookups and stabilize browsing.
- `dns-forward-max=50`: Restricts concurrent outbound queries to 50 (default is 150) to
  prevent DNS flood detection.
- `strict-order`: Forces `dnsmasq` to query upstream servers strictly in the order they
  appear in `/etc/resolv.conf`.
- `dns-loop-detect`: **Mandatory.** Prevents routing loops where `dnsmasq` inadvertently
  queries itself as an upstream resolver.

4. Enable and start the service:
   ```bash
   sudo systemctl enable dnsmasq
   sudo systemctl start dnsmasq
   sudo systemctl status dnsmasq
   ```

---

## Step 5: Automatic Cache Invalidation on VPN Connect

When connected to a VPN, previously cached (and potentially spoofed or poisoned) responses
must be flushed to prevent connection errors.

### Manual Cache Reset

```bash
sudo systemctl restart dnsmasq
```

_(Alternatively, run `dns-reset`)._

### Automated Flush via `if-up.d`

Automatically flush DNS cache whenever a VPN tunnel (e.g., `tun0`, `nekoray-tun`)
connects:

```bash
sudo cp files/dns-cache /etc/network/if-up.d/
sudo chmod 755 /etc/network/if-up.d/dns-cache
```

---

## Step 6: Verification & Testing

### 1. Test DNS Caching Performance

Execute repeated lookups against a domain. The first query queries the upstream provider,
while subsequent queries resolve in 0ms directly from cache:

```bash
dig google.com
dig facebook.com
dig yahoo.com
dig github.com
```

### 2. Test Cache Reset on VPN Connection

_(Requires the `if-up.d/dns-cache` script installed)_

1. Query a domain without VPN:
   ```bash
   dig amazon.com
   ```
2. Connect your VPN and query again. The latency will be non-zero on the first lookup,
   confirming the cache was flushed upon tunnel creation.

### 3. Test for DNS Leaks with Wireshark

1. Connect to your VPN / proxy.
2. Flush `dnsmasq`:
   ```bash
   sudo systemctl restart dnsmasq
   ```
3. Open Wireshark on your active physical interface (`eth0`, `wlan0`).
4. Set the display filter to:
   ```text
   udp.port == 53
   ```
5. Run query commands:
   ```bash
   curl github.com
   dig yahoo.com
   ping youtube.com
   ```
6. Test Flatpak container resolution (Flatpak can attempt to query `systemd-resolved`
   directly):
   ```bash
   flatpak run --share=network --devel --command=python3 org.freedesktop.Platform/x86_64/21.08 -c 'import socket; print(socket.gethostbyname_ex("google.com"))'
   ```
7. Verify that **no DNS packets leave through your physical network interface**. All
   queries must route through the VPN tunnel.

---

## Step 7: Cache Statistics Monitoring

Query live `dnsmasq` operational metrics:

```bash
dig +short chaos txt cachesize.bind
dig +short chaos txt insertions.bind
dig +short chaos txt hits.bind
dig +short chaos txt misses.bind
dig +short chaos txt evictions.bind
dig +short chaos txt auth.bind
dig +short chaos txt servers.bind
```

### Understanding `servers.bind`

The output reports upstream server queries in the format:

```text
"SERVER_IP#PORT SUCCESS_COUNT FAILED_COUNT"
```

Example:

```text
"127.0.0.53#53 0 0" "8.8.8.8#53 10 1" "8.8.4.4#53 2 0"
```

- Total cache misses correspond to the sum of queries forwarded to upstreams:
  $$	ext{Cache Misses} pprox \sum 	ext{Success Count of Remote Servers}$$ In the example
  above, cache misses = $10 + 2 = 12$.

### Quick CLI Helper

Install the standalone stats inspection script:

```bash
cp files/dns-stats ~/.local/sbin/
```
