## Watchtower

Watchtower is a tool that automatically updates running Docker containers whenever their base
image is updated.

### Installation

#### Create a directory for Watchtower:

```bash
mkdir -p ~/.watchtower
```

#### Copy the `docker-compose.yml` file to the Watchtower directory:

```bash
cp docker-compose.yml ~/.watchtower/
```

#### Navigate to the Watchtower directory:

```bash
cd ~/.watchtower
```

#### Start Watchtower using Docker Compose:

```bash
docker-compose up -d
```

### Configuration

The `docker-compose.yml` file is configured to check for updates every 3 hours.
You can adjust the `WATCHTOWER_POLL_INTERVAL` environment variable to change the update frequency.

> Note: The docker compose files that have defined volumes, will maintain their state and
> data even after the container is updated. Watchtower will only update the container
> image, not the volumes.

#### Opt-In to Watchtower for specific containers:

To make Watchtower update the containers you want, you need to add the following label
to the `docker-compose.yml` file of each container. Otherwise, Watchtower will ignore
those containers and not update them.

```yml
# This is the magic label that invites Watchtower in to update this container
labels:
  - "com.centurylinklabs.watchtower.enable=true"
```

#### Other Configurations:

```yml
environment:
  # Only receive notifications from watchtower when updates are available (no updates are done)
  - WATCHTOWER_MONITOR_ONLY=true
  # Configure watchtower to check for updates on specific schedules (cron) instead of polling.
  # This is mutually exclusive with "WATCHTOWER_POLL_INTERVAL" config.
  # This example will check for updates every day at 1am.
  - WATCHTOWER_SCHEDULE=0 0 1 * * *
```
