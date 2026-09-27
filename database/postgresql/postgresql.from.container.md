# Connecting Docker Containers to Local PostgreSQL Host

Configure a host PostgreSQL service to accept incoming database connections from Docker container networks.

---

## Step 1: Allow Remote Listeners (`postgresql.conf`)

1. Open `/etc/postgresql/<VERSION_NUM>/main/postgresql.conf`:
   ```bash
   sudo nano /etc/postgresql/<VERSION_NUM>/main/postgresql.conf
   ```
2. Enable all network interfaces:
   ```ini
   listen_addresses = '*'
   ```

---

## Step 2: Configure Client Authentication (`pg_hba.conf`)

1. Open `/etc/postgresql/<VERSION_NUM>/main/pg_hba.conf`:
   ```bash
   sudo nano /etc/postgresql/<VERSION_NUM>/main/pg_hba.conf
   ```
2. Under the IPv4 local connections section, add records for the Docker bridge network and local LAN:
   ```text
   # Docker container bridge network
   host    all             all             172.18.0.0/16           md5

   # Local subnet
   host    all             all             192.168.0.0/16          md5
   ```
   *(Adjust authentication method to match your system standard, e.g., `scram-sha-256` or `md5`).*

---

## Step 3: Restart Service

```bash
sudo systemctl restart postgresql
```

---

## Step 4: Firewall Configuration (UFW)

Open port `5432` to container networks:

```bash
# Option A: Allow port universally
sudo ufw allow 5432/tcp

# Option B (Recommended): Restrict access strictly to Docker network subnet
sudo ufw allow from 172.18.0.0/16 to any port 5432
```

Verify firewall status:
```bash
sudo ufw status
```
