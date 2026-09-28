# Running Background Processes with `nohup`

Instructions for running detached background commands that continue running after terminal
closure.

> [!TIP]
>
> The recommended tool for long-running processes is `tmux` (or `screen`). `nohup` can
> occasionally be interrupted or terminate unexpectedly if the parent shell exits
> abnormally.

---

## 1. Launch a Detached Background Process

To launch a process in the background detached from the current shell session:

```bash
nohup COMMAND &
```

### Example

```bash
nohup python script.py &
```

- Runs the command asynchronously in the background.
- Preserves execution even if the terminal window is closed.
- Standard output and standard error are automatically redirected to `nohup.out` in the
  directory where the command was initiated.

---

## 2. Locate the Running Process

Search for the running process by name to retrieve its Process ID (PID):

```bash
ps -aux | grep <COMMAND_NAME>
```

### Example

```bash
ps -aux | grep python
```

---

## 3. Terminate the Background Process

Kill the background process using its PID:

```bash
kill -9 <PROCESS_ID>
```

### Example

```bash
kill -9 56532
```
