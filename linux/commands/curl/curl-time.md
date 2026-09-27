# cURL Response Time Formatting Template

A timing format string for `curl` to profile latency breakdown across connection phases
(DNS lookup, TCP connect, TLS handshake, transfer start, and total elapsed duration).

## Timing Format Template

Save this format string in a file named `curl-time.txt`:

```text
     time_namelookup:  %{time_namelookup}s\n
        time_connect:  %{time_connect}s\n
     time_appconnect:  %{time_appconnect}s\n
    time_pretransfer:  %{time_pretransfer}s\n
       time_redirect:  %{time_redirect}s\n
  time_starttransfer:  %{time_starttransfer}s\n
                     ----------\n
          time_total:  %{time_total}s\n
```

## Metric Descriptions

- `time_namelookup`: Elapsed time from request start until DNS name resolution completed.
- `time_connect`: Elapsed time until remote TCP connection established.
- `time_appconnect`: Elapsed time until SSL/TLS handshake completed.
- `time_pretransfer`: Elapsed time until file transfer was about to begin.
- `time_redirect`: Total elapsed time across all redirection steps before final
  transaction.
- `time_starttransfer`: Time until the first byte was about to be transferred (Time To
  First Byte - TTFB).
- `time_total`: Total duration of the complete operation.

## Usage Example

```bash
curl -w "@curl-time.txt" -o /dev/null -s https://example.com/api/info
```
