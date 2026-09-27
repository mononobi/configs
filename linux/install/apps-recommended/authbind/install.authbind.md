# Authbind

Authbind allows you to perform commands which will bind to ports below 1024 without root
access.

## Installation

```bash
sudo apt-get install authbind
```

## Example Usage

```bash
authbind --deep COMMAND
```

```bash
authbind --deep ssh -f -N -i private_key_path -o GatewayPorts=true -L 80:0.0.0.0:80 remote_user@remote_server
```
