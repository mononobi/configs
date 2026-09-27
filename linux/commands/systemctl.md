# Systemd Service Management (`systemctl`)

Commands for inspecting, enabling, disabling, and controlling system services.

---

## Service Operations

| Action                             | Command                                                |
| :--------------------------------- | :----------------------------------------------------- |
| **List all enabled services**      | `systemctl list-unit-files --state=enabled --no-pager` |
| **Enable service on system boot**  | `sudo systemctl enable <SERVICE_NAME>`                 |
| **Disable service on system boot** | `sudo systemctl disable <SERVICE_NAME>`                |
| **Start service immediately**      | `sudo systemctl start <SERVICE_NAME>`                  |
| **Stop running service**           | `sudo systemctl stop <SERVICE_NAME>`                   |
| **Restart service**                | `sudo systemctl restart <SERVICE_NAME>`                |
