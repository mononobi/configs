# Install pgAdmin 4 (Local Version via APT)

> **Note:** You can install the normal version using the Ubuntu package manager. However, it is recommended to use the `pgadmin4-local` script to run it and prevent further problems.
> Make sure you have installed PostgreSQL before proceeding.

## Installation Steps

1. **Install the public key for the repository** (if not done previously):

   ```bash
   sudo curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add
   ```

2. **Create the repository configuration file:**

   ```bash
   sudo sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
   ```

3. **Install pgAdmin 4:**

   ```bash
   sudo apt-get install pgadmin4
   ```

## Post-Installation Setup

1. **Copy the local script:**

   ```bash
   sudo cp pgadmin4-local /usr/local/sbin
   ```

2. **Set permissions and ownership:**
   
   > **Note:** Replace `YOUR_USER:YOUR_USER` with your actual username and group.

   ```bash
   sudo chmod 777 /usr/local/sbin/pgadmin4-local
   sudo chown YOUR_USER:YOUR_USER /usr/local/sbin/pgadmin4-local
   ```

3. **Configure server mode:**
   
   Change `SERVER_MODE=False` in `/usr/share/pgadmin4/web/config.py`.

4. **Create cache directory:**
   
   Execute the following command:

   ```bash
   sudo mkdir /var/cache/pgadmin
   ```

> **Tip:** You can now put `pgadmin-local` into your startup commands to make pgAdmin 4 available on boot.
