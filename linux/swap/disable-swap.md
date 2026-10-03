# Disabling Linux Swap File

Instructions for disabling active swap and removing swap files permanently from `/etc/fstab`.

---

## Ubuntu <= 22.04 (`/swapfile`)

1. Deactivate swap:

   ```bash
   sudo swapoff -v /swapfile
   ```

2. Open `/etc/fstab`:

   ```bash
   sudo nano /etc/fstab
   ```

   Remove or comment out the swapfile entry:

   ```text
   # /swapfile   none   swap   sw   0   0
   ```

3. Delete the file:
   ```bash
   sudo rm -f /swapfile
   ```

---

## Ubuntu > 22.04 (`/swap.img`)

1. Deactivate swap:

   ```bash
   sudo swapoff -v /swap.img
   ```

2. Open `/etc/fstab`:

   ```bash
   sudo nano /etc/fstab
   ```

   Remove or comment out the swap image entry:

   ```text
   # /swap.img   none   swap   sw   0   0
   ```

3. Delete the file:
   ```bash
   sudo rm -f /swap.img
   ```

---

## Verification

Confirm swap is completely disabled:

```bash
# Should return no output:
sudo swapon --show

# Swap line should display 0B:
free -h
```
