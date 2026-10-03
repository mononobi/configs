# OSRM Backend Routing Server Setup

Open Source Routing Machine (OSRM) provides high-performance routing engines for shortest
paths, turn-by-turn navigation, and distance matrices.

---

## References & Map Data

- **Docker Hub**: [osrm/osrm-backend](https://hub.docker.com/r/osrm/osrm-backend)
- **Source Code**: [Project-OSRM/osrm-backend](https://github.com/Project-OSRM/osrm-backend)
- **Map Downloads**: [Geofabrik OpenStreetMap Extracts](https://download.geofabrik.de)

---

## Preparation Steps

1. Create a `data` folder adjacent to `docker-compose.yml`:
   ```bash
   mkdir -p data
   ```
2. Download your `.osm.pbf` map file into `data/`.
3. In all initialization scripts (`1-initialize.sh`, `2-partition.sh`, `3-customize.sh`),
   rename occurrences of `lebanon-latest` to your downloaded map file name.

---

## Processing & Deployment

1. Make initialization scripts executable:

   ```bash
   sudo chmod 775 1-initialize.sh 2-partition.sh 3-customize.sh
   ```

2. Execute scripts in sequence, waiting for each step to finish:

   ```bash
   ./1-initialize.sh
   ./2-partition.sh
   ./3-customize.sh
   ```

3. Monitor container processing logs:

   ```bash
   docker logs -f <CONTAINER_ID>
   ```

4. Once data preparation completes, launch the routing service:
   ```bash
   docker-compose up -d
   ```

> [!NOTE]
>
> This container runs the standalone OSRM routing daemon. A reverse proxy (e.g., Nginx) is
> recommended for production deployments.
