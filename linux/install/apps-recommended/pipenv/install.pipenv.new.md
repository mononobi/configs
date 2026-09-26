# Install Pipenv

> **Note:** This will only work on Ubuntu 24.04 and newer.

## 1. Install virtualenv

First, install `virtualenv` using the following command:

```bash
sudo apt-get install virtualenv
```

## 2. Install pipenv

Then install `pipenv` using any version of Python that is not included in your distribution by default (e.g., 3.9). In this example, `python3.13` is used:

```bash
python3.13 -m pip install --user pipenv
```

## 3. Upgrade pip

Finally, upgrade `pip`:

```bash
python3.13 -m pip install --upgrade pip
```
