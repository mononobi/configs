# PostgreSQL Installation

## New Installation

Run the following commands to add the PostgreSQL repository and install it:

```bash
sudo apt update
sudo apt install -y wget
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc
RELEASE=$(lsb_release -cs)
echo "deb [arch=amd64] http://apt.postgresql.org/pub/repos/apt/ ${RELEASE}"-pgdg main | sudo tee /etc/apt/sources.list.d/pgdg.list
cat /etc/apt/sources.list.d/pgdg.list

sudo apt update
```

Change `VERSION` to the version you want to install (e.g., `17`):

```bash
sudo apt -y install postgresql-VERSION
```

After the installation has finished, you can copy the provided `db.conf` file into the
PostgreSQL `conf.d` folder to modify the required configs:

```bash
sudo cp db.conf /etc/postgresql/VERSION/main/conf.d
```

## Setup Independent Database User Login (Not Recommended)

> **Warning:** This will prevent any non-interactive access to the database (such as cronjobs,
> replication, etc.).

If you want to login as any user in the database without having the relevant user in your Linux
system, open the `pg_hba.conf` file:

```bash
sudo nano /etc/postgresql/VERSION/main/pg_hba.conf
```

Replace this line:

```text
local   all             postgres                                peer
```

With this line:

```text
local   all             postgres                                md5
```

And replace this line:

```text
local   all             all                                     peer
```

With this line:

```text
local   all             all                                     md5
```

Save the file. Now you can login to any database user without the need to switch to the
relevant user in the terminal:

```bash
psql -U DB_USERNAME
```

For example:

```bash
psql -U postgres
```

## Post-Installation Setup

Execute this to set a password for the `postgres` user on the database:

```bash
sudo su - postgres
psql -c "alter user postgres with password 'PASSWORD_HERE'"
```

Restart the PostgreSQL service:

```bash
sudo systemctl restart postgresql
```

Check that PostgreSQL is up and running:

```bash
sudo ss -tunelp | grep 5432
sudo systemctl status postgresql
```

If you didn't change the `pg_hba.conf` file, you can connect to PostgreSQL using the terminal
this way. Note that you should have a relevant user with the same username as the database user
on your Linux system:

```bash
sudo su DB_USERNAME
psql -U DB_USERNAME
```

For example:

```bash
sudo su postgres
psql -U postgres
```
