# Microsoft SQL Server (Docker Compose) Setup

Automated, isolated installation of Microsoft SQL Server using Docker Compose. Supports
multi-version management, persistent host-mounted data, dedicated shared volume for backups,
automatic UUID v4 password generation, custom case-sensitive collation, and UFW firewall rules.

---

## Directory Structure

All runtime files and volumes are persisted on the host in `~/.sqlserver/<version>/`:

```text
~/.sqlserver/2022/
├── data/                  # Host bind mount for SQL Server data (/var/opt/mssql, engine-private 0700)
├── logs/                  # Dedicated host mount for server diagnostic logs (/var/opt/mssql/log, mode 777)
├── shared/                # Two-way exchange directory for backups & SQL scripts (mode 777)
└── docker-compose.yml     # Generated Compose configuration (user-owned)
```

---

## Installation & Deployment

Execute the installer directly:

```bash
cd linux/install/apps-recommended/sqlserver
./install.sqlserver.docker.sh
```

### CLI Options

| Flag                   | Description                                                                             |
| :--------------------- | :-------------------------------------------------------------------------------------- |
| `[VERSION...]`         | SQL Server release year(s) (e.g. `2022`, `2019`). Default: latest release (e.g. `2025`) |
| `-p, --password <PWD>` | Set custom `sa` password (default: automatically generated UUID v4)                     |
| `--port <PORT>`        | Set custom host port (default: `1433`, falls back to next free port if occupied)        |
| `--collation <COL>`    | Set collation (default: `SQL_Latin1_General_CP1_CS_AS` - Case-Sensitive)                |
| `-f, --force`          | Force regenerating configurations and restarting containers                             |
| `--no-update`          | Skip host APT updates                                                                   |
| `-h, --help`           | Display usage help                                                                      |

### Examples

```bash
# Auto-detects latest release (e.g. 2025) and deploys on port 1433
./install.sqlserver.docker.sh

# Deploy specific version on custom port
./install.sqlserver.docker.sh 2022 --port 1435

# Deploy multiple versions side-by-side
./install.sqlserver.docker.sh 2022 2019

# Set custom password
./install.sqlserver.docker.sh -p "MyStrongPass123!"
```

### Pre-flight Version Validation

Before creating any local directories (`data/`, `logs/`, `shared/`), modifying permissions, or
generating Compose files, the installer queries the Microsoft Container Registry (MCR) to
verify that all requested versions/tags exist.

If an invalid or unsupported version is specified (e.g. `2014` or `2099`):

- The installer fails immediately with a clear error message.
- It displays the list of officially available releases (`2025`, `2022`, `2019`, `2017`).
- Zero directories, configurations, or partial artifacts are created on disk.

---

## Host CLI Utilities (`sqlcmd`, `bcp`)

The installer automatically exposes wrapper utilities in `~/.local/bin/` so you can interact
with your SQL Server instances directly from your host shell without running `docker exec` or
looking up generated credentials:

- **`sqlcmd`**: Full-featured interactive and batch SQL client.
  - Automatically detects the container's generated `sa` password and connects to `localhost`.
  - Automatically trusts local development certificates (`-C`).
  - Automatically selects the running instance if only one is configured, or displays an
    interactive menu if multiple versions exist.
  - Can directly target specific instances via `--instance <name|year>` or `--port <port>`.
- **`bcp`**: High-speed bulk copy utility for importing and exporting tables to/from text or
  CSV files.
- **`sql-stop-all`**: Convenience command to stop all running SQL Server instances (`-d` to
  down).
- **`sql-start-all`**: Convenience command to launch all configured SQL Server instances.

### CLI Examples

```bash
# Interactive terminal session (auto-authenticates to running instance)
sqlcmd

# Run single query and exit
sqlcmd -Q "SELECT @@VERSION;"

# Query databases list
sqlcmd -Q "SELECT name FROM sys.databases;"

# Execute a SQL script file
sqlcmd -i /path/to/script.sql

# Target specific instance when multiple versions are running
sqlcmd --instance 2025 -Q "SELECT 1;"
sqlcmd --port 1433 -Q "SELECT 1;"

# Pipe query into sqlcmd
echo "SELECT 12345 AS val;" | sqlcmd
```

---

## Connection Information

- **Host**: `localhost` (or `127.0.0.1`)
- **Port**: `1433` (or secondary port such as `1434`)
- **User**: `sa`
- **Password**: Shown in the installation summary (generated UUID v4)
- **Encryption**: Set `Trust Server Certificate = true` / `Encrypt = false` in client
  connections (DBeaver, DataGrip, Azure Data Studio, SSMS).

---

## Permissions & Host Access

- **Database Files (`data/`)**: SQL Server in Docker runs under non-root UID `10001` (`mssql`).
  The `data/` directory (`/var/opt/mssql`) holds raw `.mdf` and `.ldf` database cluster files
  and remains engine-private (`0700` owned by `10001`). This standard Linux isolation prevents
  accidental deletion or file corruption from host user commands.
- **Log Files (`logs/`)**: Dedicated host directory mounted to `/var/opt/mssql/log` with mode
  `777`. SQL Server writes `errorlog` and diagnostic trace files here, allowing host users to
  inspect, tail, and open logs in editors directly without root privileges.
- **Shared Directory (`shared/`)**: Mounted to `/shared` in the container with open read/write
  permissions (`777`), enabling seamless, friction-free file exchange between the host user and
  SQL Server for database backups (`.bak` files), CSV exports, and initialization scripts
  without requiring `sudo` or host group modifications.
- **Compose & Configurations**: `docker-compose.yml` is owned by the host user and editable
  without administrative privileges.
