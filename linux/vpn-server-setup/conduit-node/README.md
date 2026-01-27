## Conduit Node

Make a copy of both `docker-compose.yml` and `Dockerfile` files under `~/.conduit-node` directory:

```bash
mkdir ~/.conduit-node
cp docker-compose.yml Dockerfile ~/.conduit-node
```

### Dockerfile

Change the link on this line:

```dockerfile
RUN wget -O conduit https://github.com/Psiphon-Inc/conduit/releases/download/release-cli-1.1.0/conduit-linux-amd64
```

And point it to the latest stable version from 
[Psiphon Official GitHub](https://github.com/Psiphon-Inc/conduit/releases)

### Docker-Compose

Based on the RAM size and CPU core count, customize the `--max-clients` value.

> NOTE: 
> 
> 1 GB RAM + 1 CPU core ~= 75 Users
>
> For each extra RAM and CPU core ~= 150 Users per RAM + CPU core

Based on your internet connection speed, customize the `--bandwidth` value.

> NOTE: The bandwidth unit is megabits per second (Mbps)

### Start the Service

```bash
cd ~/.conduit-node
docker-compose up -d --build
```

### View Logs

```bash
docker logs -f conduit
```

### View Resource Utilization

```bash
docker stats conduit
```

### Stop the Service

```bash
cd ~/.conduit-node
docker-compose stop
```
