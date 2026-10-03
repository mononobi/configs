# SSH Connections & Port Forwarding Cheat Sheet

Complete reference for standard SSH connections, key authentication, local port forwarding, and
remote reverse tunneling.

---

## 1. Remote Server Connections

```bash
# Connect using default port (22):
ssh remote_user@remote_server

# Connect using a custom port:
ssh -p <PORT_NO> remote_user@remote_server

# Connect providing a specific private key:
ssh -i /path/to/private_key remote_user@remote_server

# Force password authentication (bypass local SSH keys):
ssh -o PreferredAuthentications=password remote_user@remote_server
```

---

## 2. Local Port Forwarding (SSH Tunnels)

Run these commands on the **client machine** (your local computer or intermediate node) to
forward traffic from a local port to a remote destination through an SSH bastion.

### Dynamic SOCKS Proxy (Foreground)

```bash
ssh -f -N -D <LOCAL_PORT> remote_user@remote_server
```

### Background Port Forwarding (Universal)

```bash
ssh -f -N -i <PRIVATE_KEY_PATH> -o GatewayPorts=true -L <LOCAL_PORT>:<REMOTE_ADDRESS>:<REMOTE_PORT> remote_user@remote_server
```

#### Example

Forward local port `5000` to remote port `5000`:

```bash
ssh -f -N -i private_key_path -o GatewayPorts=true -L 5000:0.0.0.0:5000 remote_user@remote_server
```

### Binding to Privileged Ports (< 1024)

Binding to ports below 1024 (e.g., port 80 or 443) requires elevated privileges:

```bash
# Option A: Run as root (requires PermitRootLogin on remote host)
sudo ssh -f -N -i private_key_path -o GatewayPorts=true -L 80:0.0.0.0:80 root@remote_server

# Option B: Run via authbind without root privileges
authbind --deep ssh -f -N -i private_key_path -o GatewayPorts=true -L 80:0.0.0.0:80 remote_user@remote_server
```

---

## 3. Remote Reverse Port Forwarding

Run on the **client machine** to expose a local service on a remote public server port:

```bash
ssh -f -N -i <PRIVATE_KEY_PATH> -o GatewayPorts=true -R <REMOTE_PORT>:<LOCAL_ADDRESS>:<LOCAL_PORT> remote_user@remote_server
```

---

## Use Cases

### Local Port Forwarding is useful when:

1. **Bypassing Censorship / Internet Access**: You want to route internet traffic from your
   local machine through an unblocked remote server.
2. **Accessing Internal Services**: You want to access internal database or admin ports on a
   remote server without exposing those ports to the public internet.

### Remote Port Forwarding is useful when:

1. **Public Webhooks & Demonstrations**: You want to expose a local web service (e.g.,
   `localhost:3000`) on a public remote server without requiring a static public IP or port
   forwarding rules on your local router.
