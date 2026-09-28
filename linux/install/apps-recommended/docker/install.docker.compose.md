# Docker Compose Installation

## Best Approach (Recommended)

If you have followed the recommended installation approach from the
[`install.docker.md`](/linux/install/apps-recommended/docker/install.docker.md) file,
Docker Compose has already been installed and is accessible using the `docker compose`
command. With that approach, you get both Docker and Docker Compose with the latest
versions and automatic updates through regular system updates.

## Manual Installation

> **Note**: With this approach, you will get the latest version of Docker Compose, but
> without automatic updates. For the latest version with automatic updates, follow the
> recommended approach above.

Use the following commands to download and install Docker Compose manually:

```bash
sudo curl -L https://github.com/docker/compose/releases/download/v2.35.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

## APT Installation (Not Recommended)

> **Warning**: This approach is not recommended as it typically installs older versions of
> Docker Compose.

```bash
sudo apt-get install docker-compose
docker-compose --version
```
