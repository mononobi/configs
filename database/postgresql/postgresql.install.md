# PostgreSQL Installation & Initial Configuration Guide (Ubuntu)

Step-by-step installation, logging setup, and user provisioning for PostgreSQL on Ubuntu.

---

## 1. System Preparation & Official PGDG Repository

```bash
# Update and upgrade system packages
sudo apt update && sudo apt -y upgrade
sudo reboot

# Install prerequisites
sudo apt install -y wget vim lsb-release

# Add PostgreSQL official signing key
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Configure PGDG apt repository
RELEASE=$(lsb_release -cs)
echo "deb http://apt.postgresql.org/pub/repos/apt/ ${RELEASE}-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list

# Update repository metadata and install PostgreSQL
sudo apt update
sudo apt -y install postgresql-11
```

---

## 2. Server Tuning & Configuration (`postgresql.conf`)

Open the configuration file:
```bash
sudo vim /etc/postgresql/11/main/postgresql.conf
```

### Network Connections
```ini
listen_addresses = '*'
```

### Client Defaults
```ini
datestyle = 'iso, ymd'
timezone = 'UTC'
client_encoding = utf-8
check_function_bodies = on
default_transaction_isolation = 'read committed'
```

### Logging Configuration
```ini
logging_collector = on
log_directory = '/var/log/postgresql'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_file_mode = 0600
log_rotation_age = 1d
log_rotation_size = 10MB
log_min_duration_statement = 25
log_line_prefix = '%m [%p] %q%u@%d '
log_timezone = 'UTC'
```

---

## 3. Apply Configuration & Firewall

```bash
sudo systemctl restart postgresql
sudo ss -tunelp | grep 5432
sudo ufw allow 5432/tcp
```

---

## 4. User & Database Provisioning

```bash
# Set password for superuser postgres:
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'PASSWORD_HERE';"

# Connect to database shell:
sudo -u postgres psql
```

Execute SQL provisioning commands:
```sql
CREATE DATABASE mydb;
CREATE USER myuser WITH ENCRYPTED PASSWORD 'mypass';
GRANT ALL PRIVILEGES ON DATABASE mydb TO myuser;
```

---

## 5. Web Management Tool (Optional)

```bash
sudo apt install -y pgadmin4
```

> [!TIP]
> For cluster major version upgrades, refer to [GoRails PostgreSQL Upgrade Guide](https://gorails.com/guides/upgrading-postgresql-version-on-ubuntu-server).
