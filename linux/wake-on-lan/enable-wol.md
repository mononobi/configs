# Wake-on-LAN (WoL) Complete Configuration

Step-by-step setup to enable Wake-on-LAN across BIOS/UEFI firmware, network routers, and the
Linux operating system.

---

## 1. Enable in BIOS/UEFI

1. Enter your motherboard BIOS/UEFI during boot (`Del` or `F2`).
2. Navigate to **Advanced** / **Power Management** / **APM Configuration**.
3. Enable **Wake on LAN**, **Power On By PCI-E/PCI**, or **Network Boot**.
4. Save and reboot.

---

## 2. Configure Router / Local Gateway

1. Log in to your router management portal.
2. Locate your PC in the connected device / DHCP client list.
3. Enable **Wake on LAN** or reserve a static IP for your machine's MAC address.

---

## 3. Enable in Operating System

### Identify Interface Name

Find your active physical network interface (e.g., `eno1`, `eth0`, `enp3s0`):

```bash
ip link
# or
ifconfig
```

### Verify Interface WoL Capability

```bash
sudo ethtool eno1
```

Look for:

```text
Supports Wake-on: pumbg
Wake-on: g
```

- `Supports Wake-on: ...g...`: Hardware supports Magic Packet wake-up.
- `Wake-on: g`: Wake-on-LAN is enabled.
- `Wake-on: d`: Wake-on-LAN is currently disabled.

### Enable WoL on Interface

```bash
sudo ethtool -s eno1 wol g
```

---

## 4. Persisting Across Reboots

`ethtool` settings reset upon reboot. To persist WoL automatically:

1. Copy helper scripts to `~/.local/sbin/`:
   ```bash
   cp linux/install/commands/sbin/wol-enable ~/.local/sbin/
   cp linux/install/commands/sbin/wol-status ~/.local/sbin/
   chmod +x ~/.local/sbin/wol-enable ~/.local/sbin/wol-status
   ```
2. Open `Startup Applications` (`gnome-session-properties`) and create an entry pointing to
   `~/.local/sbin/wol-enable`.

---

## 5. Mobile Remote Trigger Apps (Android)

Trigger wake-up packets over Wi-Fi using Android utilities:

- [WolOn - Wake on LAN](https://play.google.com/store/apps/details?id=com.bitklog.wolon&hl=en)
- [Wake On Lan by Mike Webb](https://play.google.com/store/apps/details?id=co.uk.mrwebb.wakeonlan&hl=en)
