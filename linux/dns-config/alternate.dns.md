# Recommended Alternate DNS Servers

A curated list of fast, reliable public DNS resolvers and DNS-over-HTTPS (DoH) endpoints.

To apply these DNS servers:

- In system network settings: Configure the IPv4 and IPv6 DNS fields manually and disable
  **Automatic** DNS.
- In web browsers: Configure secure DNS directly in browser privacy settings.
- In VPN clients: Add them as custom DNS or DoH endpoints.

After updating system DNS settings, disconnect and reconnect your network to apply the changes.

---

## 1. DNS-over-HTTPS (DoH) — Encrypted

> [!TIP]
>
> **Recommended for VPN apps and web browsers.** In regions subject to ISP-level DNS
> manipulation, spoofing, or censorship, raw unencrypted DNS queries on UDP port 53 are
> frequently poisoned. Use DoH over an active VPN tunnel or within your browser to protect
> query privacy.

### Google Public DNS (DoH)

- `https://8.8.8.8/dns-query`
- `https://223.5.5.5/dns-query`
- `https://dns.google/dns-query`

---

## 2. Cisco OpenDNS

> [!NOTE]
>
> **Recommended as a fallback system DNS resolver.**

- **IPv4**:
  - `208.67.222.222`
  - `208.67.220.220`
- **IPv6**:
  - `2620:119:35::35`
  - `2620:119:53::53`

---

## 3. Google Public DNS

> [!NOTE]
>
> **Recommended for permanent system-wide DNS.**

- **IPv4**:
  - `8.8.8.8`
  - `8.8.4.4`
- **IPv6**:
  - `2001:4860:4860::8888`
  - `2001:4860:4860::8844`

---

## 4. Cloudflare DNS

### Standard Anycast Resolvers

- **IPv4**:
  - `1.1.1.1`
  - `1.0.0.1`
- **IPv6**:
  - `2606:4700:4700::1111`
  - `2606:4700:4700::1001`

### Cloudflare Mobile Endpoints

- `one.one.one.one`
- `1dot1dot1dot1.cloudflare-dns.com`
