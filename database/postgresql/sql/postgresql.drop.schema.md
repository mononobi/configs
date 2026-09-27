# Recreating the PostgreSQL Public Schema

Completely purge and recreate a clean `public` schema and restore default permissions:

```bash
sudo su - postgres
psql -U postgres
```

Execute SQL:

```sql
-- Drop schema and all cascaded objects:
DROP SCHEMA public CASCADE;

-- Recreate empty schema:
CREATE SCHEMA public;

-- Restore standard permissions:
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
```
