## Ollama Installation Guide

Ollama is a local LLM (Large Language Model) server that allows you to run and manage LLMs on
your own machine. This guide will walk you through the installation process for Ollama.

### Install Ollama

```bash
mkdir -p ~/.ollama
cp docker-compose.yml ~/.ollama/
```

### Start Ollama

```bash
cd ~/.ollama
docker compose up -d
```

### Stop Ollama

```bash
cd ~/.ollama
docker compose down
```

### Ollama URLs

- Ollama API: `http://localhost:11434`
- Ollama Web UI: `http://localhost:3000`

> Note:
> Instead of using `localhost`, you can also use your machine's LAN IP address to access
> the Ollama API and Web UI from other devices on the same network.
> For example, `http://192.168.X.Y`. To find your machine's IP address,
> you can use the following command:

```bash
ip addr show
```

### Create Account

Navigate to the Ollama Web UI at `http://localhost:3000` and follow the instructions to
create an account.

### Add AI Models

Models that can be run with 32 GB of RAM and an iGPU:

- **General Purpose:**
    - `gemma2:9b`: `Faster`
    - `gemma3:12b`: `Slower`

- **Code Generation:**
    - `qwen2.5-coder:7b`: `Faster`
    - `qwen3-coder:30b`: `Slower`

### Important Settings

> **Settings -> Admin Settings:**

> **Connections:**
- **OpenAI API:** `Off`
- **Integration - Google Drive:** `On`

> **Models:** Click on each model and set the following options:
- **Default Features:** `All Off`
- **Access:** `Public`

> **Documents:**
- **PDF Extract Images (OCR):** `On`

> **Web Search:**
- **Web Search:** `On`
- **Web Search Engine:** `DDGS`
- **DDGS Backend:** `DuckDuckGo`

> **Interface:**
- **Voice Mode Custom Prompt:** `On`
- **All Other Options:** `Off`
