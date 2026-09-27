# PostgreSQL Unique Constraints vs. Unique Indexes

SQL syntax for enforcing column uniqueness.

---

## Method 1: Unique Constraint (Recommended)

Standard SQL table constraint:

```sql
ALTER TABLE table_name
ADD CONSTRAINT constraint_name UNIQUE (column1, column2);
```

---

## Method 2: Unique Index

Direct unique index creation:

```sql
CREATE UNIQUE INDEX index_name
ON table_name (column1, column2);
```
