# Varnish Cache Real-Time Logging (`varnishlog`)

CLI commands for monitoring and filtering real-time HTTP transaction logs in Varnish
Cache.

---

## Commands

### Live Log Stream (All Requests)

```bash
varnishlog
```

### Filter by HTTP Request Method

Filter logs for a specific method (e.g., `PURGE` or `POST`):

```bash
varnishlog -g request -q 'ReqMethod eq "PURGE"'
```

### Filter by HTTP Response Status Code

Filter logs by HTTP response code (e.g., investigating `503 Service Unavailable`):

```bash
varnishlog -q 'RespStatus == 503' -g request
```

> [!NOTE] 
> All `varnishlog` queries stream real-time output from shared memory. Press
> `Ctrl + C` to exit.
