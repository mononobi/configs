# NekoRay Desktop VMess Client Setup (Linux & Windows)

Step-by-step setup guide for configuring NekoRay (V2Ray / Xray GUI) for anti-censorship VMess
proxy connections.

---

## 1. Download & Installation

1. Download the latest release from GitHub:
   - [NekoRay Releases](https://github.com/MatsuriDayo/nekoray/releases) _(For Linux, the
     standalone `.zip` archive is recommended)._
2. Extract the archive and launch the `nekoray` executable.

---

## 2. Client Application Preferences

Open **Preferences** in NekoRay and configure the following panels:

### Preferences -> Routing Settings

- **Sniffing Mode**: `The sniffing result is used for routing`
- **Outbound Domain Strategy**: `UseIPv4`
- **Remote DNS**: `8.8.8.8`
- **Direct DNS**: `208.67.222.222`
- **Enable DNS Routing**: `Off`
- **Domain Strategy**: `AsIs`

#### Custom Global Routing JSON

Click **Custom (global)**, paste the following routing rules, click **Format JSON**, and save:

```json
{
  "rules": [
    {
      "ip": ["geoip:ir", "192.168.0.0/16", "172.16.0.0/12", "10.0.0.0/8"],
      "outboundTag": "direct",
      "type": "field"
    },
    {
      "network": "tcp,udp",
      "outboundTag": "proxy",
      "type": "field"
    }
  ]
}
```

### Preferences -> VPN Settings

- **Strict Route**: `On`
- **Hide Console**: `On` _(Windows only)_

### Preferences -> Basic Settings -> Common

- **HTTP Listen Port Enable**: `On`
- **Test URL**: `https://www.google.com`
- **Concurrent**: `1`
- **Loglevel**: `none`

_(Alternatively, copy pre-configured group settings from `desktop/files/configs/nekoray.json`
into `<APP_DIR>/config/groups`)._

---

## 3. Creating Server Profiles

1. In the top menu, select **Server** -> **New Profile**.
2. Configure connection parameters:
   - **Type**: `VMess`
   - **Name**: Identifiable profile name
   - **Address**: `INTERNAL` or `EXTERNAL` server IP
   - **Port**: `80` _(or configured port)_
   - **UUID**: User UUID configured on the server
   - **Security**: `chacha20-poly1305`
   - **Network**: `ws` (WebSocket)
   - **Path**: `/graphql`
3. Save the profile.

---

## 4. Connection Modes: VPN Mode vs. System Proxy

Right-click your profile and select **Start**. Then toggle your operating mode:

- **VPN Mode (Recommended)**: Tunnels all operating system traffic automatically through
  virtual network adapter (`tun`) with zero configuration per application.
- **System Proxy**: Sets HTTP/SOCKS proxy variables. Applications ignoring system proxy
  settings will bypass the tunnel.
  - _Proxy Bypass List_: Add
    `localhost, 127.0.0.0/8, ::1, 192.168.0.0/16, 172.16.0.0/12, 10.0.0.0/8` to **Ignore
    Hosts** in system network settings.

---

## 5. Linux Desktop Integration & Icon Setup

```bash
# 1. Close application and move to hidden home directory
mv nekoray ~/.nekoray

# 2. Update Exec and Icon paths in desktop file to match your username
nano nekoray.desktop

# 3. Copy to application launchers
cp nekoray.desktop ~/.local/share/applications/

# 4. Refresh GNOME Shell (X11: Alt + F2, type r, enter)
```

---

## 6. Linux DNS Leak Troubleshooting

> [!CAUTION]
>
> On Linux, `systemd-resolved` often bypasses routing tables, sending DNS queries directly to
> the physical gateway instead of the `nekoray-tun` interface.

### Recommended Remedy

Configure static, leak-free DNS using `dnsmasq` as documented in
[permanent.dns.secure.md](file:///home/mono/Workspace/configs/linux/dns-config/permanent.dns.secure.md):

```text
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 2001:4860:4860::8888
nameserver 2001:4860:4860::8844
```

### Alternative Remedy

Configure DNS-over-HTTPS (DoH) within your web browser settings pointing to
`https://8.8.8.8/dns-query`.
