# GNU Screen Terminal Multiplexer Cheat Sheet

Commands and keybindings to manage persistent, detach-safe terminal sessions with GNU
Screen.

---

## Command-Line Usage

| Action                                    | Command             |
| :---------------------------------------- | :------------------ |
| **Create a named session**                | `screen -S <name>`  |
| **Attach to existing session**            | `screen -rx <name>` |
| **Attach and force-detach other clients** | `screen -rd <name>` |

---

## Screen Keybindings

All shortcuts within Screen are triggered by the prefix key `Ctrl + A`:

| Key Sequence          | Action                                     |
| :-------------------- | :----------------------------------------- |
| `Ctrl + A`, then `d`  | Detach from the active screen session      |
| `Ctrl + A`, then `c`  | Create a new window / page within session  |
| `Ctrl + A`, then `k`  | Kill the current screen window and session |
| `Ctrl + A`, then `n`  | Navigate to the next window                |
| `Ctrl + A`, then `p`  | Navigate to the previous window            |
| `Ctrl + A`, then `\|` | Split the screen vertically                |
