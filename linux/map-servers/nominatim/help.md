# Nominatim Geocoding Server Setup (Docker Compose)

Nominatim provides search and reverse geocoding (converting addresses/names to geographical
coordinates and vice-versa).

---

## References & Map Data

- **Official Docker Container Documentation**:
  [mediagis/nominatim-docker](https://github.com/mediagis/nominatim-docker)
- **OpenStreetMap Data Extracts**: Download `.osm.pbf` extracts from
  [Geofabrik](https://download.geofabrik.de)

---

## Configuration Guidelines (`docker-compose.yml`)

1. **Volume Mounts**: Update host mount paths (`host:container`) to existing directories on
   your host server.
2. **Database Credentials**: Replace `DATABASE_PASSWORD_OF_YOUR_CHOICE` with a strong password.
3. **Map Source (`PBF_URL` vs `PBF_PATH`)**:
   - To download during initialization: Specify `PBF_URL` and `REPLICATION_URL`.
   - If pre-downloaded: Comment out `PBF_URL`, uncomment `PBF_PATH`, and mount the directory
     containing the file.
   - _Note: Do not configure both `PBF_URL` and `PBF_PATH` simultaneously._
4. **Shared Memory (`shm_size`)**: Recommended to set to **half of available system RAM**.
5. **Import Styles (`IMPORT_STYLE`)**:
   - `admin`: Administrative boundaries and places only.
   - `street`: Administrative boundaries, places, and streets.
   - `address`: All data required for address computation down to house number level.
   - `full` _(Default)_: Full dataset including points of interest.
   - `extratags`: Full dataset plus OpenStreetMap tags preserved in the `extratags` column.
6. **Continuous Replication**: Uncomment `REPLICATION_URL` and `REPLICATION_RECHECK_INTERVAL`
   to enable ongoing updates. _(Note: Significantly increases storage usage)._

---

## Deployment & Optimization

### Start the Service Stack

Starts Apache web server, PostgreSQL/PostGIS, and Nominatim:

```bash
docker-compose up -d
```

### Post-Import Storage Optimization (Freeze Database)

If continuous updates are **not** needed, you can reclaim over 50% of the PostgreSQL database
storage by freezing the imported data once processing finishes and queries start serving:

1. Open an interactive shell inside the container:

   ```bash
   docker exec -it nominatim /bin/bash
   ```

2. Switch to the `postgres` user:

   ```bash
   su postgres
   ```

3. Navigate to the Nominatim directory and run `freeze`:

   ```bash
   cd /nominatim
   nominatim freeze
   ```

   _(Any error regarding deleting the flatnode file may be safely ignored)._

4. Exit the container:
   ```bash
   exit
   exit
   ```
