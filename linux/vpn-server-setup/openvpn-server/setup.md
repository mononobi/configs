# Production OpenVPN Server Setup Guide (Ubuntu/Debian)

A comprehensive guide for building a hardened, enterprise-grade OpenVPN server using Easy-RSA
v3, PKI certificate authorities, elliptic-curve or RSA cryptography, TLS-Crypt authentication,
UFW NAT forwarding, multi-protocol serving (UDP & TCP), and multi-IP policy routing.

---

## 1. Prerequisites & Initial Firewall Setup

All actions must be run as a non-root sudoer user.

```bash
# Add user to sudoers group (if not already done)
sudo adduser user_name sudo

# Install and configure UFW firewall
sudo apt-get update
sudo apt-get install -y ufw

# Allow SSH and enable firewall
sudo ufw allow OpenSSH
sudo ufw enable
sudo ufw status
```

---

## 2. Install OpenVPN and Easy-RSA

```bash
sudo apt update
sudo apt install -y openvpn easy-rsa
```

### Setup Easy-RSA Environment

```bash
# Create easy-rsa directory in user home
mkdir ~/easy-rsa

# Symlink Easy-RSA scripts into working directory
ln -s /usr/share/easy-rsa/* ~/easy-rsa/

# Restrict permissions strictly to your user
sudo chown -R $(whoami):$(whoami) ~/easy-rsa
chmod 700 ~/easy-rsa
```

### Configure Easy-RSA Variables (`vars`)

```bash
cd ~/easy-rsa
touch vars
nano vars
```

Add your organizational information and cryptographic parameters:

```bash
# CA and Certificate Lifespans (in days)
set_var EASYRSA_CA_EXPIRE      20000
set_var EASYRSA_CERT_EXPIRE    10000

# Organizational Identity
set_var EASYRSA_REQ_COUNTRY    "DE"
set_var EASYRSA_REQ_PROVINCE   "Hamburg"
set_var EASYRSA_REQ_CITY       "Hamburg"
set_var EASYRSA_REQ_ORG        "Private"
set_var EASYRSA_REQ_EMAIL      "your_email@domain.com"
set_var EASYRSA_REQ_OU         "Community"

# Cryptographic Algorithm and Digest (Do not alter)
set_var EASYRSA_ALGO           "ec"
set_var EASYRSA_DIGEST         "sha512"
```

---

## 3. Initialize PKI & Build Certificate Authority (CA)

```bash
cd ~/easy-rsa
./easyrsa init-pki
```

Build the root CA certificate. Choose a strong passphrase and set an identifiable Common Name
(referenced as `vpn-server-ca` in this guide):

```bash
./easyrsa build-ca
```

### Secure and Backup the CA Keys

1. **Download public and private keys to your secure local machine**:
   ```bash
   # Run on your local machine:
   scp remote_user@server_ip:/home/remote_user/easy-rsa/pki/ca.crt /home/local_user/ca.crt
   scp remote_user@server_ip:/home/remote_user/easy-rsa/pki/private/ca.key /home/local_user/ca.key
   ```
2. **Install public CA certificate into the server's trusted store**:
   ```bash
   # Run on the server:
   cp ~/easy-rsa/pki/ca.crt /tmp/ca.crt
   sudo cp /tmp/ca.crt /usr/local/share/ca-certificates/
   sudo update-ca-certificates
   ```

---

## 4. Generate Server Certificate & TLS Crypt Key

```bash
cd ~/easy-rsa

# Generate server certificate signing request without a password
./easyrsa gen-req vpn-server-ca nopass

# Copy private key to OpenVPN server directory
sudo cp ~/easy-rsa/pki/private/vpn-server-ca.key /etc/openvpn/server/

# (Optional: Only if CA and OpenVPN servers are physically separated)
# ./easyrsa import-req ~/easy-rsa/pki/reqs/vpn-server-ca.req vpn-server-ca

# Sign the server certificate using the CA passphrase
./easyrsa sign-req server vpn-server-ca

# Deploy public certificates to OpenVPN
sudo cp ~/easy-rsa/pki/issued/vpn-server-ca.crt /etc/openvpn/server/
sudo cp ~/easy-rsa/pki/ca.crt /etc/openvpn/server/

# Generate TLS-Crypt pre-shared key for packet obfuscation and DoS protection
openvpn --genkey secret ta.key
sudo cp ta.key /etc/openvpn/server/
```

