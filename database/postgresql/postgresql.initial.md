# Initial PostgreSQL Transaction Isolation Setup

SQL commands to establish default transaction isolation levels for specific roles and databases.

```sql
-- Set default transaction isolation level for specific database user:
ALTER ROLE db_user
    SET default_transaction_isolation TO 'read committed';

-- Set default transaction isolation level for specific database:
ALTER DATABASE development_db
    SET default_transaction_isolation TO 'read committed';
```
