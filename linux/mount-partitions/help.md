# Persistent Partition Mounting Guide (`/etc/fstab`)

Instructions for mounting internal and external disk partitions automatically at system
boot via `/etc/fstab`.

---

## 1. Identify Partition UUIDs

List all block devices, filesystems, and their unique UUIDs:

```bash
sudo blkid
```

---

## 2. Configure `/etc/fstab`

Add your partition configurations to `/etc/fstab`:

```bash
sudo nano /etc/fstab
```

### Sample References in this Directory

- `samples/fstab.sample`: Standard template for ext4/Linux partitions.
- `samples/fstab.ntfs`: Mounting NTFS drives with read/write permissions and UID/GID
  mapping.
- `samples/fstab.with.external.hdd`: Mounting an external hard drive under `/mnt` instead
  of `/media/user_name`.
- `fstab`: Consolidated template file to merge with your active system fstab.
