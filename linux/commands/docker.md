# Docker & Docker Compose Cheat Sheet

Quick reference for Docker containers, images, volumes, Compose services, and private
registry management.

---

## Docker Compose

| Command                              | Description                                                                 |
| :----------------------------------- | :-------------------------------------------------------------------------- |
| `docker-compose up -d`               | Start services defined in compose file in daemon (background) mode          |
| `docker-compose up --remove-orphans` | Start services and remove containers for services no longer in Compose file |
| `docker-compose ps`                  | List status of containers managed by current Compose project                |

---

## Containers & Images

| Command                                                 | Description                                                        |
| :------------------------------------------------------ | :----------------------------------------------------------------- |
| `docker ps` / `docker container ls`                     | List all running containers                                        |
| `docker container rm <CONTAINER_ID_OR_NAME>`            | Remove a stopped container                                         |
| `docker image rm <IMAGE_ID_OR_NAME>`                    | Remove a Docker image                                              |
| `docker image rm -f <IMAGE_ID_OR_NAME>`                 | Force remove a Docker image                                        |
| `docker images -f dangling=true`                        | List untagged/dangling images                                      |
| `docker images purge` / `docker image prune -a`         | Remove unused and dangling images                                  |
| `docker inspect <CONTAINER_ID_OR_NAME>`                 | Display low-level JSON configuration of a container                |
| `docker exec -it <CONTAINER_ID_OR_NAME> /bin/bash`      | Open an interactive Bash shell inside a running container          |
| `docker exec -it <CONTAINER_ID_OR_NAME> <COMMAND>`      | Execute an ad-hoc command inside a container                       |
| `docker build --tag <NAME>:<TAG> .`                     | Build an image from a `Dockerfile` in the current directory        |
| `docker inspect <CONTAINER> \| grep com.docker.compose` | Find Compose file associations of a running container              |
| `docker system prune`                                   | Remove unused containers, networks, images, and dangling resources |

---

## Volumes

| Command                                     | Description                                            |
| :------------------------------------------ | :----------------------------------------------------- |
| `docker volume ls`                          | List all existing Docker volumes                       |
| `docker volume inspect <VOLUME_NAME>`       | Display details and filesystem mount point of a volume |
| `docker volume create --name <VOLUME_NAME>` | Create a named volume                                  |
| `docker volume rm <VOLUME_NAME>`            | Delete a specified volume                              |
| `docker volume prune`                       | Delete all unused local volumes                        |

---

## System Storage Paths

- **Docker Data Directory**: `/var/lib/docker/`
- **Mounted Volumes Storage**: `/var/lib/docker/volumes/`

---

## Docker Registry Operations

### Tag and Push Image to Private Registry

```bash
# Pull remote image:
docker pull remote.registry.com/url/NAME:TAG

# Re-tag for target registry:
docker tag remote.registry.com/url/NAME:TAG local.registry.com/NEW_NAME:NEW_TAG

# Push to private registry:
docker push local.registry.com/NEW_NAME:NEW_TAG
```

### Query Image Catalog in Private Registry

```bash
curl -u USER:PASS -X GET https://local.registry.com:PORT/v2/_catalog
curl -u USER:PASS -X GET https://local.registry.com/v2/_catalog
```
