# Production SSL/TLS Certificates with Let's Encrypt & Certbot

Automated issuance and renewal of trusted SSL/TLS certificates using Certbot and Nginx.

---

## Prerequisites

- **Official Guides**:
  - [Nginx SSL with Let's Encrypt](https://www.nginx.com/blog/using-free-ssltls-certificates-from-lets-encrypt-with-nginx)
  - [Let's Encrypt Rate Limits](https://letsencrypt.org/docs/rate-limits)
  - [Certbot Staging Environment](https://letsencrypt.org/docs/staging-environment)
  - [Certbot FAQ](https://certbot.eff.org/faq)

> [!IMPORTANT] The target domain (and subdomains) must have public DNS `A` records
> resolving directly to your server's public IP address before issuing certificates, or
> domain validation challenges will fail.

---

## Step 1: Install Certbot & Nginx Plugin

```bash
sudo apt-get update
sudo apt-get install -y certbot python3-certbot-nginx
```

---

## Step 2: Configure Initial HTTP Server Block

Create an initial HTTP virtual host in `/etc/nginx/conf.d/<domain>.conf`:

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html;
    server_name domain.com www.domain.com;
}
```

Verify syntax and reload Nginx:

```bash
sudo nginx -t && sudo nginx -s reload
```

---

## Step 3: Issue Certificate

### 1. Test via Dry Run (Staging)

Verify DNS routing and challenge validation against Let's Encrypt staging servers to avoid
hitting production rate limits:

```bash
sudo certbot --nginx --test-cert -d domain.com -d www.domain.com
```

### 2. Request Production Certificate

Once staging succeeds, issue the trusted production certificate:

```bash
sudo certbot --nginx -d domain.com -d www.domain.com
```

Certbot automatically modifies your Nginx configuration to enable SSL/TLS and configure
redirects. Review the updated configuration and reload:

```bash
sudo nginx -t && sudo nginx -s reload
```

Certificate files are stored in:

```text
/etc/letsencrypt/live/<domain.com>/
```

---

## Step 4: Automated Certificate Renewal

Let's Encrypt certificates are valid for 90 days. Schedule a cron job to check and renew
expiring certificates daily:

1. Open root crontab:

   ```bash
   sudo crontab -e
   ```

2. Add a scheduled job running daily at 12:00 PM:
   ```cron
   0 12 * * * /usr/bin/certbot renew --quiet
   ```

Certbot will automatically renew certificates when fewer than 30 days remain before
expiration.
