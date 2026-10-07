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
- **Shared Directory (`shared/`)**: Mounted to `/shared` in the container with open read/write
  permissions (`777`), enabling seamless, friction-free file exchange between the host user and
  SQL Server for database backups (`.bak` files), CSV exports, and initialization scripts
  without requiring `sudo` or host group modifications.
- **Compose & Configurations**: `docker-compose.yml` is owned by the host user and editable
  without administrative privileges.
