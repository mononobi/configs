# PostgreSQL CLI & Service Commands Cheat Sheet

Essential CLI commands for checking service status, managing daemon lifecycle, user authentication, and psql operations.

---

## Service Management

| Action                          | Command                             |
|:--------------------------------|:------------------------------------|
| **Check Port Listening (5432)** | `sudo ss -tunelp \| grep 5432`      |
| **Start Service**               | `sudo systemctl start postgresql`   |
| **Stop Service**                | `sudo systemctl stop postgresql`    |
| **Restart Service**             | `sudo systemctl restart postgresql` |
| **Service Status**              | `sudo systemctl status postgresql`  |
| **Server Version**              | `pg_config --version`               |

---

## Configuration & Data Paths

- **Main Configuration File**: `/etc/postgresql/<VERSION_NUM>/main/postgresql.conf`
- **Default Data Directory**: `/var/lib/postgresql/<VERSION_NUM>/main`

---

## User & Authentication Management

```bash
# Switch to postgres system user:
sudo su - postgres
# or
sudo su postgres

# Set / change postgres database user password:
sudo su - postgres
psql -c "ALTER USER postgres WITH PASSWORD 'PASSWORD_HERE';"

# Connect to psql console as postgres superuser:
sudo -u postgres psql
# Or if logged in as postgres user:
psql -U postgres
```

---

## Database & User Administration (SQL)

```sql
-- Create database user with encrypted password:
CREATE USER myuser WITH ENCRYPTED PASSWORD 'mypass';

-- Drop a database:
DROP DATABASE "database-name";
```
