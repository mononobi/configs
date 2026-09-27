# Local Development Reverse Proxy Setup with Nginx

Configure Nginx as a reverse proxy for local services to access applications via friendly
domain names (e.g., `http://app`) instead of raw port numbers.

---

## 1. Configure Local Domain in `/etc/hosts`

Open `/etc/hosts` with administrative privileges:

```bash
sudo vi /etc/hosts
```

Map your custom host name (e.g., `app`) to `127.0.0.1`:

```text
127.0.0.1	localhost app
```

_(You can replace `app` with any preferred domain or subdomain name. Ensure the same name
is used in your Nginx config)._

---

## 2. Configure Nginx Server Block (`app.conf`)

Edit `app.conf` (or rename it to reflect your application):

```bash
vi app.conf
```

Update the configuration:

- Set `server_name` to the hostname defined in `/etc/hosts` (e.g., `app`).
- Set `proxy_pass` to the upstream port number of your local application (e.g.,
  `http://127.0.0.1:PORT_NUMBER`).

---

## 3. Deploy & Reload Nginx

Copy the configuration to Nginx:

```bash
sudo cp app.conf /etc/nginx/conf.d/
```

Verify Nginx configuration syntax:

```bash
sudo nginx -t
```

Restart Nginx:

```bash
sudo systemctl restart nginx
```

After restarting, restart your browser and navigate to `http://app`.
