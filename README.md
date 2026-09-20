# Configs & Setup Framework

A curated collection of production-tested configurations, setup guidelines, and
automation scripts for Linux environments, development tools, databases, and IDEs.

> [!NOTE]
> The entire installation framework, automation scripts, and configurations in this
> repository are 100% AI-generated. No humans are to blame for any bugs, anti-patterns,
> or code design—all code was produced and maintained by AI under human supervision.

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
5. **Selective Skipping via `ignore` & Interactive Installers**: Any subfolder that contains an
   `ignore` file is automatically skipped during unattended batch installations (`installer.sh`,
   `install-recommended.sh`, `install-extra.sh`).
   - **Inherently Interactive Recipes**: Any installer that is inevitably interactive (requiring
     manual terminal choices, prompts for credentials, interactive wizards, or license acceptance)
     **must be intentionally marked with an `ignore` file** so it does not block unattended 
     batch runs.
   - **Interactive Batch Runner (`install-ignored.sh`)**: The framework provides 
     `install-ignored.sh` to perform an interactive batch installation across all ignored 
     applications, asking the user one-by-one (`[y/N]`) whether to install each one.
6. **Execution Logging & Summary**: The runner captures stdout/stderr per application,
   reports clear visual progress, and prints an end-of-run summary with exact failure
   diagnostics if an error occurs.
7. **Single Upfront APT Update**: Batch runners perform a single `apt update` at the start
   and pass `--no-update` to every subscript by default. This avoids redundant index
   downloads for each app, unless an app adds a custom repository that requires refreshing.
8. **Strict Idempotency**: Every recipe is idempotent—safe to execute repeatedly without
   unintended side effects, corrupted states, duplicate configurations, or redundant downloads.

---

## Shared Utilities & Dependency Management (`utils.sh`)

The framework provides shared helpers in `linux/install/utils.sh` to keep individual
scripts minimal, robust, and DRY. All installer scripts source this file.

### 1. `require_app [OPTIONS] <app1> [app2...]`
Resolves and executes application installers on demand:
- **Multiple Apps in One Call**: Accepts one or more application names separated by
  spaces (e.g., `require_app curl ca-certificates gnupg`). Always combine dependencies
  into a single call rather than repeating `require_app` across multiple lines.
- **Recipe Folder Names (Not Package Names)**: Positional arguments passed to `require_app`
  must always be the **folder name of the recipe in this repository** (e.g., `net-tools`,
  `xdg-user-dirs`, `debconf-utils`, `python`, `odbcinst`), **NOT** the underlying system package
  or binary name. `require_app` resolves the folder, enters it, and executes its installer script.
- **Automatic 3-Tier Fallback**: Automatically searches for recipes across categories in
  priority order:
  1. `apps-recommended/`
  2. `apps-extra/`
  3. `apps-not-needed/`
  Halts resolution as soon as a matching installer script is found. Never pass default
  category names (`apps-recommended`, `apps-extra`, `apps-no-needed`) to `require_app` — allow 
  the 3-tier fallback to resolve them automatically.
- **Direct Nested Path Resolution**: Accepts relative nested paths under standard categories 
  without needing `--category` or repeating `apps-recommended`:
  ```bash
  require_app "gnome-extensions/activator"
  require_app "gnome-extensions/recommended/color-picker"
  ```
- **Custom Category via `--category`**: Prioritizes an entirely custom top-level folder 
  (such as `apps-dev`) while retaining graceful fallback to the standard 3 categories:
  ```bash
  require_app my-tool --category apps-dev
  ```
- **Fail-Fast Execution**: If any dependency fails during its installation, `require_app`
  halts execution immediately and returns a non-zero exit code (`return 1`).
- **Instant Fast-Skip**: Each required recipe inspects its own state via `is_installed`,
  skipping in `<1ms` if already present.
- **Flag Propagation**: Global flags such as `--no-update` are deduplicated and forwarded
  automatically to all required dependencies.

