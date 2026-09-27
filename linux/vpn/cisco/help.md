# Cisco AnyConnect / OpenConnect Configuration

Instructions for configuring and running the Cisco AnyConnect helper script.

---

## Setup Steps

1. In the `vpn` script file, replace `{SERVER_ADDRESS}`, `{YOUR_USERNAME}`, and
   `{YOUR_PASSWORD}` with your credentials.
2. If OpenConnect / Cisco client packages are not installed, refer to the `connection`
   guide in this directory.
3. Install the script globally:
   ```bash
   sudo cp vpn /usr/local/sbin/
   sudo chmod 755 /usr/local/sbin/vpn
   ```
4. Run the VPN connection directly from terminal:
   ```bash
   vpn
   ```
