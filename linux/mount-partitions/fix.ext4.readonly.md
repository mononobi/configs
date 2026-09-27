# Fix Read-Only Permissions on External ext4 Partitions

To gain write access to an external or secondary ext4 drive (separate from your root Linux
filesystem), assign group ownership and write permissions to the `adm` group at the mount
point.

---

## Commands

```bash
sudo chgrp adm <MOUNT_POINT>
sudo chmod g+w <MOUNT_POINT>
```

### Example

```bash
sudo chgrp adm /media/username/56d0c0ab-60a0-48bf-955d-bc2f283009b6
sudo chmod g+w /media/username/56d0c0ab-60a0-48bf-955d-bc2f283009b6
```
