# Recurring Command Execution with `watch`

Execute a command or script repeatedly at a fixed interval to monitor output changes in real
time.

## Syntax

```bash
watch -n <SECONDS> <COMMAND_OR_SCRIPT>
```

## Examples

```bash
# Run a shell script every 10 seconds:
watch -n 10 script.sh

# Run a Python program every 25 seconds:
watch -n 25 python main.py
```