### 2. `is_installed [OPTIONS] <target_name>`
Performs fast-path verification to check whether a package or application is already
installed, allowing recipes to exit in `<1ms`.
The target name is the **only positional argument**. All options are passed via named `--` flags:

- **Target Name is the Real Installed Package/Binary**:
  The positional `<target_name>` passed to `is_installed` is always the **real package,
  binary, or application ID installed on the host system** (e.g., `is_installed "netstat"`,
  `is_installed "xdg-user-dir"`, `is_installed "debconf-set-selections"`, 
  `is_installed "msodbcsql18"`). This directly contrasts with `require_app`, which takes 
  the **recipe folder name** in this repo.

- **Options**:
  - `--name <display_name>`: Custom human-readable display name for logs 
    (e.g. `--name "Visual Studio Code"`).
  - `--type <flatpak|snap>`: Specifies sandboxed runtime. Only `'flatpak'` or `'snap'` are accepted.
  - `--check`: Silent query mode. Performs a factual check, suppresses console logging, and 
    ignores `$FORCE`. Returns exit code `0` if present, `1` if not.

- **Smart Default Check (No Type Needed for CLI/APT)**:
  By default, `is_installed` checks binary presence in `$PATH` via `command -v`, and if not found, 
  falls back to `dpkg-query` for APT packages.
  - Arguments like `command`, `bin`, `apt`, or `dpkg` are **never passed**.
  - Recipes are completely decoupled from package packaging format (whether a tool is installed 
    via APT deb or direct binary in `~/.local/bin`, it detects seamlessly):
    ```bash
    is_installed "curl"
    is_installed "ca-certificates"
    ```

- **Sandboxed Packages (`--type flatpak` / `--type snap`)**:
  Because Flatpak and Snap are isolated runtimes not present in standard `$PATH`, the `--type` 
  flag must be explicitly passed:
  ```bash
  is_installed "com.spotify.Client" --type flatpak --name "Spotify"
  is_installed "canonical-livepatch" --type snap
  ```

- **Display Name Flag (`--name`)**:
  - If the display name is identical to `target_name` (case-sensitive), omit `--name`:
    ```bash
    # Correct
    is_installed "curl"
    is_installed "ca-certificates"

    # Incorrect (redundant --name)
    is_installed "curl" --name "curl"
    ```
  - Only pass `--name` when the human-readable display name differs:
    ```bash
    is_installed "code" --name "Visual Studio Code"
    is_installed "subl" --name "Sublime Text"
    is_installed "com.spotify.Client" --type flatpak --name "Spotify"
    ```

- **Strict Self-Check Scope**: `is_installed` is strictly meant for an installer script
  to check **its own primary target** at the start. **NEVER** use `is_installed` to check
  dependencies or external packages — always use `require_app` for dependencies!
- **Output Formatting**: Logs `[i] <display_name> is already installed, skipping...` (or
  `[i] <display_name>: <target_name> is already installed, skipping...` if they differ
  case-insensitively).
- **Force Reinstallation**: Respects `FORCE=true` (or `--force`), returning `1` to bypass
  skipping when reinstallation or update is explicitly requested.
- **Pure Existence Query via `--check`**:
  When passed `--check`, `is_installed` operates in silent query mode:
  ```bash
  is_installed --check <target_name>
  ```
  - Suppresses console logging (`[i] ... skipping...`).
  - Bypasses and ignores `$FORCE`, performing a factual query against host reality.
  - Returns exit code `0` if present, `1` if not.
  - **Strict Prohibition on Manual Package Checks**: Scripts must **NEVER** use manual
    shell commands (`command -v`, `which`, `dpkg-query`, `dpkg -l`, `flatpak list`,
    `flatpak info`, `snap list`) to check if a package or tool is installed. Always use
    `is_installed --check <target_name>`.
  - **Check As Sole Purpose Only**: `is_installed --check` may **only** be used when inspecting
    presence is the **sole purpose** and **NO installation should follow it** (e.g., validating 
    user CLI input, running optional updates on already-existing runtimes, or checking non-managed 
    host tools).
  - **Strict Prohibition on Manual Installation**: Scripts must **NEVER** use `is_installed`
    or `is_installed --check` to test for a dependency and then proceed to install it.
    If installation is intended, `require_app <folder_name>` must always be used.

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
  enables the extension. Automatically ensures the CLI activator via:
  ```bash
  require_app "gnome-extensions/activator"
  ```
