# Antigravity CLI (`agy`)

The Antigravity CLI (`agy`) is Google's terminal-based agentic coding assistant featuring
multi-step reasoning, tool execution, and multi-file editing.

## Installation

### Automated Framework Install

Run the recipe directly:

```bash
cd linux/install/apps-recommended/antigravity-cli && ./install.antigravity.cli.sh
```

Or invoke via `require_app`:

```bash
require_app "antigravity-cli"
```

### Manual Installation (Official Bootstrapper)

```bash
curl -fsSL https://antigravity.google/cli/install.sh | bash
```

The bootstrapper installs the `agy` binary into `~/.local/bin/` and configures shell
integrations.

## Getting Started

1. **Launch**:
   ```bash
   agy
   ```
2. **Authenticate**: On first launch, follow the on-screen browser/device authentication
   prompt.
3. **Slash Commands**: Inside the interactive TUI, type `/help` to view available
   commands.
4. **Exit**: Press `Ctrl+D` twice or type `/exit`.

## Configuration

Settings are stored in:

```
~/.gemini/antigravity-cli/settings.json
```

The installer automatically activates **dark mode** (`"colorScheme": "dark"`) upon
installation while preserving any existing custom settings:

```json
{
  "colorScheme": "dark"
}
```

## Documentation & References

- Documentation: [https://antigravity.google/docs](https://antigravity.google/docs)
- CLI Reference:
  [https://antigravity.google/docs/cli/reference](https://antigravity.google/docs/cli/reference)
- CLI Best Practices:
  [https://antigravity.google/docs/cli/best-practices](https://antigravity.google/docs/cli/best-practices)