---

## 5. Client Key & Certificate Generation

Prepare a directory for client keys and profiles:

```bash
mkdir -p ~/client-configs/keys
chmod -R 700 ~/client-configs
```

> [!NOTE]
>
> Repeat the following key generation block for each client (replacing `client1` with your
> desired client identifier):

```bash
cd ~/easy-rsa

# Generate client private key and request without passphrase
./easyrsa gen-req client1 nopass
cp ~/easy-rsa/pki/private/client1.key ~/client-configs/keys/

# (Optional: Only if CA server is separated)
# ./easyrsa import-req ~/easy-rsa/pki/reqs/client1.req client1

# Sign certificate with CA passphrase
./easyrsa sign-req client client1

# Copy issued certificate
cp ~/easy-rsa/pki/issued/client1.crt ~/client-configs/keys/
```

---

## 6. Configure OpenVPN Server (`server.udp.conf`)

Copy the sample configuration:

```bash
sudo cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf /etc/openvpn/server/server.udp.conf
sudo nano /etc/openvpn/server/server.udp.conf
```

Apply the following modifications to `/etc/openvpn/server/server.udp.conf`:

```ini
# Subnet topology
topology subnet

# HMAC hardening via TLS-Crypt
;tls-auth ta.key 0
tls-crypt ta.key

# Cryptographic ciphers
;cipher AES-256-CBC
cipher AES-256-GCM
auth SHA256

# Diffie-Hellman parameters (none required when using EC)
;dh dh2048.pem
dh none

# Privileged process drop
user nobody
group nogroup

# Redirect all client internet traffic through the VPN
push "redirect-gateway def1 bypass-dhcp"

# Push fallback DNS resolvers (OpenDNS)
push "dhcp-option DNS 208.67.222.222"
push "dhcp-option DNS 208.67.220.220"

# Port and protocol (UDP default)
port 1194
proto udp
explicit-exit-notify 1

# Match certificate and key filenames
cert vpn-server-ca.crt
key vpn-server-ca.key
```

---

## 7. Kernel Packet Forwarding & UFW NAT Routing

Enable IP packet forwarding:

```bash
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
echo "net.netfilter.nf_conntrack_tcp_be_liberal=1" | sudo tee -a /etc/sysctl.conf

# If using IPv6:
echo "net.ipv6.conf.all.forwarding=1" | sudo tee -a /etc/sysctl.conf

# Reload sysctl settings
sudo sysctl -p
```

### Identify Outbound Public Network Interface

```bash
ip route list default
```

_(Note the interface name, e.g., `eth0`, `ens3`, or `enp3s0`)._

### Configure UFW NAT Masquerading (`/etc/ufw/before.rules`)

```bash
sudo nano /etc/ufw/before.rules
```

Add the following NAT block at the very top of the file, before the `*filter` line (replace
`eth0` with your actual network interface):

```text
# START OPENVPN RULES
# NAT table rules
*nat
:POSTROUTING ACCEPT [0:0]
# Allow traffic from OpenVPN client subnet to public interface
-A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
COMMIT
# END OPENVPN RULES
```

### Configure Forward Policy & Firewall Rules

Edit `/etc/default/ufw`:

```bash
sudo nano /etc/default/ufw
```

Set:

```text
DEFAULT_FORWARD_POLICY="ACCEPT"
```

Open OpenVPN UDP port and reload UFW:

```bash
sudo ufw allow 1194/udp
sudo ufw allow OpenSSH

sudo ufw disable
sudo ufw enable
```

### Start OpenVPN UDP Daemon

