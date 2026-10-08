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
  - Because major versions are pinned, Watchtower and Docker Compose only apply **safe minor
    and security updates** (e.g. `18.0` $\rightarrow$ `18.1` $\rightarrow$ `18.2`), which are
    100% binary-compatible with your existing data files.
  - Future major releases (e.g., PostgreSQL 19) will **never** automatically overwrite or
    corrupt your PostgreSQL 18 cluster.
- **Clean Fallback Cleanup**: If the installer ever pulls a temporary `:latest` image during
  inspection fallback, it immediately deletes that temporary image so no dangling tags or
  storage remain on your system.
- **OS Reinstall Resilience**: All database data and configurations persist directly under
  `~/.postgres/<version>/` in user space. If your `/home` partition is preserved or restored
  after an OS reinstallation, your databases, schemas, and configurations remain 100% intact.
- **Multiple Concurrent Versions**: Run multiple major PostgreSQL versions (e.g., `18`, `17`,
  `16`) side-by-side without port collisions or conflicting shared system libraries.
- **Identical Connectivity**: Exposes standard ports on `localhost` so database GUI clients
  (DBeaver, TablePlus, DataGrip, pgAdmin) and programming languages (Node.js, Python, Go, Rust)
  connect identically to native installations.
- **Zero-Friction Host CLI**: Automatically equips the host system with `postgresql-client` so
  `psql`, `pg_dump`, and `pg_restore` work directly in your terminal without requiring
  `docker exec`.
- **Clean User-Space Access & File Sharing**:
  - Custom server configurations (`db.conf`, `pg_hba.conf`, and `.conf` drops), `initdb.d/`,
    and `docker-compose.yml` reside in user space and are editable without `sudo`.
  - Server query logs in `logs/` are generated with readable mode (`0644`), allowing direct
    inspection in your editor or terminal without root privileges.
  - A dedicated `shared/` directory (mounted to `/shared` in the container) provides seamless,
    permission-frictionless two-way file exchange (e.g. for CSV imports, SQL dumps, or scripts)
    between the host user and the container.
  - The raw database directory (`data/pgdata`) remains standard and private to the PostgreSQL
    engine (`0700`), ensuring full ACID safety and data integrity without fragile host group
    hacks.
- **PostGIS Support**: One-flag deployment of spatial databases via official `postgis/postgis`
  images.
- **Automated UFW Firewall**: Opens instance listening ports in UFW automatically.

---

## Directory Structure

Each provisioned PostgreSQL instance is isolated in its own home subfolder named after its
major version:

```text
~/.postgres/
├── 18/
│   ├── config/
│   │   ├── conf.d/
│   │   │   └── db.conf           # Custom server tuning & query logging
│   │   └── pg_hba.conf           # Client authentication rules
│   ├── data/                     # Database cluster files (engine-private, 0700)
│   ├── initdb.d/                 # First-boot SQL & shell initialization scripts
│   ├── logs/                     # Query and statement rotation logs (mode 0644)
│   ├── shared/                   # Two-way exchange directory for dumps, CSVs, imports
│   └── docker-compose.yml        # Docker Compose service definition (image: postgres:18)
└── 17/
    ├── config/
    ├── data/
    ├── initdb.d/
    ├── logs/
    ├── shared/
    └── docker-compose.yml
```

---

## Quick Start & Installation

Run the unattended installer from `linux/install/apps-recommended/postgresql/`:

### 1. Default Installation (Latest Stable)

Auto-detects the current latest stable major version (e.g. `18`), creates `~/.postgres/18/`,
and binds to default port `5432`:

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

PostGIS instances are stored in dedicated directories (`~/.postgres/<version>-postgis/`, e.g.
`~/.postgres/18-postgis/`) with container name `postgres-<version>-postgis`. They can run
side-by-side with vanilla PostgreSQL instances on separate ports without replacing or
overwriting each other's data.

### 4. Custom Host Port (`--port`)

Specify a custom base port for the primary instance. If the port (or default 5432) is busy, the
installer automatically finds and binds to the next free available port, logging an
informational message:

```bash
# Attempt to install on specific port 5435 (falls back to next free port if occupied)
./install.postgresql.docker.sh 18 --port 5435

# Install multiple versions: 18 binds to 5440, and 16 binds to next free port (>= 5441)
./install.postgresql.docker.sh 18 16 --port 5440
```

### 5. Custom Credentials & Databases

```bash
./install.postgresql.docker.sh -p "mysecurepass" -u "developer" -d "production_dev"
```

### Pre-flight Version Validation

Before creating any local directories (`data/`, `config/`, `initdb.d/`, `logs/`, `shared/`),
modifying permissions, or generating Compose files, the installer queries Docker Hub to verify
that all requested versions/tags exist (for both standard PostgreSQL and PostGIS).

If an invalid or unsupported version is specified (e.g. `99`):

- The installer fails immediately with a clear error message.
- It displays the list of major versions available on Docker Hub (e.g.
  `18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8`).
- Zero directories, configurations, or partial artifacts are created on disk.

---

## Connection Credentials & Defaults

