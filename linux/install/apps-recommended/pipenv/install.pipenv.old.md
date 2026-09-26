# Install Pipenv (Old Method)

> **Warning:** This method will only work on Ubuntu 22.04 and older versions.

## Installation

For Python 2:
```bash
pip install pipenv
```

For Python 3:
```bash
pip3 install pipenv
```

> **Note:** Pipenv supports the automatic loading of environmental variables when a `.env` file exists in the top-level directory. That way, when you run `pipenv shell` to open the virtual environment, it automatically loads your environmental variables from the file.
> 
> The `.env` file should contain key-value pairs like this:
> ```env
> SOME_ENV_CONFIG=some_value
> SOME_OTHER_ENV_CONFIG=some_other_value
> ```

## Fixing a Broken Installation

> **Important Notes:** 
> 1. You should not install Pipenv using `apt-get`.
> 2. You should not install Virtualenv using `pip`.

If you already have a broken installation, follow the steps below to fix it:

1. Uninstall `virtualenv` and `pipenv` as a **non-root** user:
   ```bash
   pip uninstall vitualenv
   pip3 uninstall vitualenv
   pip uninstall pipenv
   pip3 uninstall pipenv
   ```

2. Uninstall `virtualenv` and `pipenv` as the **root** user:
   ```bash
   pip uninstall vitualenv
   pip3 uninstall vitualenv
   pip uninstall pipenv
   pip3 uninstall pipenv
   ```

3. Remove related APT packages as the **root** user:
   ```bash
   sudo apt remove virtualenv
   sudo apt remove python3-virtualenv
   ```

4. Install `virtualenv` using APT:
   ```bash
   sudo apt-get install virtualenv
   ```

5. Finally, install `pipenv` as a **non-root** user:
   ```bash
   pip3 install pipenv
   ```
