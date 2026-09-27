# Chocolatey Package Manager Installation & Administration

CLI commands to install, update, and manage software packages using Chocolatey on Windows.

---

## 1. Installation

### Option A: Via PowerShell (Administrator)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

### Option B: Via Command Prompt (Administrator)

```cmd
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
```

---

## 2. GUI Client & Maintenance

```powershell
# Install Chocolatey GUI client:
choco install chocolateygui

# Upgrade Chocolatey CLI:
choco upgrade chocolatey

# Upgrade Chocolatey GUI:
choco upgrade chocolateygui

# Check installed version:
choco -v
```

---

## 3. Package Management Commands

```powershell
# List all locally installed Chocolatey packages:
choco list --installed

# Upgrade all installed packages to latest versions:
choco upgrade all -y
```
