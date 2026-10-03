# IP Address & Network Diagnostics Cheat Sheet

Commands for inspecting local network interfaces, public IP addresses, routing gateways, and
DNS resolvers.

---

## Network Interface Addresses

```bash
# Show all local and global IPv4 addresses:
ip -4 addr

# Show only global (non-loopback) IPv4 addresses:
ip -4 addr show scope global

# Show all local and global IPv6 addresses:
ip -6 addr

# Show only global IPv6 addresses:
ip -6 addr show scope global
```

---

## Domain Resolution & Gateways

### Domain Resolution via `nslookup`

```bash
nslookup <DOMAIN>
# Example:
nslookup google.com
```

### View Default Gateway and Subnet Routes

```bash
ip r
# or
ip route
```

#### Example Output:

```text
default via 185.248.110.1 dev eth0 onlink
185.248.110.0/24 dev eth0 proto kernel scope link src 185.248.110.166
```

- Line 1 identifies the default gateway (`185.248.110.1`) on interface `eth0`.
- Line 2 identifies the assigned subnet route (`185.248.110.0/24`) and source IP
  (`185.248.110.166`).

---

## Query Public IP Address

Check your current external public IP (reflecting VPN/proxy egress when connected):

```bash
curl ifconfig.co
curl checkip.amazonaws.com
curl ifconfig.me
curl icanhazip.com
curl ipecho.net/plain
```

---

## Query Domain via Specific Nameserver

Resolve a domain using an explicit DNS server:

```bash
dig @<DNS_RESOLVER_IP> <DOMAIN>

# Example using Google Public DNS:
dig @8.8.8.8 google.com
```
