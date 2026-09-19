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

The framework provides shared helpers in `linux/install/utils.sh` to keep individual
scripts minimal, robust, and DRY. All installer scripts source this file.

### 1. `require_app [OPTIONS] <app1> [app2...]`
Resolves and executes application installers on demand:
- **Multiple Apps in One Call**: Accepts one or more application names separated by
  spaces (e.g., `require_app curl ca-certificates gnupg`). Always combine dependencies
  into a single call rather than repeating `require_app` across multiple lines.
- **Automatic 3-Tier Fallback**: Automatically searches for recipes across categories in
  priority order:
  1. `apps-recommended/`
  2. `apps-extra/`
  3. `apps-not-needed/`
  Halts resolution as soon as a matching installer script is found. Never pass default
  category names (`apps-recommended`, `apps-extra`, `apps-no-needed`) to `require_app` — allow 
  the 3-tier fallback to resolve them automatically.
- **Custom Category via `--category`**: Prioritizes a custom folder while retaining
  graceful fallback to the standard 3 categories:
  ```bash
  require_app my-tool --category apps-dev
  ```
- **Fail-Fast Execution**: If any dependency fails during its installation, `require_app`
  halts execution immediately and returns a non-zero exit code (`return 1`).
- **Instant Fast-Skip**: Each required recipe inspects its own state via `is_installed`,
  skipping in `<1ms` if already present.
- **Flag Propagation**: Global flags such as `--no-update` are deduplicated and forwarded
  automatically to all required dependencies.

### 2. `is_installed <target_name> [type] [display_name]`
Performs fast-path verification to check whether a package or application is already
installed, allowing recipes to exit in `<1ms`:
- **Supported Types**:
  - `command` (default): Checks binary presence in `$PATH` via `command -v`.
  - `apt` / `dpkg`: Checks package status via `dpkg-query -W -f='${Status}'` for `ok installed`.
  - `flatpak`: Checks Flatpak applications via `flatpak info`.
  - `snap`: Checks Snap applications via `snap list`.
- **Strict Self-Check Scope**: `is_installed` is strictly meant for an installer script
  to check **its own primary target** at the start. **NEVER** use `is_installed` to check
  dependencies or external packages — always use `require_app` for dependencies!
- **Display Name Rule**:
  - If the display name is identical to `target_name` (case-sensitive), 
    **do NOT pass the 3rd argument**:
    ```bash
    # Correct
    is_installed "curl"
    is_installed "ca-certificates" "apt"

    # Incorrect (redundant display name)
    is_installed "curl" "command" "curl"
    is_installed "ca-certificates" "apt" "ca-certificates"
    ```
  - Only pass `display_name` when it actually differs from `target_name`:
    ```bash
    is_installed "code" "command" "Visual Studio Code"
    is_installed "flatpak" "command" "Flatpak"
    is_installed "com.spotify.Client" "flatpak" "Spotify"
    ```
- **Output Formatting**: Logs `[i] <display_name> is already installed, skipping...` (or
  `[i] <display_name>: <target_name> is already installed, skipping...` if they differ
  case-insensitively).
- **Force Reinstallation**: Respects `FORCE=true` (or `--force`), returning `1` to bypass
  skipping when reinstallation or update is explicitly requested.
- **Pure Existence Query via `--check`**:
  When passed `--check`, `is_installed` operates in silent query mode:
  ```bash
  is_installed --check <target_name> [type]
  ```
  - Suppresses console logging (`[i] ... skipping...`).
  - Bypasses and ignores `$FORCE`, performing a factual query against host reality.
  - Returns exit code `0` if present, `1` if not.
  - **Permitted Use Scope**: While `is_installed` is primarily intended as an installer's
    own top-level self-check, `is_installed --check` **may** be used by other scripts
    **only** when the goal is purely to inspect whether an application, tool, or binary is
    present *without any intention of installing it* (e.g., validating user CLI input or
    inspecting non-managed binaries).
  - **Strict Prohibition**: Scripts must **NEVER** use `is_installed` or `is_installed --check`
    to test for a dependency and then proceed to install it manually. Installing dependencies
    is strictly the responsibility of `require_app`.

