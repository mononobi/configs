# UFW Warning: UID is 0 but '/lib' or '/usr' is owned by 1000

## Error Message

When running `sudo ufw` or installing applications that manage firewall rules 
(such as Conduit Node), you may see warnings like:

```text
WARN: uid is 0 but '/lib' is owned by 1000
WARN: uid is 0 but '/usr' is owned by 1000
```

---

## Cause

1. **Root Directory Ownership Security Check:**  
   UFW performs security checks on system binary and library paths (`/usr`, `/lib`, `/bin`). 
   These directories must be strictly owned by `root:root` (UID 0). If owned by a regular 
   user (such as UID 1000), UFW emits this security warning.

2. **How It Happens:**  
   - **Third-Party Tarballs (e.g., XDM):** Certain third-party installers 
     (like Xtreme Download Manager) extract archives directly into `/` using `tar -C "/"`. 
     If the archive contains a `usr/` directory packaged under UID 1000, `tar` applies that 
     user ownership and date to the host's `/usr` directory.
   - **Accidental Recursive chown:** Running `chown -R $USER:$USER ...` from `/` or 
     with an unset/empty variable.
   - Since `/lib` is a symlink pointing to `usr/lib`, changing the ownership of `/usr` 
     triggers warnings for both `/usr` and `/lib`.

---

## Verification

Check the current owner and permissions of system directories:

```bash
ls -ld / /bin /etc /lib /usr /var
```

If `/usr` displays your regular user/group (e.g. `mono mono` or UID 1000) instead of `root root`, 
it needs to be corrected.

---

## Solution

Restore root ownership to `/usr` and clean up any stray installer scripts:

```bash
# 1. Restore root ownership to /usr
sudo chown root:root /usr

# 2. Remove stray installer file dropped into / (if created by XDM)
sudo rm -f /install-script.sh
```

After running these commands, verify that the warning is gone:

```bash
sudo ufw status verbose
```
