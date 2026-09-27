# Process & Port Management Cheat Sheet

Commands for querying running processes, monitoring system resources, and terminating
processes on specific network ports.

| Action                                    | Command                         |
| :---------------------------------------- | :------------------------------ |
| **Find processes listening on a port**    | `fuser -n tcp <PORT>`           |
| **Kill all processes on a port**          | `fuser -n tcp -k <PORT>`        |
| **Kill process by PID**                   | `kill -9 <PID>`                 |
| **Find active listening ports**           | `netstat -tuln \| grep <PORT>`  |
| **Find connections by process name**      | `netstat -tulnp \| grep <NAME>` |
| **Kill all processes with matching name** | `killall -9 <PROCESS_NAME>`     |
| **Monitor running processes & resources** | `top`                           |
| **Check RAM & Swap usage**                | `free -h`                       |
| **Display process hierarchy for name**    | `ps -axjf \| grep <NAME>`       |
| **Display process info for specific PID** | `ps -jf -p <PID>`               |
