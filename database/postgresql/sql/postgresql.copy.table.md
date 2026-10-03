# PostgreSQL Table Duplication & Data Transfer

SQL patterns for copying table schemas, cloning rows, inserting between tables, and joining
updates.

---

## 1. Clone Table with Data and Structure

```sql
CREATE TABLE new_table AS
TABLE existing_table;
```

---

## 2. Clone Table Structure Only (Empty Table)

```sql
CREATE TABLE new_table AS
TABLE existing_table
WITH NO DATA;
```

---

## 3. Clone Table Structure with Filtered Data

```sql
CREATE TABLE new_table AS
SELECT *
FROM existing_table
WHERE condition;
```

---

## 4. Insert Records from Another Table

```sql
INSERT INTO new_table (col1, col2)
SELECT col1, col2
FROM existing_table
WHERE condition;
```

---

## 5. Update Table Rows from Another Table

```sql
UPDATE new_table
SET column1 = old_table.column1,
    column2 = old_table.column2,
    column3 = old_table.column3
FROM old_table
WHERE old_table.id = new_table.id;
```
