# Secure Copy (`scp`) Remote File Transfer

Transfer files between a local machine and remote servers over SSH.

---

## Download from Remote Server to Local Machine

```bash
# Using standard port (22):
scp remote_user@remote_server:/remote/path/file.txt /local/path/

# Using custom SSH port:
scp -P <PORT_NO> remote_user@remote_server:/remote/path/file.txt /local/path/
```

---

## Upload from Local Machine to Remote Server

```bash
# Using standard port (22):
scp /local/path/file.txt remote_user@remote_server:/remote/path/

# Using custom SSH port:
scp -P <PORT_NO> /local/path/file.txt remote_user@remote_server:/remote/path/
```