```bash
sudo systemctl -f enable openvpn-server@server.udp.service
sudo systemctl start openvpn-server@server.udp.service
sudo systemctl status openvpn-server@server.udp.service
```

---

## 8. Client Configuration Generation Automation

Create a base client configuration template:

```bash
mkdir -p ~/client-configs/files
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf ~/client-configs/base.conf
nano ~/client-configs/base.conf
```

Update `/client-configs/base.conf`:

```ini
remote <SERVER_PUBLIC_IP> 1194
proto udp

user nobody
group nogroup

# Comment out external certificate paths
;ca ca.crt
;cert client.crt
;key client.key
;tls-auth ta.key 1

# Mirror cryptographic ciphers
cipher AES-256-GCM
auth SHA256

key-direction 1

# DNS update helper scripts for Linux clients
# For non-systemd-resolved systems:
; script-security 2
; up /etc/openvpn/update-resolv-conf
; down /etc/openvpn/update-resolv-conf

# For systemd-resolved systems:
; script-security 2
; up /etc/openvpn/update-systemd-resolved
; down /etc/openvpn/update-systemd-resolved
; down-pre
; dhcp-option DOMAIN-ROUTE .
```

### Automated Profile Assembly Script (`make_config.sh`)

Create `~/client-configs/make_config.sh`:

```bash
nano ~/client-configs/make_config.sh
```

Paste the following script:

```bash
#!/bin/bash

# First argument: Client identifier

EASYRSA_DIR=~/easy-rsa
CA_DIR=~/easy-rsa/pki
KEY_DIR=~/client-configs/keys
OUTPUT_DIR=~/client-configs/files
BASE_CONFIG=~/client-configs/base.conf

cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${CA_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${KEY_DIR}/${1}.crt \
    <(echo -e '</cert>\n<key>') \
    ${KEY_DIR}/${1}.key \
    <(echo -e '</key>\n<tls-crypt>') \
    ${EASYRSA_DIR}/ta.key \
    <(echo -e '</tls-crypt>') \
    > ${OUTPUT_DIR}/${1}.ovpn
```

Make it executable and assemble `client1.ovpn`:

```bash
chmod 700 ~/client-configs/make_config.sh
cd ~/client-configs
./make_config.sh client1
```

Copy the `.ovpn` file to your client machine:

```bash
scp remote_user@server_ip:~/client-configs/files/client1.ovpn /home/local_user/
```

---

## 9. Client DNS Resolution Configuration (Linux)

Inspect the DNS resolution system used on the client machine:

```bash
cat /etc/resolv.conf
```

### If `nameserver 127.0.0.53` is present (`systemd-resolved`):

Install the helper and uncomment the `systemd-resolved` section inside `client1.ovpn`:

```bash
sudo apt install -y openvpn-systemd-resolved
```

In `client1.ovpn`:

```text
script-security 2
up /etc/openvpn/update-systemd-resolved
down /etc/openvpn/update-systemd-resolved
down-pre
dhcp-option DOMAIN-ROUTE .
```

### If `update-resolv-conf` exists (`/etc/openvpn/update-resolv-conf`):

In `client1.ovpn`:

```text
script-security 2
up /etc/openvpn/update-resolv-conf
down /etc/openvpn/update-resolv-conf
```

---

## 10. Multi-Protocol: Serving OpenVPN on Both UDP and TCP

Running OpenVPN on TCP port 443 allows clients to bypass strict firewalls that block standard
UDP ports.

### Configure TCP Instance (`server.tcp.conf`)

```bash
cd /etc/openvpn/server
sudo cp server.udp.conf server.tcp.conf
sudo nano server.tcp.conf
```

Update parameters:

```ini
port 443
proto tcp
server 10.8.1.0 255.255.255.0
explicit-exit-notify 0

# (Optional: Prevent IPv6 leakage if server possesses IPv6 addresses)
# server-ipv6 AAAA:BBBB:CCCC:0124:0000:0000:0000:0000/64
```

### Configure TCP NAT Routing & Firewall

In `/etc/ufw/before.rules`, append the TCP subnet under `*nat`:

