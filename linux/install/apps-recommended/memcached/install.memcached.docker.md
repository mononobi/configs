# Memcached Docker Compose Setup

Production-grade, automated Memcached deployment powered by Docker Compose.

---

## Key Features

- **Official `:latest` Image**: Deploys the official `memcached:latest` Docker image.
- **Fail-Fast Port Policy**:
  - Validates host port availability upfront (default `11211` or specified via `--port`).
  - Aborts immediately if the port is busy by an external process to prevent silent port drift.
  - Transparently reuses the port if already owned by the container.
- **Interactive Host Client (`memcached-cli`)**:
  - Equips the host system with an interactive client linked to `~/.local/bin/memcached-cli`.
  - Auto-connects to the running Memcached instance with prompt `127.0.0.1:11211> `.
  - Features readline tab-completion, persistent command history (`~/.memcached_history`), and
    arrow-key navigation.
- **Redis-Style Multi-Key Commands**:
  - `del <k1> <k2> ...`: Delete multiple keys at once and return deleted count `(integer) N`.
  - `mget <k1> <k2> ...`: Retrieve multiple keys in one call.
  - `mset <k1> <v1> <k2> <v2> ...`: Batch key assignment.
  - `exists <key>`: Returns `(integer) 1` or `(integer) 0`.
  - `keys [pattern]`: Discover cached keys matching glob patterns (e.g. `user:*`).
  - `dump`: Full cache export dumping all keys and values.
  - `ping`: Connectivity test returning `PONG`.
- **Built-in `memcached-tool` Diagnostics**:
  - `slabs` / `display`: Formats memory slab allocation into an aligned diagnostic table (chunk
    sizes, pages, used items, evictions).
  - `items`: Inspects item counts and age per slab.
  - `stats [subcommand]`: Comprehensive server metrics.
- **Automated UFW Firewall**: Automatically configures host firewall rules
  (`ufw allow <port>/tcp`).

---

## Directory Structure

All Memcached host files reside under `~/.memcached/`:

```text
~/.memcached/
├── config/
│   └── memcached.conf     # Reference configuration drop
├── logs/                  # Container service logs
└── docker-compose.yml     # Docker Compose service definition
```

---

## Quick Start & Installation

Run the installer from within the recipe folder or via the framework runner:

```bash
# Standard installation (port 11211, 64MB RAM)
./install.memcached.docker.sh

# Install on a custom host port
./install.memcached.docker.sh --port 11220

# Allocate custom memory and maximum connection limit
./install.memcached.docker.sh -m 128 -c 2048

# Force recreation of container and update configurations
./install.memcached.docker.sh -f

# Skip APT updates for host dependencies
./install.memcached.docker.sh --no-update
```

---

## Host CLI Usage (`memcached-cli`)

The wrapper is accessible anywhere on your system via `memcached-cli`:

### 1. Interactive REPL

```bash
memcached-cli
Connected to Memcached at 127.0.0.1:11211.
Type 'help' for commands, 'exit' or 'quit' to quit.

127.0.0.1:11211> set user:1 "Mono"
STORED
127.0.0.1:11211> get user:1
Mono
127.0.0.1:11211> exists user:1
(integer) 1
127.0.0.1:11211> quit
```

### 2. Multi-Key Commands (Redis-Style)

```bash
# Batch assignment
memcached-cli mset k1 v1 k2 v2 k3 v3
# Output: OK

# Multi-key fetch
memcached-cli mget k1 k2 k3
# Output:
# 1) "k1": "v1"
# 2) "k2": "v2"
# 3) "k3": "v3"

# Multi-key delete
memcached-cli del k1 k2
# Output: (integer) 2

# List cached keys by pattern
memcached-cli keys "user:*"
```

### 3. Cache Diagnostics (`memcached-tool` Style)

```bash
# View memory slab distribution table
memcached-cli slabs

# Dump all stored keys and values
memcached-cli dump

# View server performance metrics
memcached-cli stats
```

### 4. Single Commands & Piping

```bash
memcached-cli ping
# Output: PONG

memcached-cli get user:1
# Output: Mono

echo "get user:1" | memcached-cli
```

---

## Container Lifecycle Management

Manage the Memcached service using standard Docker Compose commands:

```bash
cd ~/.memcached

# View container status
docker compose ps

# View real-time logs
docker compose logs -f

# Stop Memcached
docker compose stop

# Start Memcached
docker compose start

# Restart Memcached
docker compose restart
```
