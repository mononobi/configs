## Change Hostname

```bash
sudo hostnamectl set-hostname <NEW_HOST_NAME>
```

Open this file and find the line starting with `127.0.1.1` (or your server's public/private IP) 
and replace the old server name with your <NEW_HOST_NAME>. Save and exit.

```bash
sudo nano /etc/hosts
```

Open this file and look for `preserve_hostname: false` and change it 
to `preserve_hostname: true` to prevent cloud init from changing the hostname. Save and exit.

> Note: If the file does not exist, your server isn't using cloud-init for 
> the hostname, and you can skip this step.

```bash
sudo nano /etc/cloud/cloud.cfg
```

To see the new hostname prompt immediately without dropping your connection, just reload the shell:

```bash
exec bash
```

## Create a User & Add It To Sudoers

```bash
sudo useradd -m -s /bin/bash mono
sudo passwd <NEW_PASSWORD>
sudo usermod -aG sudo mono
```

## Remove the Default User (e.g. ubuntu)

```bash
sudo userdel -r ubuntu
```

## Create SSH Key & Disable Password Login

[SSH Key Management](/linux/key-management/ssh-key-ed25519.md)

## Enable & Configure Firewall

[UFW](/linux/commands/ufw.txt)
