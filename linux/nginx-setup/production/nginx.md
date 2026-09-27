# Production Nginx Application Server Setup

Guidelines for deploying a production web application behind Nginx reverse proxy.

---

## Configuration Reference

- Use the comprehensive, production-tuned template `app.conf` in this directory as your
  baseline.
- For SSL/TLS certificate setup and Let's Encrypt automation, refer to the
  [SSL Certificate Guide](file:///home/mono/Workspace/configs/linux/ssl-certificate/production/create.certificate.md).

---

## Deployment Steps

1. **Deploy Configuration**:

   ```bash
   sudo cp app.conf /etc/nginx/conf.d/
   ```

2. **Test Syntax**:

   ```bash
   sudo nginx -t
   ```

3. **Apply Changes**: Reload Nginx without dropping active connections:
   ```bash
   sudo systemctl restart nginx
   # or
   sudo nginx -s reload
   ```
