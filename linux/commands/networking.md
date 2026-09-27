# NetworkManager CLI (`nmcli`) Management

Common commands for managing network state and connections using `nmcli`.

## Restart Networking Subsystem

Toggle networking off and back on via NetworkManager:

```bash
sudo nmcli networking off
sudo nmcli networking on
```

## List Configured Network Connections

Display all available network interfaces and connections with their names and UUIDs:

```bash
sudo nmcli connection show
```

## Remove a Network Connection

Delete an unused or obsolete connection profile by specifying its UUID from the list:

```bash
sudo nmcli connection delete <UUID>
```
