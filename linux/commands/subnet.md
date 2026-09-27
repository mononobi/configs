# IPv4 & IPv6 Subnetting Reference Guide

A comprehensive quick-reference for network subnet masks, CIDR prefix notation, and
private IP addressing ranges.

---

## IPv4 Subnetting (CIDR)

An IPv4 address consists of 32 bits divided into four 8-bit octets. The prefix `/N`
indicates the number of static (network) bits counted from left to right.

### Example: `192.168.1.0/24`

- Covers addresses from `192.168.1.0` through `192.168.1.255` (256 IP addresses total).
- The first 24 bits (three octets) remain constant.

### Common Prefix Notation

| Subnet            | Range Description           | Address Span                                     |
| :---------------- | :-------------------------- | :----------------------------------------------- |
| `192.0.0.0/8`     | First octet constant        | `192.0.0.0` – `192.255.255.255` (16,777,216 IPs) |
| `192.168.0.0/16`  | First two octets constant   | `192.168.0.0` – `192.168.255.255` (65,536 IPs)   |
| `192.168.1.0/24`  | First three octets constant | `192.168.1.0` – `192.168.1.255` (256 IPs)        |
| `192.168.1.10/32` | All 32 bits constant        | Exactly one IP (`192.168.1.10`)                  |

---

## IPv6 Subnetting (CIDR)

An IPv6 address consists of 128 bits divided into eight 16-bit hexadecimal blocks. The
prefix `/N` specifies how many bits are constant from left to right.

_(The following addresses are illustrative examples)_

- `AAAA:BBBB:CCCC:0126:0000:0000:0000:0000/64` Spans
  `AAAA:BBBB:CCCC:0126:0000:0000:0000:0000` through
  `AAAA:BBBB:CCCC:0126:FFFF:FFFF:FFFF:FFFF`

### Common IPv6 CIDR Blocks

| Subnet Prefix | Constant Segments         | Scope                                |
| :------------ | :------------------------ | :----------------------------------- |
| `/16`         | 1st block constant        | Wide ISP / Global allocation         |
| `/32`         | 1st & 2nd blocks constant | RIR to LIR / ISP allocation          |
| `/48`         | Blocks 1–3 constant       | Standard enterprise / site prefix    |
| `/64`         | Blocks 1–4 constant       | Standard single subnet / LAN segment |
| `/80`         | Blocks 1–5 constant       | Sub-delegation                       |
| `/96`         | Blocks 1–6 constant       | IPv4-mapped IPv6 translation         |
| `/112`        | Blocks 1–7 constant       | Point-to-point / small link          |
| `/128`        | All 128 bits constant     | Single host address                  |

---

## Private IPv4 Ranges (RFC 1918) & Localhost

These addresses are reserved for private internal networks and are non-routable on the
public internet:

- **`192.168.0.0/16`** (LAN / Home Networks) Spans `192.168.0.0` through
  `192.168.255.255`.
- **`172.16.0.0/12`** (Private Networks, Docker bridges, VPN tunnels) Spans `172.16.0.0`
  through `172.31.255.255`.
- **`10.0.0.0/8`** (Enterprise Private Networks, WireGuard/OpenVPN tunnels) Spans
  `10.0.0.0` through `10.255.255.255`.
- **`127.0.0.0/8`** (Loopback / Localhost) Spans `127.0.0.0` through `127.255.255.255`.
  Each system or container maintains its own isolated loopback interface; localhost in a
  host system is not automatically reachable from inside a container unless sharing
  network namespaces.

---

## System Proxy Bypass Configuration

When configuring a system-wide HTTP/SOCKS proxy, include the following list in the
**Ignore Hosts** (No Proxy) setting to ensure local, container, and private resources
remain accessible directly without routing through the proxy:

```text
localhost, 127.0.0.0/8, ::1, 192.168.0.0/16, 172.16.0.0/12, 10.0.0.0/8
```