### 3. `conditional_apt_update [--force]`
Executes `sudo apt-get update` unless `SKIP_UPDATE` is set to `true` (e.g., when `--no-update`
is passed or during batch runs).
- **Direct Invocation**: Call `conditional_apt_update` directly without wrapping it in an
  `if` condition or manual check:
  ```bash
  # Correct
  conditional_apt_update

  # Incorrect (redundant manual check)
  if [[ "$SKIP_UPDATE" != "true" ]]; then
      sudo apt-get update
  fi
  ```
- **Distinction from Repository Updates**: `conditional_apt_update` standardizes the upfront
  package index check. If a recipe adds a third-party PPA, custom GPG keyring, or new
  APT repository list, it must directly call `sudo apt-get update` after adding the
  repository. Pass `--force` to `conditional_apt_update` if you need to run unconditionally
  while respecting the helper.

### 4. `ensure_local_bin_in_path`
Ensures `~/.local/bin` exists, exports it to current process `$PATH`, and permanently
persists it to `~/.bashrc`, `~/.zshrc`, and `~/.profile` if not already present.

### 5. GNOME Extension Helpers
- **`install_gnome_extension <uuid> [display_name]`**: Queries extensions.gnome.org API
  for the host GNOME Shell version, downloads candidate archive, inspects `metadata.json`
  to verify Shell compatibility and version before installing, compiles schemas, and
  enables the extension.
- **`compare_extension_version <zip_path> [uuid]`**: Compares downloaded extension version
  against the installed copy to avoid downgrading or unnecessary reinstallations.
- **`check_extension_archive_compatibility <zip_path>`**: Inspects `metadata.json` inside
  downloaded zip to confirm host GNOME Shell version compatibility before installation.

---

## Architectural Rules & Standards for Recipes

To maintain modularity, speed, and zero code duplication, every script in `linux/install`
must adhere strictly to the following framework rules:

### Rule 1: Every Installer Must Self-Check via `is_installed`
At the very top of every installer (immediately after parsing options), check if the
application is already installed:
```bash
is_installed "my-tool" && exit 0
```
This guarantees `<1ms` fast-skips when running batches or re-executing installers.

### Rule 2: `is_installed` Is Strictly for Self-Checks
Never use `is_installed` to inspect external dependencies or third-party packages with
the goal of installing them. Let `require_app` handle dependencies, which in turn runs the
dependency recipe's own `is_installed` check.
The only exception is using `is_installed --check <target>` when a script purely needs to
inspect whether a tool or binary is present on the system without intending to install it
(e.g., validating user CLI input or inspecting non-managed binaries). Never follow an
`is_installed` check with a manual installation — that is strictly the role of `require_app`.

### Rule 3: Never Check Dependency Presence Manually
Never wrap `require_app` in `if ! command -v ...` or `if ! dpkg ...`:
```bash
# Correct
require_app curl ca-certificates gnupg

# Incorrect (redundant manual checks)
if ! command -v curl >/dev/null 2>&1; then
    require_app "curl"
fi
```
Because the required recipe already contains its own `is_installed` self-check, manual
checks in caller scripts are completely redundant and add unnecessary boilerplate.

### Rule 4: Never Check Conditions or Pass `--no-update` Manually to Utility Functions
- **Zero Wrapping Checks**: Never wrap `require_app` or `conditional_apt_update` 
  in manual `if` blocks.
- **Automatic Flag Propagation**: **Never manually pass `--no-update` to `require_app` 
  or `conditional_apt_update`**. The helper functions automatically inspect the `$SKIP_UPDATE` 
  environment variable and propagate `--no-update` to all child recipes. Always call them directly:
  ```bash
  # Correct
  require_app git gnome-extensions sassc
  conditional_apt_update

  # Incorrect (redundant manual forwarding and if checks)
  if [[ "$SKIP_UPDATE" == "true" ]]; then
      require_app git gnome-extensions sassc --no-update
  else
      require_app git gnome-extensions sassc
  fi
  ```

