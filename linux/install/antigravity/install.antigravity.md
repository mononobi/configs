# Install Antigravity

This is the recommended approach for installing both the `Antigravity V2` and `Antigravity IDE` 
with auto updates through apt.

Open your terminal and run the following commands:

```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | sudo tee /etc/apt/sources.list.d/google_antigravity.list > /dev/null
```

## Install Antigravity v2 Agent Manager (Recommended)

```bash
sudo apt update
sudo apt install antigravity
```

## Install Antigravity IDE (Not Recommended)

```bash
sudo apt update
sudo apt install antigravity-ide
```
