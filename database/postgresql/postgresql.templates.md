# PostgreSQL Template Databases

Understanding template databases in PostgreSQL:

- **`template0`**: A pristine, immutable system template. Use this when creating databases
  that must remain completely independent of any customizations added to `template1`.
- **`template1`**: The default base template. Any tables, extensions, data types, or
  schemas created in `template1` are automatically inherited by all newly created
  databases.