### Rule 5: Every Installer Must Accept `--no-update` and Respect `SKIP_UPDATE`
To ensure both seamless standalone runs and efficient batch runs:
- **Standalone CLI Flag**: Every installer script must parse `--no-update` (or `--skip-update`) 
  and set `SKIP_UPDATE=true`. This allows users to run individual scripts without incurring 
  an unnecessary `apt-get update`:
  ```bash
  ./install.my-tool.sh --no-update
  ```
- **Environment Respect**: Every script must respect `SKIP_UPDATE` by calling 
  `conditional_apt_update`. This guarantees that batch runners (like `installer.sh`) and 
  parent `require_app` calls execute only a single upfront `apt update`, saving bandwidth 
  and preventing lock contention.

### Rule 6: Zero Inline Dependencies (Never Install Dependencies Directly)
- **No Shared Tool May Be Installed Inline**: Each recipe must only install **its own
  primary application, private libraries, or specific binaries**.
- Public CLI tools, libraries, or system services (such as `curl`, `wget`, `docker`,
  `python`, `unzip`, `gnupg`, `ca-certificates`, `flatpak`, `ufw`) must **NEVER** be
  installed inline via `apt install` or direct downloads inside another application's script.
- They must always be required using `require_app`.

### Rule 7: Introducing a New Dependency
If an application requires a dependency that does not yet exist as a recipe in the repository:
1. **Do not install it inline** inside the current script.
2. **First create a standalone recipe folder and installer** under `apps-recommended/`
   (e.g., `linux/install/apps-recommended/<new-dep>/install.<new-dep>.sh`).
3. Ensure the new recipe follows all standard conventions (`is_installed`, `conditional_apt_update`,
   `--no-update`, error handling).
4. Then, require it in your recipe via `require_app <new-dep>`.

### Rule 8: Syntax & Cleanliness Conventions
- **Combine `require_app`**: Call `require_app` once with all dependencies on a single
  line instead of multiple consecutive calls.
- **Omit Default Categories**: Do not pass `"apps-recommended"` or `"apps-extra"`, or 
  `apps-not-needed` to `require_app`. The 3-tier fallback automatically searches them in order.
- **Omit Redundant Display Names**: Do not pass the 3rd argument to `is_installed` if the
  display name matches the target name (case-sensitive).

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
3. Use the standard framework boilerplate (This is an example, not all apps need 
   these specific libraries):
   ```bash
   #!/usr/bin/env bash
   # Description: Install my-tool
   # Note: Idempotent and safe to run multiple times.

   set -euo pipefail

   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   source "${SCRIPT_DIR}/../../utils.sh"

   SKIP_UPDATE=false

   show_help() {
       cat <<EOF
   Usage: $(basename "$0") [OPTIONS]

   Options:
     --no-update   Skip apt update before installation
     -h, --help    Show this help message and exit
   EOF
   }

   while [[ $# -gt 0 ]]; do
       case "$1" in
           -h|--help)
               show_help
               exit 0
               ;;
           --no-update|--skip-update)
               SKIP_UPDATE=true
               shift
               ;;
           *)
               echo "Unknown option: $1" >&2
               exit 1
               ;;
       esac
   done

   # 1. Fast-path self-check (checks only this tool, drops display name if identical)
   is_installed "my-tool" && exit 0

   echo "[+] Starting installation/setup for my-tool..."

   # 2. Require shared dependencies (never inline, never manual checks, single call)
   require_app curl ca-certificates gnupg

   # 3. Conditional upfront APT update (no manual if check)
   conditional_apt_update

   # 4. Install tool
   sudo apt-get install -y my-tool
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
   require_app my-custom-tool --category apps-dev
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
