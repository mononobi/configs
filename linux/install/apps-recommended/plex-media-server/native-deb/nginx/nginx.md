# Plex Media Server Nginx Configuration

If you want to put the Plex server behind Nginx to set a custom URL for it, follow these
steps:

1. Open the `/etc/hosts` file:

   ```bash
   sudo nano /etc/hosts
   ```

2. Add your custom URL (e.g., `plex`) to the line containing `localhost`:

   ```
   127.0.0.1 localhost plex
   ```

   > **Note:** You can use any name you want instead of `plex`. However, if you change it
   > here, you must also update the name in the `plex.conf` file accordingly.

3. Save the file and exit the editor.

4. Copy the `plex.conf` file to the Nginx configuration directory:

   ```bash
   sudo cp plex.conf /etc/nginx/conf.d
   ```

5. Check the Nginx configuration for syntax errors:

   ```bash
   sudo nginx -t
   ```

6. Restart the Nginx service and your web browser:

   ```bash
   sudo systemctl restart nginx
   ```
