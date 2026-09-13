# Configs & Setup Framework

A curated collection of production-tested configurations, setup guidelines, and
automation scripts for Linux environments, development tools, databases, and IDEs.

---

## The `linux/install` Framework

The `linux/install/` directory provides a modular, automated system setup framework
designed primarily for Ubuntu/Debian systems. It enables consistent, reproducible,
and unattended installation of development stacks, desktop applications, CLI tools,
and system services.

### Directory Structure

- `apps-recommended/`: Essential tools, core runtimes, CLI utilities, and everyday
  development applications (e.g., Docker, Git, Python, VS Code, Flatpak, UFW).
- `apps-extra/`: Optional or specialized desktop software (e.g., Brave, Discord,
  Blender, Thunderbird).
- `apps-server/`: Dedicated server environments, services, and stack configurations.
- `apps-not-needed/`: Deprecated or redundant alternatives kept for reference.
- `commands/`, `themes/`, `updates-and-configs/`: Standalone shell scripts, desktop
  themes, and update automation.

---

## How Automation Works

The framework centers around a modular runner and individual self-contained recipes:

1. **Self-Contained Recipes**: Each application resides in its own subfolder containing
   its installation script (`*.sh`), documentation, and local assets.
2. **Context Preservation**: Scripts are executed from within their own subdirectories,
   ensuring that relative paths to local assets or config files always resolve cleanly.
3. **User-Space Safety**: The batch installer must be run as a regular user, never via
   `sudo`. Subscripts invoke `sudo` internally only when administrative privileges are
   required.
4. **Credential Keepalive**: The batch runner initializes `sudo` credentials upfront
   and maintains a background keepalive loop, preventing repetitive password prompts.
5. **Selective Skipping via `ignore`**: Any subfolder that contains an `ignore` file is
   automatically skipped during batch installations.
6. **Execution Logging & Summary**: The runner captures stdout/stderr per application,
   reports clear visual progress, and prints an end-of-run summary with exact failure
   diagnostics if an error occurs.

---

## Managing Dependencies (`require_app`)

Applications often depend on shared utilities (such as Flatpak, Python, Curl, or Unzip).
The framework avoids duplicate installations or hardcoded package managers through a
shared helper located in `linux/install/utils.sh`:

```bash
require_app <app_name> [category] [extra_args...]
```

- **Lookup Order**: Checks `apps-recommended/<app_name>`, then `apps-extra/<app_name>`.
- **Deduplication**: Scripts inspect if a command exists before requiring it:
  ```bash
  if ! command -v flatpak >/dev/null 2>&1; then
      require_app "flatpak" "apps-recommended"
  fi
  ```
- **Flag Propagation**: Global flags such as `--no-update` are forwarded automatically
  to satisfy nested dependencies without redundant package index updates.

---

## Application Types & Extensibility

The framework supports multiple installation strategies across different tool types:

- **APT Packages**: Standard packages and custom APT repositories/PPAs with modern
  keyring handling (placed under `/etc/apt/keyrings/`).
- **Flatpak Apps**: Sandboxed desktop applications installed from Flathub.
- **Direct Binaries & Tarballs**: Tools fetched directly from GitHub releases or official
  mirrors, extracted into `~/.local/bin` (which is ensured in `PATH`).
- **GNOME Extensions**: Extension zips unpacked into `~/.local/share/gnome-shell/extensions`,
  with GSettings schemas compiled and configured.
- **System Rules & Configs**: Configuration-only scripts (such as UFW firewall rules
  for servers or local networks).

### Adding a New Application

To add a new tool or application:

1. Create a folder inside `apps-recommended/` or `apps-extra/`:
   ```bash
   mkdir -p linux/install/apps-recommended/my-tool
   ```
2. Add an installation script `install.my-tool.sh` inside that folder.
3. Use the standard boilerplate:
   ```bash
   #!/usr/bin/env bash
   set -euo pipefail

   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   source "${SCRIPT_DIR}/../../utils.sh"

   # Parse --no-update and -h/--help options
   # Resolve dependencies via require_app if needed
   # Install tool and apply configurations
   ```
4. Make the script executable: `chmod +x install.my-tool.sh`.
5. (Optional) If the script should only run on demand and not during batch runs,
   create an empty `ignore` file: `touch linux/install/apps-recommended/my-tool/ignore`.

---

## How to Install What You Want

You can run entire suites or install individual applications on demand.

### 1. Batch Installation

Run all recommended applications:
```bash
./linux/install/install-recommended.sh
```

Skip upfront APT repository update to save time:
```bash
./linux/install/install-recommended.sh --no-update
```

Install optional/extra applications:
```bash
./linux/install/install-extra.sh
```

Run a custom category directory using the generic runner:
```bash
./linux/install/installer.sh apps-server
```

### 2. Individual (Single-App) Installation

Every application script is standalone and can be run independently at any time:
```bash
# Install Docker
cd linux/install/apps-recommended/docker && ./install.docker.sh

# Install VS Code
cd linux/install/apps-recommended/vscode && ./install.vscode.sh

# Configure UFW firewall rules for a local network
cd linux/install/apps-recommended/ufw-rules-local && ./set.ufw.rules.local.sh
```

### 3. Inspecting Ignored Applications

To see all folders marked with an `ignore` file:
```bash
./linux/install/list-ignored.sh
```

To output plain names for scripting:
```bash
./linux/install/list-ignored.sh --names-only
```
