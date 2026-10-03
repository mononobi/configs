# PostgreSQL Docker Compose Multi-Version Setup

Production-grade, automated multi-version PostgreSQL development environment powered by Docker
Compose.

---

## Key Features

- **Automated Major Version Pinning**: When executed without arguments, the installer inspects
  official Docker metadata (via the Registry API or fallback inspection) to resolve the latest
  stable major version (e.g. `18`) and pins the instance to that concrete major release
  (`~/.postgres/18/` with `postgres:18`).
- **Data Safety Against Breaking Upgrades**:
  - Because major versions are pinned, Watchtower and Docker Compose only apply **safe minor and
    security updates** (e.g. `18.0` $\rightarrow$ `18.1` $\rightarrow$ `18.2`), which are 100%
    binary-compatible with your existing data files.
  - Future major releases (e.g., PostgreSQL 19) will **never** automatically overwrite or corrupt
    your PostgreSQL 18 cluster.
- **Clean Fallback Cleanup**: If the installer ever pulls a temporary `:latest` image during
  inspection fallback, it immediately deletes that temporary image so no dangling tags or storage
  remain on your system.
- **OS Reinstall Resilience**: All database data and configurations persist directly under
  `~/.postgres/<version>/` in user space. If your `/home` partition is preserved or restored after an
  OS reinstallation, your databases, schemas, and configurations remain 100% intact.
- **Multiple Concurrent Versions**: Run multiple major PostgreSQL versions (e.g., `18`, `17`,
  `16`) side-by-side without port collisions or conflicting shared system libraries.
- **Identical Connectivity**: Exposes standard ports on `localhost` so database GUI clients
  (DBeaver, TablePlus, DataGrip, pgAdmin) and programming languages (Node.js, Python, Go, Rust) connect
  identically to native installations.
- **Zero-Friction Host CLI**: Automatically equips the host system with `postgresql-client` so
  `psql`, `pg_dump`, and `pg_restore` work directly in your terminal without requiring `docker exec`.
- **Easy Config Access**: Custom server configurations (`db.conf`, `pg_hba.conf`, and `.conf` drops)
  are mounted in user space and editable without `sudo`.
- **PostGIS Support**: One-flag deployment of spatial databases via official `postgis/postgis`
  images.
- **Automated UFW Firewall**: Opens instance listening ports in UFW automatically.

---

## Directory Structure

Each provisioned PostgreSQL instance is isolated in its own home subfolder named after its major version:

```text
~/.postgres/
├── 18/
│   ├── config/
│   │   ├── conf.d/
│   │   │   └── db.conf           # Custom server tuning & query logging
│   │   └── pg_hba.conf           # Client authentication rules
│   ├── data/                     # Database cluster files (persists across OS reinstalls)
│   ├── initdb.d/                 # First-boot SQL & shell initialization scripts
│   ├── logs/                     # Query and statement rotation logs
│   └── docker-compose.yml        # Docker Compose service definition (image: postgres:18)
└── 17/
    ├── config/
    ├── data/
    ├── initdb.d/
    ├── logs/
    └── docker-compose.yml        # Docker Compose service definition (image: postgres:17)
```

---

## Quick Start & Installation

Run the unattended installer from `linux/install/apps-recommended/postgresql/`:

### 1. Default Installation (Latest Stable)

Auto-detects the current latest stable major version (e.g. `18`), creates `~/.postgres/18/`, and binds
to default port `5432`:

```bash
./install.postgresql.docker.sh
```

### 2. Specific or Multiple Versions

Spin up specific versions with automatic port assignment:

```bash
# Install PostgreSQL 18
./install.postgresql.docker.sh 18

# Install multiple versions concurrently
./install.postgresql.docker.sh 18 16
```

### 3. PostGIS Extension Support

To deploy instances with PostGIS pre-installed and ready:

```bash
./install.postgresql.docker.sh --postgis
# Or for a specific version:
./install.postgresql.docker.sh 18 --postgis
```

### 4. Custom Credentials & Databases

```bash
./install.postgresql.docker.sh -p "mysecurepass" -u "developer" -d "production_dev"
```

---

## Connection Credentials & Defaults

Unless customized with flags, all instances default to standard local development credentials:

| Parameter | Default Value | Notes |
| :--- | :--- | :--- |
| **Superuser** | `postgres` | Configurable via `-u, --user` |
| **Password** | `123` | Configurable via `-p, --password` |
| **Default Database** | `postgres` | Configurable via `-d, --database` |
| **Default Port** | `5432` | Reserved for primary instance (aborts if occupied) |
| **Secondary Ports** | `5433+` | Automatically incremented for additional versions |

---

## Client Applications & Terminal Access

### 1. GUI Database Clients (DBeaver, TablePlus, DataGrip, pgAdmin)

- **Host**: `localhost` (or `127.0.0.1`)
- **Port**: `5432` (or secondary port such as `5433`)
- **Database**: `postgres`
- **Username**: `postgres`
- **Password**: `123`

### 2. Terminal CLI (`psql`)

Because `postgresql-client` is installed on your host system:

```bash
# Connect to primary instance (port 5432)
psql -h localhost -p 5432 -U postgres -d postgres

# Connect to secondary instance (e.g. port 5433)
psql -h localhost -p 5433 -U postgres -d postgres
```

### 3. Connection URIs for Programming Languages

```text
postgresql://postgres:123@localhost:5432/postgres
```

---

## Configuration & Tuning

### Modifying Server Settings (`db.conf`)

Edit `~/.postgres/<version>/config/conf.d/db.conf` directly with your favorite editor:

```bash
nano ~/.postgres/18/config/conf.d/db.conf
```

Restart the instance to apply changes:

```bash
docker compose -f ~/.postgres/18/docker-compose.yml restart
```

### Adding Initialization Scripts

Place any `.sql` or `.sh` script into `~/.postgres/<version>/initdb.d/`. Scripts run automatically in
alphabetical order the very first time the database cluster initializes.

---

## Managing Containers

All instances run with `restart: unless-stopped` and resume automatically across reboots.

```bash
# Check status
docker compose -f ~/.postgres/18/docker-compose.yml ps

# View live logs
docker compose -f ~/.postgres/18/docker-compose.yml logs -f

# Stop instance
docker compose -f ~/.postgres/18/docker-compose.yml stop

# Start instance
docker compose -f ~/.postgres/18/docker-compose.yml start

# Remove container (data in ~/.postgres/18/data remains completely safe)
docker compose -f ~/.postgres/18/docker-compose.yml down
```
