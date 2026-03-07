## Conduit Node

Make a copy of both `docker-compose.yml` and `prometheus.yml` files
under `~/.conduit-node` directory:

```bash
mkdir -p ~/.conduit-node
cp docker-compose.yml prometheus.yml ~/.conduit-node
```

### Docker-Compose

Based on the RAM size and CPU core count, customize the `--max-common-clients` value.

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
docker-compose up -d
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

### Access the Grafana Dashboard and Prometheus Raw Data Running Locally:

- `Grafana`: `http://localhost:3030` `(Username: admin, Password: admin)`
- `Prometheus Raw Data`: `http://localhost:9091`

### Access the Grafana Dashboard and Prometheus Raw Data Running on a Remote Server:

To access the Grafana dashboard and Prometheus raw data on a remote server, you can use SSH
tunneling to forward the ports from the remote server to your local machine:

```bash
ssh -L 3031:localhost:3030 -L 9092:localhost:9091 remote_user@server_ip
```

If you have setup SSH key to access the server, you can use the following command instead:

```bash
ssh -L 3031:localhost:3030 -L 9092:localhost:9091 ssh-server-alias
```

Keep the terminal open while you want to access the Grafana dashboard and Prometheus raw data.
Open the following URLs in your local browser:

- `Grafana`: `http://localhost:3031` `(Username: admin, Password: admin)`
- `Prometheus Raw Data`: `http://localhost:9092`
