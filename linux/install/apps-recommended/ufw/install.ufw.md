# Install UFW (Uncomplicated Firewall)

To install UFW and set the default policy to allow outgoing traffic, run the following
commands:

```bash
sudo apt-get install ufw
sudo ufw default allow outgoing
```

## GUI Interface

To also include a GUI firewall application, install `gufw`:

```bash
sudo apt-get install gufw
```
