# Redis Server Setup & Systemd Optimization Guide

Comprehensive configuration, connection commands, and systemd service fixes for Redis server.

---

## 1. Service Management Commands

| Action              | Command                                              |
| :------------------ | :--------------------------------------------------- |
| **Enable on boot**  | `sudo systemctl enable redis-server`                 |
| **Start service**   | `sudo systemctl start redis-server` _(or `redis`)_   |
| **Restart service** | `sudo systemctl restart redis-server` _(or `redis`)_ |
| **Service status**  | `sudo systemctl status redis-server` _(or `redis`)_  |
| **Stop service**    | `sudo systemctl stop redis-server` _(or `redis`)_    |

---

## 2. Connecting with `redis-cli`

```bash
# Connect to local Redis instance:
redis-cli

# Connect to a remote Redis host:
redis-cli -h <IP_ADDRESS>
```

---

## 3. Resolving Systemd PID File Errors

If `systemd` reports PID file errors or service startup hangs, edit
`/etc/systemd/system/redis.service` (or `/lib/systemd/system/redis-server.service`):

Under the `[Service]` section, ensure `ExecStop` and `ExecStartPost` are defined:

```ini
[Service]
Type=forking
ExecStart=/usr/bin/redis-server /etc/redis/redis.conf
ExecStop=/bin/kill -s TERM $MAINPID
ExecStartPost=/bin/sh -c "echo $MAINPID > /var/run/redis/redis.pid"
PIDFile=/run/redis/redis-server.pid
```

Reload and restart systemd:

```bash
sudo systemctl daemon-reload
sudo systemctl restart redis-server
```

---

## 4. Binding to Local Network Interface

By default, Redis binds only to loopback (`127.0.0.1 ::1`). To allow connections from
containers or local LAN machines:

1. Open `/etc/redis/redis.conf`:

   ```bash
   sudo nano /etc/redis/redis.conf
   ```

2. Locate `bind` and include your real LAN IP:

   ```text
   bind 127.0.0.1 192.168.2.104
   ```

   _(Replace `192.168.2.104` with your machine's static IP. Remove `::1` if IPv6 is disabled)._

3. Restart the service:
   ```bash
   sudo systemctl restart redis-server
   ```

---

## 5. Firewall Configuration (UFW)

Open the Redis port (`6379`) in UFW:

```bash
# Allow all connections to Redis:
sudo ufw allow 6379

# Recommended: Restrict access strictly to Docker container subnet:
sudo ufw allow from 172.18.0.0/16 to any port 6379
```

Verify firewall status:

```bash
sudo ufw status
```

---

## 6. Helper Utility

A reload helper script `redis-reload` is included in this repository. You can copy it to
`/usr/local/sbin/` and add it to startup scripts to ensure Redis is initialized cleanly on
boot.
