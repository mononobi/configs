# UFW (Uncomplicated Firewall) Guide & Recommended Rules

Essential management commands and recommended firewall rule templates for local workstations
and production servers.

---

## Basic Firewall Management

| Action                      | Command                         |
| :-------------------------- | :------------------------------ |
| **Check Firewall Status**   | `sudo ufw status`               |
| **Disable Firewall**        | `sudo ufw disable`              |
| **Enable Firewall**         | `sudo ufw enable`               |
| **List Rules with Numbers** | `sudo ufw status numbered`      |
| **Delete Rule by Number**   | `sudo ufw delete <RULE_NUMBER>` |

### Allow / Deny by IP or Subnet

```bash
# Deny outgoing traffic to specific IP or subnet:
sudo ufw deny out from any to <IP_OR_SUBNET>

# Deny incoming traffic from specific IP or subnet:
sudo ufw deny from <IP_OR_SUBNET>

# Allow incoming traffic from specific IP or subnet:
sudo ufw allow from <IP_OR_SUBNET>
```

---

## Recommended Rules for Local Workstations

### 1. Default Policies

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

### 2. Allow Local and Private Networks

```bash
# Allow incoming from local network (LAN):
sudo ufw allow from 192.168.0.0/16

# Allow incoming from private subnets (Docker containers, VPN tunnels, etc.):
# Note: The private class B range spans 172.16.0.0 through 172.31.255.255, encapsulated by /12
sudo ufw allow from 172.16.0.0/12

# Allow incoming from Class A private subnet (tunnels, WireGuard):
sudo ufw allow from 10.0.0.0/8
```

### 3. Block Known ISP DNS Interceptors & Telemetry

```bash
# Block outgoing traffic to AsiaTech DNS servers:
sudo ufw deny out from any to 2a06:5484::113
sudo ufw deny out from any to 2a06:5484::114

# Block outgoing connections to Microsoft NCSI connectivity check (www.msftncsi.com):
sudo ufw deny out from any to 2.16.106.91
sudo ufw deny out from any to 2.16.106.89
sudo ufw deny out from any to 2.16.238.150
sudo ufw deny out from any to 2.16.238.132

# Block outgoing connections to GitHub status check (alive.github.com):
sudo ufw deny out from any to 140.82.112.25
sudo ufw deny out from any to 140.82.112.26
sudo ufw deny out from any to 140.82.113.25
sudo ufw deny out from any to 140.82.113.26
sudo ufw deny out from any to 140.82.114.25
sudo ufw deny out from any to 140.82.114.26
```

---

## Recommended Rules for Servers

```bash
# Default policies:
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow incoming SSH connection:
sudo ufw allow 22

# Allow incoming Web ports (HTTP & HTTPS):
sudo ufw allow 80
sudo ufw allow 443

# Allow incoming OpenVPN default ports:
sudo ufw allow 443/tcp
sudo ufw allow 1194/udp
```
