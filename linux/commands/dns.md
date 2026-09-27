# DNS Troubleshooting & Inspection Commands

CLI utilities to inspect active DNS resolvers, query domain records, and audit DNS privacy
features.

## Active DNS Resolvers

Inspect current per-interface and global DNS configuration used by systemd:

```bash
resolvectl status
```

## Query Domain Records

Query specific DNS record types using `nslookup`:

```bash
# Query IPv4 'A' records:
nslookup -type=A SOME.DOMAIN

# Query IPv6 'AAAA' records:
nslookup -type=AAAA SOME.DOMAIN
```

## Verify QNAME Minimisation

Verify whether your upstream DNS resolver has QNAME minimisation enabled (preventing
intermediate root/TLD servers from learning full target domain names):

```bash
dig +short txt qnamemintest.internet.nl
```
