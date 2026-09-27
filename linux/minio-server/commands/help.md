# MinIO Client (`mc`) CLI Installation & Setup

Instructions for installing and configuring the official MinIO Client (`mc`) CLI utility.

---

## 1. Download & Install `mc`

Download the official binary:

```bash
wget https://dl.min.io/client/mc/release/linux-amd64/mc
```

Install to `/usr/local/sbin` and grant executable permissions:

```bash
sudo mv mc /usr/local/sbin/
sudo chown $(whoami):$(whoami) /usr/local/sbin/mc
sudo chmod 755 /usr/local/sbin/mc
```

---

## 2. Configuration & Aliases

Configure client profiles in `~/.mc/config.json`:

- Rename template `_.mc` directory to `.mc` in your user's home directory if applicable:
  ```bash
  mv ~/_.mc ~/.mc
  ```
- Manage host aliases directly via `mc`:
  ```bash
  mc alias set myminio http://localhost:9000 ACCESS_KEY SECRET_KEY
  ```

---

## 3. Usage & Command Reference

```bash
mc --help
```
