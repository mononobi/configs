## Conduit Node

Execute these commands to copy the necessary files and directories to
the `~/.conduit-node` directory from the `files` directory.

```bash
mkdir -p ~/.conduit-node/data
cp docker-compose.yml prometheus.yml ~/.conduit-node
cp -r grafana-provisioning ~/.conduit-node
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

### Access the Grafana Dashboard and Prometheus Locally:

- `Grafana`: `http://localhost:3030` `(Username: admin, Password: admin)`
- `Prometheus`: `http://localhost:9091`

### Access the Grafana Dashboard and Prometheus Running on a Remote Server:

To access the Grafana dashboard and Prometheus on a remote server, you can use SSH
tunneling to forward the ports from the remote server to your local machine:

```bash
ssh -L 3031:localhost:3030 -L 9092:localhost:9091 remote_user@remote_server_ip
```

If you have setup SSH key to access the server, you can use the following command instead:

```bash
ssh -L 3031:localhost:3030 -L 9092:localhost:9091 ssh_server_alias
```

You can add the following configuration to your `~/.ssh/config` file to create an alias for
the remote server and to automatically open the Grafana dashboard in your default browser when
you connect:

```text
Host SSH_SERVER_ALIAS
    HostName REMOTE_SERVER_IP
    User REMOTE_USER
    IdentityFile ~/.ssh/IDENTITY_FILE
    IdentitiesOnly yes
    LocalForward 3031 localhost:3030
    LocalForward 9092 localhost:9091
    PermitLocalCommand yes
    LocalCommand xdg-open http://localhost:3031
```

Now you can simply open the Grafana dashboard using the alias:

```bash
ssh SSH_SERVER_ALIAS
```

The default browser will automatically open the Grafana dashboard at `http://localhost:3031`.

Keep the terminal open while you want to access the Grafana dashboard and Prometheus.

You can also manually open the following URLs in your local browser after tunneling:

- `Grafana`: `http://localhost:3031` `(Username: admin, Password: admin)`
- `Prometheus`: `http://localhost:9092`

### Other URLs

- `Prometheus Metrics`: `http://localhost:9091/metrics`
- `Prometheus Targets`: `http://localhost:9091/targets`
- `Grafana Datasource`: `http://host.docker.internal:9091`

### Firewall Rules

Make sure these rules are defined in your firewall to allow access from Grafana to Prometheus
and to allow access to the Grafana dashboard and Prometheus from your local machine:

```bash
# Allow access from Grafana to Prometheus in the Docker network
sudo ufw allow from 172.16.0.0/12
sudo ufw allow from 10.0.0.0/8
# Allow access to Grafana dashboard and Prometheus from your local machine through SSH tunneling
sudo ufw allow OpenSSH
sudo ufw allow 22
```

### Final Note

You can also use the `conduit-stats` command to see some basic stats about the Conduit node,
such as the number of connected clients, connection history, and CPU/RAM usage.
This command is a wrapper around `docker stats` and `docker logs` to provide a more user-friendly
output.

#### Copy the `conduit-stats` script to your local bin directory and make it executable:

```bash
cp conduit-stats ~/.local/bin
chmod +x ~/.local/bin/conduit-stats
```

#### Run the `conduit-stats` command to see the stats:

```bash
conduit-stats
```
