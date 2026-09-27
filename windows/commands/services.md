# Windows Service Management CLI Commands

Command-line utilities for managing, starting, stopping, and triggering Windows background services via elevated Command Prompt (`cmd.exe`).

---

## Service Lifecycle

```cmd
:: Stop a running service
net stop <SERVICE_NAME>

:: Start a service
net start <SERVICE_NAME>

:: Self-register a service binary
<SERVICE_BINARY> /register

:: Unregister a service binary
<SERVICE_BINARY> /unregister

:: Execute custom service command
<SERVICE_BINARY> /<SERVICE_COMMAND>
```

---

## Service Event Triggers (`sc triggerinfo`)

```cmd
:: Configure trigger to start service based on criteria:
sc triggerinfo <SERVICE_NAME> start/<START_CRITERIA>

:: Configure trigger to stop service based on criteria:
sc triggerinfo <SERVICE_NAME> stop/<STOP_CRITERIA>

:: Delete all configured triggers for a service:
sc triggerinfo <SERVICE_NAME> delete
```
