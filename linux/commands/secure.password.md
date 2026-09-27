# Secure Password Generation

Generate a cryptographically secure random password using OpenSSL:

```bash
openssl rand 60 | openssl base64 -A
```

- `openssl rand 60`: Generates 60 high-entropy random bytes from `/dev/urandom`.
- `openssl base64 -A`: Encodes the random bytes to base64 on a single line without
  wrapping.
