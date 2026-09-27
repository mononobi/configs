# MinIO Server & Image Proxy Integration

Docker Compose reference for serving and dynamically transforming objects through an image
proxy.

---

## Image Proxy URL Pattern

Access resized, cropped, or transformed images stored in MinIO through the image proxy:

```text
{PROXY_URL:PROXY_PORT}/{SIZE_OPTIONS}/{MINIO_URL:MINIO_PORT}/{IMAGE_PATH}
```

### Example

```text
http://localhost:8080/x0.9/http://nginx:9000/images/ucl.png
```

---

## Reference Repositories

- **Image Proxy**: [willnorris/imageproxy](https://github.com/willnorris/imageproxy)
- **MinIO Server**: [minio/minio](https://github.com/minio/minio)
- **MinIO Python Client**: [minio/minio-py](https://github.com/minio/minio-py)
- **MinIO Client CLI (`mc`)**: [minio/mc](https://github.com/minio/mc)
