# Complete OpenVPN Access Server Docker Guide

This guide provides everything you need to deploy a secure OpenVPN Access Server using Docker 
and Docker Compose.

## 1. Docker Compose File

First, create a file named `docker-compose.yml` on your server and paste the 
[**docker compose file**](./files/docker-compose.yml) content into it. This file defines 
the OpenVPN service, its network ports, and the volume for persistent configuration.

## 2. Setup and Deployment Guide 🚀

Follow these steps to configure and launch your VPN server.

### Step 1: Create a Configuration Directory

On your host machine (the server where you are running Docker), create a dedicated directory 
to store the server's configuration files. This ensures your settings and user data persist 
even if the container is removed and recreated.

```bash
mkdir -p /opt/openvpn-as/config
```

### Step 2: Set The Required Configs On The Host Machine

On your host machine, you need to set up some system configurations to ensure the OpenVPN 
server can function correctly. This includes enabling IP forwarding and adjusting connection 
tracking settings.

```bash
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
echo "net.netfilter.nf_conntrack_tcp_be_liberal=1" | sudo tee -a /etc/sysctl.conf
```

> **Note:** Only execute this if the host machine also has an IPv6 
> interface (either local or public).

```bash
echo "net.ipv6.conf.all.forwarding=1" | sudo tee -a /etc/sysctl.conf
```

### Step 3: Add Firewall Rules

If you are using a firewall (like `ufw` or `iptables`), you need to allow traffic on the 
OpenVPN ports and ensure that the server can communicate with clients. The following ports
and IP ranges should be allowed:

- **OpenSSH**: For SSH access to the server
- **TCP 443**: For OpenVPN connections
- **UDP 1194**: For OpenVPN connections
- **TCP 943**: For the Admin Web UI
- **TCP 9443**: For the Client Web UI
- **172.16.0.0/12**: For docker network to access the host network
- **10.0.0.0/8**: For private networks to access the host network (e.g., tun interface)

For `ufw`, you can run the following commands:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH
sudo ufw allow 443/tcp
sudo ufw allow 1194/udp
sudo ufw allow 943/tcp
sudo ufw allow 9443/tcp
sudo ufw allow from 172.16.0.0/12
sudo ufw allow from 10.0.0.0/8
```

> **Note:** Restart the firewall after making changes to apply them.

```bash
sudo ufw reload
```

### Step 4: Run the Server

Navigate to the directory that contains your `docker-compose.yml` file and start the server 
in detached mode (`-d`).

```bash
docker-compose up -d
```

### Step 5: Find Your Admin Password 🔑

The server automatically generates an initial password for the `openvpn` admin user upon 
first launch. To find this password, you need to check the container's logs.

```bash
docker-compose logs
```

Look for a block of text near the end of the log output that provides the admin UI 
address and login credentials. It will look similar to this:

```
+++++++++++++++++++++++++++++++++++++++++++++++
Access Server Web UIs are available here:
Admin  UI: https://<your_server_ip>:943/admin
Client UI: https://<your_server_ip>:943
Login as "openvpn" with "YourRandomPassword"
+++++++++++++++++++++++++++++++++++++++++++++++
```

### Step 6: Final Configuration 🖥️

You can now log in to the Admin Web UI at `https://<your-server-ip>:943/admin` using the 
username `openvpn` and the password you found in the logs. From there, you can configure 
users, network settings, and other server options.

## 3. Additional Links

- [Official Docker OpenVPN Server with Access Server](https://openvpn.net/as-docs/docker.html)
- [System Requirements](https://openvpn.net/as-docs/system-requirements.html)