- **`compare_extension_version <zip_path> [uuid]`**: Compares downloaded extension version
  against the installed copy to avoid downgrading or unnecessary reinstallations.
- **`check_extension_archive_compatibility <zip_path>`**: Inspects `metadata.json` inside
  downloaded zip to confirm host GNOME Shell version compatibility before installation.
- **Modular Subfolder Architecture**: Each recommended extension lives in its own dedicated
  directory under `apps-recommended/gnome-extensions/recommended/<extension-name>/` (containing
  its installer script and reference `.txt`).
- **4-Level Relative Depth**: Because extension recipes reside 4 directory levels 
  below `linux/install/`, they source `utils.sh` with 4 parent traversals:
  ```bash
  source "${SCRIPT_DIR}/../../../../utils.sh"
  ```
- **Dynamic Auto-Discovery Orchestrator**: The top-level runner `install.gnome.extensions.sh`
  dynamically auto-discovers all extension subfolders under `recommended/*/` and invokes them via:
  ```bash
  require_app "gnome-extensions/recommended/${ext_name}"
  ```
  Any newly added extension subfolder in `recommended/` is automatically discovered and installed
  without modifying orchestrator manifests.

---

## Architectural Rules & Standards for Recipes

To maintain modularity, speed, and zero code duplication, every script in `linux/install`
must adhere strictly to the following framework rules:

### Rule 1: Every Installer Must Be Idempotent and Self-Check Early
Every installation script must be **idempotent**—meaning it is safe and side-effect-free to 
execute multiple times on the same machine without duplicating configurations, corrupting files, 
or re-downloading packages if already present.

How to achieve idempotency across recipe types:
- **Standard APT & CLI Packages**: Perform a fast-path self-check via `is_installed` at the 
  very top of the installer (immediately after parsing options):
  ```bash
  is_installed "my-tool" && exit 0
  ```
  This guarantees `<1ms` fast-skips when running batches or re-executing installers 
  (bypassed only when `FORCE=true` or `--force` is passed).
- **Direct Tarballs, Binaries & Online Scripts**: For tools installed via custom tarballs, 
  direct GitHub releases, or remote installation scripts (e.g., Antigravity Agent Manager, 
  Rclone, Ventoy):
  - Perform custom version or state checks before downloading. Compare the installed local 
    version (via binary `--version`, inspecting application manifests, or reading a 
    `.version` marker file) against the latest remote release.
  - If the target binaries or desktop entries already exist and match the remote version, 
    skip immediately without re-downloading or re-extracting unless `--force` is explicitly 
    specified.
- **System Configurations & File Modifications**: Never blindly append lines to configuration 
  files or shell profiles. Always check whether the setting or block already exists 
  (e.g. via `grep -q`) before adding or updating it in place.


### Rule 2: `is_installed` Is Strictly for Self-Checks
Never use `is_installed` to inspect external dependencies or third-party packages with
the goal of installing them. Let `require_app` handle dependencies, which in turn runs the
dependency recipe's own `is_installed` check.

- **Folder Names vs. Real Package Names**:
  - `require_app <folder_name>`: The argument is always the **folder name of the recipe in 
    this repository** (e.g., `net-tools`, `xdg-user-dirs`, `debconf-utils`, `python`, `odbcinst`, 
    `gtk-update-icon-cache`), **not** the underlying package or binary name.
  - `is_installed <target_name>`: The argument is always the **real package, binary, 
    or application ID** installed on the system (e.g., `netstat`, `xdg-user-dir`, 
    `debconf-set-selections`, `python3.12`, `msodbcsql18`, `gtk-update-icon-cache`).
