# OpenCode

OpenCode is an open source AI coding agent that can connect to various AI models including
local and cloud-based models.

## Installation

```bash
curl -fsSL https://opencode.ai/install | bash
```

## Connecting to Local Models

```bash
mkdir -p ~/.config/opencode
cp opencode.json ~/.config/opencode/
```

> Change the model names in `opencode.json` file to the models you have installed locally.

## Connecting to GitHub Copilot Models

- In the chat prompt, type the command: `/connect`
- Use the arrow keys to scroll down the list of providers and select GitHub Copilot.
- OpenCode will generate a device code and provide a URL (usually github.com/login/device).
- Open that link in your Firefox or Chrome browser, paste the code, and click Authorize.
- Back in the OpenCode TUI, type: `/models`
- You will now see models prefixed with `github-copilot/`
  (for example, `github-copilot/claude-3.5-sonnet` or `github-copilot/gpt-4o`).
- Select the one you want to use for your current session.

### Set a GitHub Copilot model as the default model

Edit the `opencode.json` file and set the `model` key to the exact ID of your
preferred Copilot model:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "github-copilot/claude-3.5-sonnet",
  "provider": {
    "ollama": {
      // ... your existing local model configs stay here safely ...
    }
  }
}
```

## Usage

```bash
opencode
```
