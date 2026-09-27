# Pipenv Commands Cheat Sheet

This guide provides a quick reference for common `pipenv` commands and their usage.

## Basic Commands

- `pipenv shell --python 3.7`: Create an environment for the first time and activate it
  using a specific Python version (e.g., 3.7).
- `pipenv shell`: Activate an already created environment.
- `pipenv lock`: Lock all installed requirements, updating the `Pipfile.lock`.
- `pipenv install --ignore-pipfile`: Install only `packages` (not `dev-packages`) into a
  new environment directly from `Pipfile.lock`. **Use this in production**.
- `pipenv install`: Install all `packages` and `dev-packages` into a new environment from
  the `Pipfile`. _Note: this may break in production if versions shift_.
- `pipenv install --dev`: Install all development and non-development package
  requirements.
- `pipenv check`: Check for security vulnerabilities in the current environment.
- `pipenv run <command>`: Run a specific command in the environment without fully
  activating the environment shell.
- `pipenv uninstall <dependency>`: Uninstall the specified dependency from the
  environment.
- `pipenv uninstall --all`: Uninstall **ALL** dependencies from the environment.
- `pipenv uninstall --all-dev`: Uninstall **ALL DEVELOPMENT** dependencies from the
  environment.
- `pipenv --venv`: View the physical location of the current environment on the
  filesystem.
- `pipenv sync`: Install or update all dependencies based exactly on what is in
  `Pipfile.lock`.
- `pipenv --rm`: Remove the current environment.

## Compatibility Commands (requirements.txt)

- `pipenv install -r requirements.txt`: Install dependencies from a traditional
  `requirements.txt` file.
- `pipenv install -r dev-requirements.txt --dev`: Install development dependencies from a
  traditional `requirements.txt` file as dev packages.
- `pipenv lock -r > requirements.txt`: Output locked requirements to an old-style
  `requirements.txt` file.
- `pipenv lock -r -d > dev-requirements.txt`: Output locked development requirements to an
  old-style `requirements.txt` file.

---

## Environment Variables

Pipenv supports the automatic loading of environmental variables when a `.env` file exists
in the top-level directory. That way, when you run `pipenv shell` to open the virtual
environment, it automatically loads your environmental variables from the file.

The `.env` file should contain key-value pairs, for example:

```env
SOME_ENV_CONFIG=some_value
SOME_OTHER_ENV_CONFIG=some_other_value
```
