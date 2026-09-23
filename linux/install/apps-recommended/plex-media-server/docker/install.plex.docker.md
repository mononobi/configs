# Plex Media Server (Docker Compose Edition)

Production-ready Plex Media Server deployment running on Docker Compose with bare-metal
hardware acceleration, RAM-buffered transcoding, local LAN discovery, and 1:1 host
media path mapping.

> [!NOTE]
> Tailored for the **AMD Ryzen 7 7700** processor (RDNA 2 / VCN 3.0 iGPU) with 32 GB RAM,
> leveraging host network mode and native Linux shared memory (`/dev/shm`).

---

## 1. Quick Start

### Automated Installation
Run the self-contained, idempotent installer script:
```bash
./install.plex.docker.sh
```

### Framework Invocation
Call via `require_app` from any runner script in this repository:
```bash
require_app "plex-media-server/docker"
```

---

## 2. Architecture & Volume Mappings

All media paths match the host 1:1, allowing existing Plex SQLite databases and library
indices to resolve instantly without broken links.

| Host Path                          | Container Path           | Mode | Purpose                    |
|:-----------------------------------|:-------------------------|:-----|:---------------------------|
| `/home/mono/.plex/plexmediaserver` | `/config`                | `rw` | Persistent metadata & DB   |
| `/dev/shm/plex`                    | `/dev/shm/plex`          | `rw` | 16 GB RAM transcode buffer |
| `/home/mono/.plex/tmp`             | `/home/mono/.plex/tmp`   | `rw` | Downloads & temp directory |
| `/mnt/movies-1/Movies-1`           | `/mnt/movies-1/Movies-1` | `ro` | Media library 1            |
| `/mnt/movies-2/Movies-2`           | `/mnt/movies-2/Movies-2` | `ro` | Media library 2            |
| `/mnt/movies-3/Movies-3`           | `/mnt/movies-3/Movies-3` | `ro` | Media library 3            |
| `/mnt/movies-4/Movies-4`           | `/mnt/movies-4/Movies-4` | `ro` | Media library 4            |
| `/mnt/movies-5/Movies-5`           | `/mnt/movies-5/Movies-5` | `ro` | Media library 5            |
| `/mnt/movies-6/Movies-6`           | `/mnt/movies-6/Movies-6` | `ro` | Media library 6            |
| `/mnt/movies-7/Movies-7`           | `/mnt/movies-7/Movies-7` | `ro` | Media library 7            |
| `/mnt/movies-7/TV-Shows`           | `/mnt/movies-7/TV-Shows` | `ro` | TV shows library           |

> [!TIP]
> Both `/dev/shm/plex` and `/home/mono/.plex/tmp` match the host filesystem identically.
> Your existing Plex preferences pointing to `/dev/shm/plex` work immediately without
> modifying any web settings.

> [!NOTE]
> `shm_size: 16g` is explicitly set in `docker-compose.yml` to remove Docker's default
> 64 MB container shared memory limit, giving Plex access to the full 16 GB host RAM pool.

### Metadata Directory Layout
Inside the container, Plex looks for:
```text
/config/Library/Application Support/Plex Media Server
```
This directly maps to:
```text
/home/mono/.plex/plexmediaserver/Library/Application Support/Plex Media Server
```
- **Existing Metadata**: Discovered immediately upon container startup.
- **Fresh Install**: Initialized cleanly under `~/.plex/plexmediaserver/` owned by `mono`.

---

## 3. Hardware Decoding: AMD Ryzen 7 7700 (VCN 3.0)

The AMD Ryzen 7 7700 iGPU features Video Core Next (VCN 3.0) with native hardware support
for:
- **HEVC / H.265** (8-bit and 10-bit HDR)
- **H.264 / AVC**
- **VP9**

### Passthrough Configuration
Direct GPU node passthrough is configured in `docker-compose.yml`:
```yaml
devices:
  - /dev/dri:/dev/dri
group_add:
  - video
  - render
```

### Plex Web Transcoder Settings
Navigate to **Settings → Transcoder** in the Plex Web interface:
1. **Transcoder temporary directory**: Set to `/dev/shm/plex` (matches your existing
   host configuration).
2. **Hardware acceleration**: Enable **"Use hardware acceleration when available"**.
3. **Hardware encoding**: Enable **"Use hardware-accelerated video encoding"**.
4. **Hardware transcoding device**: Select **AMD Radeon Graphics (VCN)** (or `Auto`).

> [!IMPORTANT]
> Hardware transcoding requires an active **Plex Pass** subscription. Without Plex Pass,
> the Ryzen 7 7700 will transcode via high-performance multi-threaded software decoding.

---

## 4. Local Area Network (LAN) & Auto-Discovery

The service operates in `network_mode: host` to bind directly to the server's physical
network interfaces:
- **Zero NAT Overhead**: Direct line-rate gigabit streaming for 4K remuxes.
- **GDM Discovery**: Auto-discovery on UDP ports `32410`–`32414` for Smart TVs, Apple TV,
  Roku, and Plex mobile apps on the local subnet.
- **DLNA**: Standard DLNA broadcast discovery on UDP port `1900`.

### Firewall Ports (`ufw`)
The installer automatically opens the required ports:
```bash
sudo ufw allow 32400/tcp comment 'Plex Web & Streaming'
sudo ufw allow 32410:32414/udp comment 'Plex GDM Discovery'
sudo ufw allow 1900/udp comment 'Plex DLNA'
```

### Access URL
Open any web browser on your LAN:
```text
http://<SERVER_LAN_IP>:32400/web
```

---

## 5. Maintenance & Operations

All lifecycle operations are managed using standard Docker Compose commands:

### Check Status
```bash
docker compose -f ~/.plex/docker-compose.yml ps
```

### View Live Logs
```bash
docker compose -f ~/.plex/docker-compose.yml logs -f
```

### Restart Service
```bash
docker compose -f ~/.plex/docker-compose.yml restart
```

### Pull Updates & Recreate Container
```bash
docker compose -f ~/.plex/docker-compose.yml pull
docker compose -f ~/.plex/docker-compose.yml up -d
```
