# Snap Package Management Commands

Commands for inspecting, aborting, and troubleshooting Ubuntu Snap applications and
services.

---

## Snap Operations & Queries

| Action                                            | Command                    |
| :------------------------------------------------ | :------------------------- |
| **Show running operations / change tasks**        | `snap changes`             |
| **Abort a pending or hung operation**             | `snap abort <ID>`          |
| **List installed snap packages**                  | `snap list`                |
| **Inspect package details (installed or remote)** | `snap info <PACKAGE_NAME>` |

---

## Troubleshooting "Update pending 'APP_NAME' snap"

If a snap fails to update with the error **"Update pending 'APP_NAME' snap"**, close
lingering processes and trigger a manual refresh:

```bash
# Terminate snapd and snap-store background processes
sudo killall -9 snapd
sudo killall -9 snap-store

# Refresh all snaps
sudo snap refresh
```