- **Pure Existence Queries via `--check`**:
  Using `is_installed --check <target>` is allowed **only** when inspecting whether a tool, 
  package, or runtime is present is the **sole purpose** and **no installation will follow** 
  (e.g., querying environment capabilities, validating user CLI options, or checking optional 
  runtimes for update tasks).
- **Strict Prohibition**: Never follow an `is_installed` or `is_installed --check` query with 
  a manual installation command (`apt-get install`, direct download, etc.) — installing 
  dependencies is strictly the role of `require_app`.

### Rule 3: Never Check Dependency Presence Manually
Scripts must **never** run manual shell commands (`command -v`, `which`, `dpkg-query`, `dpkg -l`,
`flatpak list`, `flatpak info`, `snap list`) to check whether a package is installed:
- **If installation is intended**: Never wrap `require_app` in manual checks:
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
- **If checking is the sole purpose (no installation intended)**: Never use raw `command -v` or
  package manager queries; use `is_installed --check`:
  ```bash
  # Correct
  if is_installed --check "flatpak"; then
      flatpak update -y
  fi

  # Incorrect (manual command -v)
  if command -v flatpak >/dev/null 2>&1; then
      flatpak update -y
  fi
  ```

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
- **Strict Single Positional Argument for `is_installed`**: Always pass only `<target_name>`
  as a positional argument to `is_installed`. Never pass dummy types like `"command"` or `"apt"`.
- **Display Names via `--name`**: Use `--name "Display Name"` only when the human-readable
  name differs from `target_name`.
- **Sandbox Types via `--type`**: Pass `--type flatpak` or `--type snap` only for Flatpak
  or Snap packages. Standard CLI tools and APT packages use the default smart check and
  must never pass `--type`.
- **Symlinked Scripts Must Calculate Paths from Real Canonical Location**: When a recipe folder
  in `apps-recommended/` or `apps-extra/` contains a symlink pointing to an external script
  outside `linux/install/` (e.g. `linux/vpn-server-setup/conduit-node/`), the script resolves
  its location using `readlink -f "${BASH_SOURCE[0]}"`. Sourcing `utils.sh` and resolving local
  assets must be computed relative to the **real target file location**, never from the symlink
  directory.

### Rule 9: Always Use `apt-get` (Never `apt`) in Scripts
All scripts and automation recipes must invoke `apt-get` (e.g., `sudo apt-get install -y`,
`sudo apt-get update`) and **never bare `apt`**:
- **Script-Safe Stability**: `apt-get` provides a 100% backward-compatible, deterministic
  CLI interface designed specifically for automation. Its flags, options, and behaviors
  remain rock-solid across Ubuntu/Debian releases.
- **Unstable CLI in `apt`**: The high-level `apt` binary is meant solely for human terminal
  interaction. Using `apt` inside scripts emits warnings (`WARNING: apt does not have a stable
  CLI interface. Use with caution in scripts.`) and Debian explicitly reserves the right to
  change its output format and flags between releases.
- **Log & Pipe Cleanliness**: `apt-get` outputs clean, machine-friendly text without ANSI
  terminal formatting, dynamic progress bars, or interactive prompts that corrupt log files
  or hang headless batch runners.

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
5. **Marking with `ignore` for Inherently Interactive Recipes**:
   - If an application installer is **inevitably or inherently interactive** (e.g. requires manual
     terminal prompts, license agreements, or interactive setup wizardry), or should only run 
     on demand, you **must mark its folder with an `ignore` file**:
     ```bash
     touch linux/install/apps-recommended/my-tool/ignore
     ```
   - This ensures unattended batch runners (`installer.sh`, `install-recommended.sh`) run cleanly
     without hanging on user prompts, while still allowing the recipe to be run on demand, required
     via `require_app`, or batch-installed through `install-ignored.sh`.

