# Standard Linux Script & Executable Paths

Recommended filesystem directories for placing custom shell scripts and binaries, along
with required permissions.

---

## 1. System-Wide (Available to All Users)

Target directory:

```bash
/usr/local/bin/
```

Required permissions:

```bash
sudo chown root:root /usr/local/bin/<script_name>
sudo chmod 755 /usr/local/bin/<script_name>
```

---

## 2. Per-User (Current User Only)

Target directory:

```bash
~/.local/bin
```

Required permissions:

```bash
chmod +x ~/.local/bin/<script_name>
```
