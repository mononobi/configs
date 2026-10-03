# OSRM Frontend Web UI Setup

Docker Compose deployment for the OSRM web demonstration interface.

---

## References

- **Docker Hub**: [osrm/osrm-frontend](https://hub.docker.com/r/osrm/osrm-frontend)
- **GitHub**: [Project-OSRM/osrm-frontend](https://github.com/Project-OSRM/osrm-frontend)

---

## Configuration

In `docker-compose.yml`, customize `OSRM_BACKEND` to point to your active OSRM backend
endpoint:

```yaml
environment:
  - OSRM_BACKEND=http://routing-backend:5000
```

> [!IMPORTANT]
>
> If the frontend and backend are hosted on separate domains or ports, ensure CORS headers are
> properly handled on the backend or via your reverse proxy.

---

## Launch

```bash
docker-compose up -d
```
