# Restoring Classic Full Context Menu in Windows 11

Restore the classic Windows 10 full right-click context menu by default (bypassing the trimmed "Show more options" menu).

---

## Command

Open Command Prompt (`cmd.exe`) as **Administrator** and run:

```cmd
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
```

*Restart `explorer.exe` or reboot Windows to apply.*