#### Sourcing `utils.sh` by Directory Depth
Ensure the relative path to `utils.sh` matches the script's directory depth from `linux/install/`:
- **Standard 2-Level Depth** (`apps-recommended/<app>/` or `apps-extra/<app>/`):
  ```bash
  source "${SCRIPT_DIR}/../../utils.sh"
  ```
- **Nested 4-Level Depth** (e.g. `apps-recommended/gnome-extensions/recommended/<ext>/`):
  ```bash
  source "${SCRIPT_DIR}/../../../../utils.sh"
  ```
- **Symlinked Scripts Outside `linux/install/` (Real Target Path Rule)**:
  When an installer script physically resides outside `linux/install/` (such as in 
  `linux/fonts/`, `linux/icons/`, `linux/templates/`, `linux/llm/ollama/`, 
  `linux/vpn/express-vpn/express-openvpn/`, or `linux/vpn-server-setup/conduit-node/`) 
  and is symlinked into `linux/install/apps-recommended/` or `apps-extra/`, scripts resolve 
  their directory using `readlink -f`:
  ```bash
  SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
  SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
  ```
  > [!IMPORTANT]
  > Because `readlink -f` dereferences symlinks to the **canonical target location 
  > outside `install/`**, `SCRIPT_DIR` resolves to the physical directory on disk, 
  > **not the symlink path** inside `apps-recommended/` or `apps-extra/`.
  > 
  > Therefore, relative paths to `utils.sh` (as well as relative paths to config files 
  > and local assets) **must always be calculated from the real file location**, 
  > targeting `install/utils.sh`:
  > - **1 level under `linux/`** (e.g., `linux/fonts/`, `linux/icons/`, `linux/templates/`):
  >   ```bash
  >   source "${SCRIPT_DIR}/../install/utils.sh"
  >   ```
  > - **2 levels under `linux/`** (e.g., `linux/vpn-server-setup/conduit-node/`, 
  >   `linux/llm/ollama/`):
  >   ```bash
  >   source "${SCRIPT_DIR}/../../install/utils.sh"
  >   ```
  > - **3 levels under `linux/`** (e.g., `linux/vpn/express-vpn/express-openvpn/`):
  >   ```bash
  >   source "${SCRIPT_DIR}/../../../install/utils.sh"
  >   ```
  > 
  > Never assume the relative path to `utils.sh` is `../../utils.sh` when the physical file 
  > lives outside `linux/install/`.

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

### 3. Interactive Batch Installation for Ignored Applications (`install-ignored.sh`)

Unattended batch runners (`install-recommended.sh`, `installer.sh`) deliberately skip any folder
containing an `ignore` file to ensure non-blocking, automated execution. All recipes that are
inevitably interactive are intentionally marked with an `ignore` file.

To perform a batch installation across ignored and interactive applications in a controlled,
guided manner, use `install-ignored.sh`:

```bash
# Interactively iterate through ignored recommended applications (default)
./linux/install/install-ignored.sh

# Interactively iterate through ignored applications in another category
./linux/install/install-ignored.sh -c apps-extra
```

**How it works**:
- Scans all ignored application recipes in the selected category (defaulting to `apps-recommended`).
- Prompts for each ignored application one-by-one: `Install <app_name>? [y/N]`.
- Default answer is **No** (simply pressing `<Enter>` skips the application).
- Entering `y` or `yes` runs that application installer (passing `--no-update`), logs output, 
  and moves on to the next.
- Automatically maintains `sudo` keepalive in the background and prints an end-of-run summary 
  of installed vs. skipped applications.

### 4. Inspecting Ignored Applications (`list-ignored.sh`)

To see all folders marked with an `ignore` file across categories:
```bash
# List all ignored recipes across all categories
./linux/install/list-ignored.sh

# Filter ignored recipes for a specific category
./linux/install/list-ignored.sh -c apps-recommended

# Output plain folder names only (for scripting and loops)
./linux/install/list-ignored.sh --names-only -c apps-recommended
```