```text
-A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
-A POSTROUTING -s 10.8.1.0/24 -o eth0 -j MASQUERADE
```

Open port and reload:

```bash
sudo ufw allow 443/tcp
sudo ufw disable && sudo ufw enable
```

### Start TCP Daemon

```bash
sudo systemctl -f enable openvpn-server@server.tcp.service
sudo systemctl start openvpn-server@server.tcp.service
```

### Configure TCP Client Generation

```bash
cd ~/client-configs
cp base.conf base.tcp.conf
nano base.tcp.conf
```

Update `proto tcp` and `remote <server_ip> 443`.

Create TCP config generator:

```bash
cp make_config.sh make_config_tcp.sh
nano make_config_tcp.sh
```

Update `BASE_CONFIG=~/client-configs/base.tcp.conf` and output filename to
`${OUTPUT_DIR}/${1}.tcp.ovpn`.

### Unified Client Provisioning Script (`make_client.sh`)

Create `~/client-configs/make_client.sh`:

```bash
nano ~/client-configs/make_client.sh
chmod 700 ~/client-configs/make_client.sh
```

```bash
#!/bin/bash
# First argument: Client identifier

cd ~/easy-rsa
./easyrsa gen-req ${1} nopass
cp ~/easy-rsa/pki/private/${1}.key ~/client-configs/keys/
./easyrsa sign-req client ${1}
cp ~/easy-rsa/pki/issued/${1}.crt ~/client-configs/keys/

cd ~/client-configs/
./make_config.sh ${1}
./make_config_tcp.sh ${1}
```

Generate both UDP and TCP profiles with one command:

```bash
./make_client.sh client_name
```

---

## 11. Offline CA Hardening (Recommended)

Once all initial client profiles are generated, back up `ca.key` to an encrypted, offline local
storage drive and remove it from the server:

```bash
# Run on local machine:
scp remote_user@server_ip:~/easy-rsa/pki/private/ca.key /safe/local/storage/ca.key

# Run on server:
rm -f ~/easy-rsa/pki/private/ca.key
```

Whenever you need to sign a new client certificate in the future, copy `ca.key` back to
`~/easy-rsa/pki/private/`, sign the certificate, and delete it from the server again.

---

## 12. Advanced: Multi-IP Server Policy Routing & SNAT

If your server has multiple public IPv4 addresses (`IP1` and `IP2`) and you want different VPN
subnets to exit through specific external IPs:

### Define Separate Subnets per Server Instance

- `server.udp.conf` (`10.8.0.0/24` on port `1194/udp` -> Exit via `IP1`)
- `server.tcp.conf` (`10.8.1.0/24` on port `443/tcp` -> Exit via `IP1`)
- `server.udp2.conf` (`10.8.2.0/24` on port `1195/udp` -> Exit via `IP2`)
- `server.tcp2.conf` (`10.8.3.0/24` on port `444/tcp` -> Exit via `IP2`)

### Configure SNAT in `/etc/ufw/before.rules`

Replace generic `MASQUERADE` with explicit `SNAT` rules pointing to target outbound public IPs:

```text
# NAT table rules
*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s 10.8.0.0/24 -o eth0 -j SNAT --to-source <IP1>
-A POSTROUTING -s 10.8.1.0/24 -o eth0 -j SNAT --to-source <IP1>
-A POSTROUTING -s 10.8.2.0/24 -o eth0 -j SNAT --to-source <IP2>
-A POSTROUTING -s 10.8.3.0/24 -o eth0 -j SNAT --to-source <IP2>
COMMIT
```

Flush old NAT table and reload UFW:

```bash
sudo iptables -t nat -F POSTROUTING
sudo ufw allow 1195/udp
sudo ufw allow 444/tcp
sudo ufw disable && sudo ufw enable
```

Verify active NAT rules:

```bash
sudo iptables-save -t nat
```

---

## 13. Service Verification & Diagnostics

Verify listening ports across protocols:

```bash
sudo netstat -lpan | grep -E ':(1194|443|1195|444)'
```
