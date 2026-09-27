# HTTP Load Testing with `wrk`

High-performance HTTP benchmarking using `wrk`.

---

## Benchmarking Commands

### 1. Standard GET Request Benchmark

```bash
wrk -t 2 -c 2 -d 10 https://example.com/api/users/
```

### 2. Custom Benchmark (POST, PUT, Custom Headers) via Lua Script

```bash
wrk -t 2 -c 2 -d 10 -s data.lua https://example.com/api/users/1/
```

### Parameter Reference

- `-t 2`: Number of worker threads.
- `-c 2`: Total number of open HTTP connections kept active.
- `-d 10`: Duration of the benchmark test in seconds.
- `-s data.lua`: Custom Lua script defining request payloads, headers, or methods
  (mandatory for non-GET requests).

---

## Structure of `data.lua`

Create `data.lua` in the working directory to customize the HTTP method, payload, and
headers:

```lua
wrk.method = "PUT"
wrk.body = '{"input1": "2020-01-26T00:00:00+08:00", "input2": 100}'
wrk.headers["Content-Type"] = "application/json"
```
