# Exporting SQL Query Results to CSV in PostgreSQL

Execute within the `psql` interactive console or via client query to dump query results directly to a delimited CSV file with headers:

```sql
COPY (SQL_QUERY) TO '/absolute/path/to/output.csv' WITH CSV DELIMITER ',' HEADER;
```

### Example
```sql
COPY (SELECT id, username, email FROM users WHERE is_active = true)
TO '/tmp/active_users.csv' WITH CSV DELIMITER ',' HEADER;
```
