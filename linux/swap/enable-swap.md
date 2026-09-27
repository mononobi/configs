# Enabling and Optimizing Linux Swap Space

Create, enable, and tune a persistent swap file for Ubuntu/Debian systems.

---

## Sizing Guidelines

- **Systems with < 2 GB RAM**: 2× physical RAM.
- **Systems with 2 – 8 GB RAM**: Equal to physical RAM.
- **Systems with > 8 GB RAM**: 4 GB to 8 GB of swap.

---

## Setup by Ubuntu Version

### Ubuntu <= 22.04 (`/swapfile`)

```bash
# 1. Allocate 5GB swapfile (or adjust size as needed)
sudo fallocate -l 5G /swapfile

# Fallback using dd if fallocate is unavailable:
# sudo dd if=/dev/zero of=/swapfile bs=1024 count=5242880

# 2. Set strict permissions (root-only)
sudo chmod 600 /swapfile

# 3. Format as Linux swap
sudo mkswap /swapfile

# 4. Enable swap
sudo swapon /swapfile

# 5. Persist across reboots in /etc/fstab
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

### Ubuntu > 22.04 (`/swap.img`)

```bash
# 1. Allocate 5GB swap file
sudo fallocate -l 5G /swap.img

# Fallback using dd if fallocate is unavailable:
# sudo dd if=/dev/zero of=/swap.img bs=1024 count=5242880

# 2. Set strict permissions
sudo chmod 600 /swap.img

# 3. Format as Linux swap
sudo mkswap /swap.img

# 4. Enable swap
sudo swapon /swap.img

# 5. Persist across reboots in /etc/fstab
echo '/swap.img none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

## Verification

```bash
sudo swapon --show
free -h
```

---

## Kernel Swappiness Optimization

Swappiness controls how aggressively the Linux kernel moves memory pages to swap (range
`0` to `100`, default `60`). A lower value keeps processes in physical RAM longer.

### Check Current Value

```bash
cat /proc/sys/vm/swappiness
```

### Set Optimized Value (e.g., 10 for Servers / Workstations)

```bash
sudo sysctl vm.swappiness=10
```

### Persist Configuration Across Reboots

Append `vm.swappiness=10` to `/etc/sysctl.conf`:

```bash
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
```
