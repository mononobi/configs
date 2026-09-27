# Fix Read-Only Mounts on NTFS Drives

If an NTFS partition mounts in read-only mode without write access, try the following
solutions in order (restarting or remounting after each):

---

## Solution 1: Install Modern NTFS Driver (`ntfs-3g`)

Remove outdated utilities and install `ntfs-3g`:

```bash
sudo apt-get remove ntfsprogs && sudo apt-get install -y ntfs-3g
```

---

## Solution 2: Repair NTFS Filesystem Inconsistencies

Use `ntfsfix` to clear dirty flags and fix NTFS metadata errors (common after unclean
Windows shutdowns or Fast Startup hibernations):

```bash
sudo ntfsfix /dev/sdXN
```

### Example

```bash
sudo ntfsfix /dev/sdc2
```
