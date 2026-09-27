# Update PostgreSQL

## Upgrade an Old Installation

First, update your system packages:

```bash
sudo apt update
sudo apt -y upgrade
```

## Install New Version

Change `VERSION` to the version you want to install (for example, `14`):

```bash
sudo apt -y install postgresql-VERSION
```

## Additional Resources

> **Note** To update and/or remove the old cluster (if required, with caution), visit this
> page:
> [Upgrading PostgreSQL Version on Ubuntu Server](https://gorails.com/guides/upgrading-postgresql-version-on-ubuntu-server)
