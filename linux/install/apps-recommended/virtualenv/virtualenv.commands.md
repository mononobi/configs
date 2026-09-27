# Virtualenv Commands

This guide provides common commands for using `virtualenv` to manage Python environments.

## Environment Management

- **Create environment:**
  ```bash
  virtualenv --python=python3.7 env
  ```
- **Activate environment:**
  ```bash
  source env/bin/activate
  ```

## Setting up a New Project

When setting up a new project with a single application, you might use the following
commands:

- **Allow server port through firewall (e.g., port 8000):**
  ```bash
  sudo ufw allow 8000
  ```
- **Install required packages:**
  ```bash
  pip install -r requirements.txt
  ```
- **Freeze current requirements to a file:**
  ```bash
  pip freeze > requirements.txt
  ```
