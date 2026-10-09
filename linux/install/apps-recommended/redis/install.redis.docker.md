# Redis Docker Compose Setup

Production-grade, automated Redis deployment powered by Docker Compose.

---

## Key Features

- **Official `:latest` Image**: Deploys the official `redis:latest` Docker image.
- **Persistent Host Storage**:
  - Persists database data and snapshots in `~/.redis/data/` (`dump.rdb` and `appendonlydir/`).
  - Persists configuration in `~/.redis/config/redis.conf`.
  - Persists server logs in `~/.redis/logs/redis.log`.
  - Maintains `~/.redis/docker-compose.yml` in user space.
- **Fail-Fast Port Policy**:
  - Validates host port availability upfront (default `6379` or specified via `--port`).
  - Aborts immediately if the port is busy by an external process to prevent silent port drift.
  - Transparently reuses the port if already owned by the container.
- **Zero-Friction Host CLI (`redis-cli`)**:
  - Automatically installs and symlinks `redis-cli` to `~/.local/bin/redis-cli`.
  - Seamlessly handles interactive REPL sessions (arrows, colors, history, tab completion)
    using TTY allocation.
  - Automatically detects pipelines and input/output redirections (`! -t 0 || ! -t 1`) to
    preserve clean binary/text streaming without Docker TTY escape codes or CRLF line endings.
- **Dual Persistence Architecture**:
  - RDB snapshotting enabled (`save 3600 1 300 100 60 10000`).
  - AOF (Append Only File) logging enabled with `appendfsync everysec` for maximum data
    durability.
- **Automated UFW Integration**: Automatically configures host firewall rules
  (`ufw allow <port>/tcp`).

---

## Directory Structure

All Redis assets persist directly in user space under `~/.redis/`:

```text
~/.redis/
├── config/
│   └── redis.conf         # Redis server configuration file
├── data/                  # Persistent data directory (dump.rdb & appendonlydir/)
├── logs/                  # Persistent log directory (redis.log)
└── docker-compose.yml     # Docker Compose service definition
```

---

## Quick Start & Installation

Run the installer from within the recipe folder or via the framework runner:

```bash
# Standard installation (port 6379, auth disabled)
./install.redis.docker.sh

# Install on a custom host port
./install.redis.docker.sh --port 6380

# Install with password authentication
./install.redis.docker.sh -p mysecretpassword

# Force recreation of the container and update configurations
./install.redis.docker.sh -f

# Skip APT updates for host dependencies
./install.redis.docker.sh --no-update
```

---

## Host CLI Usage (`redis-cli`)

The wrapper is accessible anywhere on your system via `redis-cli`:

### 1. Interactive REPL

```bash
redis-cli
127.0.0.1:6379> SET user:1 "Mono"
OK
127.0.0.1:6379> GET user:1
"Mono"
127.0.0.1:6379> exit
```

### 2. Single Command Execution

```bash
redis-cli PING
# Outputs: PONG
```

### 3. Piping & Redirection (Clean Stream)

```bash
echo "PING" | redis-cli
cat commands.txt | redis-cli
redis-cli --raw GET user:1 > value.txt
```

### 4. Authenticated Connections

```bash
redis-cli -a mysecretpassword PING
```

---

## Container Lifecycle Management

Manage the Redis service using standard Docker Compose commands:

```bash
cd ~/.redis

# View status
docker compose ps

# View real-time logs
docker compose logs -f

# Stop Redis
docker compose stop

# Start Redis
docker compose start

# Restart Redis
docker compose restart
```
