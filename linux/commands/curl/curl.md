# cURL API Testing & Latency Benchmarking

Templates and examples for issuing authenticated API requests and measuring request
latency with `curl`.

---

## 1. Authenticated API Requests with Bearer Token

### Template

```bash
curl -s SERVICE_ENDPOINT -H "Accept: application/json" -H "Authorization: Bearer TOKEN"
```

### Example

```bash
curl -s https://example.com/api/info \
  -H "Accept: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9DeyJpZCI6NSwibmFtZSI6Ik1vbm8gT"
```

---

## 2. Measuring Request Execution Time

Use the timing configuration from
[curl-time.txt](file:///home/mono/Workspace/configs/linux/commands/curl/curl-time.txt) (or
[curl-time.md](file:///home/mono/Workspace/configs/linux/commands/curl/curl-time.md)) to
profile connection phases.

### Template

```bash
curl -w "@curl-time.txt" -o /dev/null -s SERVICE_ENDPOINT -H "Accept: application/json" -H "Authorization: Bearer TOKEN"
```

### Example

```bash
curl -w "@curl-time.txt" -o /dev/null -s https://example.com/api/info \
  -H "Accept: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9DeyJpZCI6NSwibmFtZSI6Ik1vbm8gT"
```

> [!NOTE] Ensure that `curl-time.txt` is located in your current working directory, or
> specify its absolute path (e.g.,
> `-w "@/home/mono/Workspace/configs/linux/commands/curl/curl-time.txt"`).
