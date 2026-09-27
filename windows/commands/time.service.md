# Windows Time Service (`w32time`) Synchronization & Triggers

Commands for repairing, re-registering, and forcing synchronization of the Windows Time
service (`w32time`) via elevated Command Prompt (`cmd.exe`).

---

## Re-Register & Resync Time Service

```cmd
:: Stop service and re-register binaries
net stop w32time
w32tm /unregister
w32tm /register

:: Restart service and force immediate NTP resynchronization
net start w32time
w32tm /resync
```

---

## Network State Triggers

Configure the time service to automatically start when connected to a network and stop on
network disconnect:

```cmd
:: Add network state triggers
sc triggerinfo w32time start/networkon stop/networkoff

:: Remove all triggers
sc triggerinfo w32time delete
```