Unless customized with flags, all instances default to standard local development credentials:

| Parameter            | Default Value | Notes                                                                |
| :------------------- | :------------ | :------------------------------------------------------------------- |
| **Superuser**        | `postgres`    | Configurable via `-u, --user`                                        |
| **Password**         | `123`         | Configurable via `-p, --password`                                    |
| **Default Database** | `postgres`    | Configurable via `-d, --database`                                    |
| **Host Port**        | `5432`        | Configurable via `--port <port>` (automatically uses next free port) |
| **Secondary Ports**  | `5433+`       | Automatically incremented to next free port for additional versions  |

---

## Client Applications & Terminal Access

### 1. GUI Database Clients (DBeaver, TablePlus, DataGrip, pgAdmin)

- **Host**: `localhost` (or `127.0.0.1`)
- **Port**: `5432` (or secondary port such as `5433`)
- **Database**: `postgres`
- **Username**: `postgres`
- **Password**: `123`

### 2. Container-Native CLI Tools (`psql`, `pg_dump`, `pg_restore`)

The installer provides and symlinks wrapper CLI tools directly into `~/.local/bin/`. They
execute transparently inside the target container via `docker exec`, guaranteeing **exact 1:1
client-to-server version matches**, zero catalog/version mismatch warnings, and full support
for all flags and piped input/output:

- **Single Version Installed**: Detects the only version in `~/.postgres/` and executes
  immediately.
- **Multiple Versions Installed**:
  - **Non-Interactive Bypass**: Pass `-p <port>` (e.g. `-p 5433`) or
    `--instance <name|version>` (e.g. `--instance 18` or `--instance postgres-18-postgis`) to
    immediately target that instance without triggering any prompt.
  - **Interactive Mode**: If neither `-p` nor `--instance` is specified, displays an
    interactive numbered menu on stderr and runs against your selected container.

#### `psql` (Interactive & Query Execution)

```bash
# Connect interactively to default database (or shows menu if multiple versions exist):
psql

# Target a specific instance non-interactively via port or instance name:
psql -p 5433
psql --instance 18
psql --instance postgres-18-postgis

# Connect to a specific custom database:
psql -d my_database
# or:
psql --dbname my_database

# Execute one-liner queries or backslash commands:
psql -c "\l"
psql -d my_database -c "SELECT count(*) FROM users;"

# Pipe SQL scripts or run migrations into a specific database:
psql -d my_database < migration.sql
```

#### `pg_dump` (1:1 Schema & Data Backup)

```bash
# Full database plain text backup:
pg_dump > backup.sql

# Backup a specific database:
pg_dump -d my_database > my_db_backup.sql

# Compressed custom archive format:
pg_dump -d my_database -Fc -f /shared/backup.dump

# Dump specific table from a database:
pg_dump -d my_database -t my_table > table_backup.sql
```

#### `pg_restore` (1:1 Archive Restore)

```bash
# Restore custom archive into a specific database:
pg_restore -d my_database /shared/backup.dump

# Clean and recreate tables before restoring:
pg_restore --clean --if-exists -d my_database /shared/backup.dump

# List contents of an archive without connecting to a database:
pg_restore -l /shared/backup.dump
```

#### `pg_dumpall` (Complete Cluster & Globals Backup)

```bash
# Full cluster backup (all databases, roles, globals, tablespaces):
pg_dumpall > cluster_backup.sql

# Backup roles and global settings only:
pg_dumpall --globals-only > globals.sql

# Target a specific cluster via port without prompt:
pg_dumpall -p 5433 > cluster_18.sql
```

#### `pgbench` (Performance Benchmarking)

```bash
# Initialize benchmark schema on default database:
pgbench -i

# Run benchmark test with 10 clients and 2 threads:
pgbench -c 10 -j 2 -t 1000

# Target a specific instance via port:
pgbench -p 5433 -c 10 -t 500
```

### 3. Instance Shared Directory (`~/.postgres/<version>/shared/`)

Each instance includes a dedicated `shared/` directory on the host mounted to `/shared` inside
the container (`./shared:/shared`):

- **Host Path**: `~/.postgres/<version>/shared/`
- **Container Path**: `/shared/`

Use this directory to exchange files between host and container:

- Place large backup archives or CSV datasets into `~/.postgres/<version>/shared/` to restore
  or import them directly via `pg_restore -d mydb /shared/archive.dump` or
  `COPY ... FROM '/shared/data.csv'`.
- Save dumps directly to the shared folder via `pg_dump -Fc -f /shared/dump.sql`.

### 4. Connection URIs for Programming Languages

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

Place any `.sql` or `.sh` script into `~/.postgres/<version>/initdb.d/`. Scripts run
automatically in alphabetical order the very first time the database cluster initializes.

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

# Stop all PostgreSQL instances across ~/.postgres/ at once:
pg-stop-all

# Start all PostgreSQL instances across ~/.postgres/ at once:
pg-start-all

# Down (remove) all PostgreSQL instances at once (volumes preserved):
pg-stop-all -d
# or:
pg-stop-all --down
```
