# Disabling Foreign Key Constraints in PostgreSQL

Temporarily disable trigger execution (including foreign key checks) on a table during bulk loads or migrations:

```sql
-- Disable foreign key constraints and triggers on a table:
ALTER TABLE table_name DISABLE TRIGGER ALL;

-- Re-enable foreign key constraints and triggers on a table:
ALTER TABLE table_name ENABLE TRIGGER ALL;
```
