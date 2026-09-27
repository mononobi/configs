# pgAdmin 4 Installation

Follow these steps to install pgAdmin 4.

## 1. Install Repository Public Key

Install the public key for the repository (if not done previously):

```bash
sudo curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo tee /etc/apt/trusted.gpg.d/pgadmin4.asc
```

## 2. Configure Repository

Create the repository configuration file and update the package list:

```bash
sudo sh -c 'echo "deb [arch=amd64] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
```

## 3. Install Package

Install the `pgadmin4` package:

```bash
sudo apt-get install pgadmin4
```

## 4. Post-Installation

After the installation completes, stop and disable the Apache server, which gets installed
alongside pgAdmin 4 by default:

```bash
sudo systemctl stop apache2
sudo systemctl disable apache2
```
