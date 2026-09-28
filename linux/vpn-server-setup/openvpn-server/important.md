# OpenVPN Profile Cross-Platform Adjustments & SOCKS Proxy

Important configuration modifications for `.ovpn` client profiles when running across
Linux and non-Linux operating systems.

---

## 1. Cross-Platform DNS Directives

When exporting an OpenVPN client profile generated on Linux to non-Linux operating systems
(Windows, macOS, Android, iOS), comment out Linux-specific resolver helper scripts:

### Standard Linux DNS Helper (`resolvconf`)

```text
; up /etc/openvpn/update-resolv-conf
; down /etc/openvpn/update-resolv-conf
```

### Systemd-Resolved Helper

```text
; up /etc/openvpn/update-systemd-resolved
; down /etc/openvpn/update-systemd-resolved
; down-pre
; dhcp-option DOMAIN-ROUTE .
```

> [!NOTE]
>
> On Linux clients, ensure **one** of the above pairs remains uncommented (typically the
> first pair) so DNS servers pushed by the server are bound to the tunnel interface.

---

## 2. Chaining OpenVPN over SOCKS5 Proxy

To tunnel OpenVPN traffic through an intermediate SOCKS5 proxy (e.g., local proxy or SSH
tunnel):

Add the `socks-proxy` directive inside the `.ovpn` profile:

```text
socks-proxy <PROXY_IP> <PROXY_PORT>
```

### Example (Local SOCKS5 Proxy)

```text
socks-proxy 127.0.0.1 1080
```
