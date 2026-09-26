# Install PostGIS

PostGIS is an extension which allows working with spatial data in a PostgreSQL database.
Please refer to the [official documentation](https://postgis.net) for complete information on PostGIS usage.

## Installation

1. **Install PostGIS:**

   ```bash
   sudo apt-get install postgis
   ```

2. **Install PostgreSQL-specific packages:**
   
   For each version of PostgreSQL that you have and want to enable PostGIS on, you may also need to execute these commands with the relevant version:

   ```bash
   sudo apt-get install postgresql-{DB_VERSION}-postgis-{LAST_POSTGIS_MAJOR_VERSION}-scripts
   sudo apt install postgresql-{DB_VERSION}-postgis-{LAST_POSTGIS_MAJOR_VERSION}
   ```

   **Example:**

   ```bash
   sudo apt-get install postgresql-14-postgis-3-scripts
   sudo apt install postgresql-14-postgis-3
   ```

## Database Setup and Verification

1. **Enable the Extension:**
   
   Open the database where you want to enable PostGIS and run this query:

   ```sql
   CREATE EXTENSION postgis;
   ```

2. **Check the Installed Version:**
   
   To see the version of installed PostGIS in the database, execute this query:

   ```sql
   SELECT PostGIS_Full_Version();
   ```

3. **List all Available PostGIS Versions:**
   
   To see all installed PostGIS versions available as extensions, execute this query:

   ```sql
   SELECT * FROM pg_available_extensions WHERE name = 'postgis';
   ```
