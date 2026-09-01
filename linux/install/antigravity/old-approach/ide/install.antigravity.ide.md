# Important:

This will install the Antigravity IDE with the AI agent mode. 
It is recommended to install the Antigravity Agent Manager instead to be able to use 
it with your favorite IDE or without IDE.

# 1. Create the keyrings directory

```bash
sudo mkdir -p /etc/apt/keyrings
```

# 2. Download and add the Google signing key

> Note: --batch --yes prevents GPG from hanging if it prompts for overwrites

```bash
curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | sudo gpg --dearmor --batch --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg
```

# 3. Add the Antigravity repository

```bash
echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null
```

# 4. Update the package list and install

```bash
sudo apt update
sudo apt install antigravity
```
