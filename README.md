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
- `apps-server/`: Headless server profiles and orchestration. Instead of duplicating
  scripts, it maintains a curated list of tools from `apps-recommended` and `apps-extra`
  and installs them using `require_app` (though custom scripts can also live here).
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
7. **Single Upfront APT Update**: Batch runners perform a single `apt update` at the start
   and pass `--no-update` to every subscript by default. This avoids redundant index
   downloads for each app, unless an app adds a custom repository that requires refreshing.

---

## Shared Utilities & Dependency Management (`utils.sh`)

The framework provides common helpers in `linux/install/utils.sh` to keep individual
scripts minimal, robust, and DRY:

### 1. `require_app <app_name> [category] [extra_args...]`
Resolves and executes an application installer on demand:
- **Flexible Category**: Can target any category folder (e.g., `apps-recommended`,
  `apps-extra`, or any custom category like `apps-custom`).
- **Default Fallback**: If `category` is omitted, checks `apps-recommended` then
  `apps-extra`.
- **Deduplication**: Scripts inspect if a command exists before requiring it:
  ```bash
  if ! command -v flatpak >/dev/null 2>&1; then
      require_app "flatpak" "apps-recommended"
  fi
  ```
- **Flag Propagation**: Global flags such as `--no-update` are forwarded automatically.

### 2. `ensure_local_bin_in_path`
Ensures `~/.local/bin` exists, exports it to current process `$PATH`, and permanently
persists it to `~/.bashrc`, `~/.zshrc`, and `~/.profile` if not already present.

### 3. GNOME Extension Helpers
- **`install_gnome_extension <uuid> [display_name]`**: Queries extensions.gnome.org API
  for the host GNOME Shell version, downloads the candidate archive, inspects its
  `metadata.json` to verify actual Shell compatibility and version before installing,
  compiles schemas, and enables the extension.
- **`compare_extension_version <zip_path> [uuid]`**: Compares downloaded extension version
  against the installed copy to avoid downgrading or unnecessary reinstallations.
- **`check_extension_archive_compatibility <zip_path>`**: Inspects `metadata.json` inside
  downloaded zip to confirm host GNOME Shell version compatibility before installation
  (critical because the GNOME API falls back to the latest build if unsupported).

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

### Creating a Custom Category Folder

The runner framework is fully category-agnostic. You can add a completely new folder
next to the existing categories (e.g., `linux/install/apps-dev` or `apps-workstation`):

1. Create your custom directory:
   ```bash
   mkdir -p linux/install/apps-dev/my-custom-tool
   ```
2. Place an installer script inside (e.g., `install.my-custom-tool.sh`).
3. Run the entire category using `installer.sh`:
   ```bash
   ./linux/install/installer.sh apps-dev
   ```
4. Other scripts can depend on tools in your custom category via `require_app`:
   ```bash
   require_app "my-custom-tool" "apps-dev"
   ```

The custom category inherits all framework features: automatic script discovery,
per-subfolder execution context, `sudo` keepalive, `ignore` file skipping, `--no-update`
forwarding, and summary diagnostics.

### Server Orchestration (`apps-server`)

The `linux/install/apps-server/` directory is designed for headless servers and VMs.
Rather than duplicating installer scripts:
- **Curated Manifest**: Defines an array (`SERVER_APPS`) of server packages (Docker,
  Git, Nginx, Redis, Python, UFW server rules, etc.).
- **Zero Duplication**: Installs each app via `require_app`, reusing the existing
  recipes from `apps-recommended/` and `apps-extra/`. Any fix or improvement to an app
  recipe instantly benefits both desktop and server setups.
- **Custom Scripts Supported**: While primarily a profile orchestrator, custom
  server-only scripts and guides can also live directly in `apps-server/` when needed.
- **Flexible Invocations**: You can run the entire server suite, or append additional
  app names as arguments (arguments are appended to `SERVER_APPS`, not overriding it):
  ```bash
  # Install the default server profile
  ./linux/install/apps-server/install-server-apps.sh

  # Install the default server profile PLUS extra applications
  ./linux/install/apps-server/install-server-apps.sh fail2ban postgresql
  ```
  *(To install an individual tool by itself without the rest of the server suite, run*
  *its script directly as shown in Section 2).*

---

## How to Install What You Want

You can run entire suites or install individual applications on demand.

### 1. Batch Installation

> **Note**: Batch scripts automatically pass `--no-update` to each installer so
> `apt update` only runs once at the beginning, unless an app adds a custom repository.

Install all recommended applications:
```bash
./linux/install/install-recommended.sh
```

Install extra applications:
```bash
./linux/install/install-extra.sh
```

Install the curated server suite:
```bash
./linux/install/apps-server/install-server-apps.sh
```

Run any custom category directory using the generic runner:
```bash
./linux/install/installer.sh apps-custom
```

### 2. Individual (Single-App) Installation

Every application script is standalone and can be run independently at any time:
```bash
# Install Docker
cd linux/install/apps-recommended/docker && ./install.docker.sh

# Install VS Code & skip upfront APT repository update to save time
cd linux/install/apps-recommended/vscode && ./install.vscode.sh --no-update

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
