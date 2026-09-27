# PostgreSQL Backup & Restore Guide (`pg_dump`)

Commands for exporting and restoring PostgreSQL databases, schema structures, and table
subsets.

---

## 1. Exporting Backups (`pg_dump`)

Switch to the `postgres` user before running dumps:

```bash
sudo su - postgres
```

### Full Database Backup (Schema & Data)

```bash
pg_dump -U postgres -d <existing_db_name> -f dump.sql
```

### Specific Tables Backup (Schema & Data)

```bash
pg_dump -U postgres -d <existing_db_name> -t <table1> -t <table2> -f dump.sql
```

### Data Only (No Schema / DDL, using Column Inserts)

```bash
pg_dump -U postgres --column-inserts -a -d <existing_db_name> -f dump.sql
```

### Data Only for Specific Tables

```bash
pg_dump -U postgres --column-inserts -a -t <table1> -t <table2> -d <existing_db_name> -f dump.sql
```

---

## 2. Restoring Backups (`psql`)

1. Ensure the target database exists (or create it: `CREATE DATABASE new_db_name;`).
2. Grant file ownership/read access to the `postgres` user:
   ```bash
   sudo chown $(whoami):postgres dump.sql
   ```
3. Import the dump:
   ```bash
   sudo su - postgres
   psql -U postgres -d <new_db_name> -f dump.sql
   ```
