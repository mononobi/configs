# VMess Mobile Client Setup (Android & iOS)

Configure mobile VMess / Shadowsocks clients to connect to your intermediate proxy server.

---

## Recommended Applications

- **Android**:
  [Matsuri Lite on Google Play](https://play.google.com/store/apps/details?id=moe.matsuri.lite&hl=en&gl=US&pli=1)
- **iOS**:
  [Shadowlink VPN on App Store](https://apps.apple.com/us/app/shadowlink-shadowsocks-vpn/id1439686518)

---

## Importing Profiles

1. In your desktop client (e.g., NekoRay), right-click the target profile and select **Share**
   -> **QR Code and Link**.
2. In the mobile app, tap **Add / Import** and scan the QR code.

---

## Recommended App Settings

| Setting                        | Value            |
| :----------------------------- | :--------------- |
| **Remote DNS**                 | `8.8.8.8`        |
| **Direct DNS**                 | `208.67.222.222` |
| **Enable DNS Routing**         | `Off`            |
| **Show Direct Speed**          | `On`             |
| **Always Show Address**        | `On`             |
| **Domain Resolution Strategy** | `AsIs`           |
| **Bypass LAN**                 | `On`             |
| **Enable Traffic Sniffing**    | `On`             |

---

## Routing Rules

To ensure domestic/regional traffic bypasses the proxy and routes directly:

1. Edit the rule template (e.g., _IP rule for China_):
   - **Route Name**: `IP rule for Iran`
   - **IP Target**: `geoip:ir`
   - **Outbound**: `Bypass` (Direct)
2. Save and enable the rule in your active routing list.
