# Plex Media Server Installation and Configuration (Native .deb)

> [!NOTE]  
>
> - Replace `mono` with your own system username throughout this guide.
> - Replace `/home/mono/.plex` with your desired root path for custom Plex data storage.

---

## 1. Installation

1. Download the latest Plex Media Server `.deb` package from the
   [official Plex Downloads page](https://www.plex.tv/media-server-downloads/).
2. Navigate to your download directory and install the package:
   ```bash
   sudo dpkg -i file_name.deb
   ```
3. Check the service status to verify it is active:
   ```bash
   sudo systemctl status plexmediaserver
   ```
4. If the service is not running, start it manually:
   ```bash
   sudo systemctl start plexmediaserver
   ```
5. Enable the service to launch automatically on system boot:
   ```bash
   sudo systemctl enable plexmediaserver
   ```

---

## 2. Automatic Updates via APT

1. List the installed files to identify the Plex APT source list configuration:

   ```bash
   sudo dpkg -L plexmediaserver
   ```

   The source list file is typically located at:
   `/etc/apt/sources.list.d/plexmediaserver.list`

2. Open the file above in an editor and uncomment the last line.

3. Import the signing key if running older distributions:

   > [!IMPORTANT]  
   >
   > Run the following command only if you are **not** on Ubuntu 20.04+ or Debian 10+:

   ```bash
   wget -q https://downloads.plex.tv/plex-keys/PlexSign.key -O - | sudo tee /etc/apt/trusted.gpg.d/plexmediaserver.asc
   ```

4. Refresh repository indexes:
   ```bash
   sudo apt update
   ```
   Plex Media Server will now be updated automatically alongside standard OS package
   upgrades.

---

## 3. Relocating Metadata & Restoring Data

Follow these steps if you want to store all Plex metadata and indices in a custom
directory (e.g., `/home/mono/.plex`), or if you are restoring existing metadata after
reinstalling the operating system.

1. **Stop the Plex Media Server service:**

   ```bash
   sudo systemctl stop plexmediaserver
   ```

2. **Create target directories (for clean/initial installations):** If this is a new setup
   without existing metadata, create the required folder hierarchy:

   ```bash
   mkdir -p /home/mono/.plex/plexmediaserver/Library/'Application Support'
   mkdir /home/mono/.plex/tmp
   ```

3. **Set permissions and ownership:** Ensure your user account owns the custom data
   directory with appropriate permissions:

   ```bash
   sudo chown -R mono:mono /home/mono/.plex
   sudo chmod -R 775 /home/mono/.plex
   ```

4. **Remove the default metadata directory:**

   ```bash
   sudo rm -r /var/lib/plexmediaserver
   ```

5. **Deploy the systemd drop-in override:** Copy `override.conf` into the systemd service
   override directory (remember to adjust `mono` and `/home/mono/.plex` inside
   `override.conf` to match your actual username and root path):

   ```bash
   sudo mkdir -p /etc/systemd/system/plexmediaserver.service.d
   sudo cp override.conf /etc/systemd/system/plexmediaserver.service.d
   sudo systemctl daemon-reload
   ```

6. **Start and re-enable the service:**
   ```bash
   sudo systemctl enable plexmediaserver
   sudo systemctl start plexmediaserver
   ```

---

## 4. Firewall & Network Settings

1. **Open the default Plex port in UFW:**

   ```bash
   sudo ufw allow 32400
   ```

2. **Configure Allowed Client Networks:** In the Plex Web interface, navigate to
   **Settings > Network** and add client IPs allowed to connect to the server without
   authentication. For example, if your default gateway is `192.168.178.1`, add:
   ```text
   localhost, 127.0.0.1, 192.168.178.0/24
   ```

---

## 5. Performance Optimization: Transcoding in RAM

If the host system running Plex has **8 GB or more of RAM**, you can relocate temporary
transcode directories to shared memory (`/dev/shm`) for faster disk I/O and reduced SSD
wear:

1. Open the Plex Web interface.
2. Go to **Settings > Transcoder**.
3. Set the following options:
   - **Transcoder temporary directory:** `/dev/shm/plex`
   - **Downloads temporary directory:** `/home/mono/.plex/tmp/downloads`

---

## 6. Default System Paths Reference

| Component                            | Path                                                          |
| :----------------------------------- | :------------------------------------------------------------ |
| **Default Metadata & Index Folder**  | `/var/lib/plexmediaserver`                                    |
| **Executables Directory**            | `/usr/lib/plexmediaserver`                                    |
| **Systemd Service Unit**             | `/lib/systemd/system/plexmediaserver.service`                 |
| **Systemd Service Drop-In Override** | `/etc/systemd/system/plexmediaserver.service.d/override.conf` |
