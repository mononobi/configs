# Disabling BitLocker Drive Encryption

Decrypt and permanently disable BitLocker on a drive partition using PowerShell.

---

## Command

Launch **PowerShell as Administrator** and execute:

```powershell
Disable-BitLocker -MountPoint "<DRIVE_LETTER>:"
```

### Example (Decrypt C: Drive)

```powershell
Disable-BitLocker -MountPoint "C:"
```

> [!NOTE]
>
> Drive decryption operates asynchronously in the background. The process takes time
> depending on partition size and disk speed; monitor progress using
> `Get-BitLockerVolume`.
