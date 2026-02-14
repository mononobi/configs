# OpenVPN Auto-Connect on System Startup (systemd)

## Prerequisites
- OpenVPN profile already added to Ubuntu (accessible in UI)
- systemd service files for OpenVPN installed
- Root or sudo access

## Steps

### 1. Identify Your OpenVPN Profile Name
```bash
nmcli connection show
```
Look for the "NAME" column and identify your OpenVPN connection. 
This is the name you should use in your systemd service file.

### 2. Create a systemd Service File
Create a new service file:
```bash
sudo nano /etc/systemd/system/openvpn-startup.service
```

### 3. Add Service Configuration
Paste the following content (replace `YOUR_PROFILE_NAME` with your actual profile filename):
```ini
[Unit]
Description=OpenVPN Auto-Connect on Startup
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/nmcli connection up "YOUR_PROFILE_NAME"
ExecStop=/usr/bin/nmcli connection down "YOUR_PROFILE_NAME"
# Auto-Reconnect on Disconnect
Restart=on-failure
RestartSec=5
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

### 4. Enable and Start the Service
```bash
sudo systemctl daemon-reload
sudo systemctl enable openvpn-startup.service
sudo systemctl start openvpn-startup.service
```

### 5. Verify Status
```bash
sudo systemctl status openvpn-startup.service
```

Check connection:
```bash
ip addr show
```

> Note: When an OpenVPN connection is established, it typically creates a new virtual 
> network interface (e.g., tun0 or tap0). This command will display all network interfaces, 
> including this new VPN interface and its assigned IP address, which helps confirm that 
> the VPN tunnel is active and has successfully obtained an IP address.

## Disable Auto-Connect
```bash
sudo systemctl disable openvpn-startup.service
sudo systemctl stop openvpn-startup.service
```

## Troubleshooting

**Service fails to start:**
```bash
sudo journalctl -u openvpn-startup.service -n 50
```

## Use Short Commands To Enable/Disable Auto-Connect

Make the scripts executable:
```bash
chmod +x ./scripts/openvpn-startup-enable
chmod +x ./scripts/openvpn-startup-disable
```

Copy the both scripts into the local `bin` folder to be able
to run them as a command from anywhere:
```bash
cp ./scripts/openvpn-startup-enable ~/.local/bin/
cp ./scripts/openvpn-startup-disable ~/.local/bin/
```

Run this command to enable auto-connect:
```bash
openvpn-startup-enable
```

Run this command to disable auto-connect:
```bash
openvpn-startup-disable
```
