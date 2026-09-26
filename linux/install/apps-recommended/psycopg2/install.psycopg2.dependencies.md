# psycopg2 Dependencies Installation

These packages must be installed to be able to install and build `psycopg2` from pip.

For other Python versions, you must also specify the exact version, for example `python3.6-dev`.
For Python 2, you need to install `python-dev`.

```bash
sudo apt-get install python3-dev python3.7-dev python3.8-dev python3.9-dev python3.10-dev python3.11-dev
sudo apt-get install libpq-dev
```

## `pg_config` Configuration

You also need the `pg_config` program. It is usually installed by the `libpq-dev` package, but sometimes it is not in a `PATH` directory. Having it in the `PATH` greatly streamlines the installation, so try running `pg_config --version`. 

If it returns an error or an unexpected version number, then locate the directory containing the `pg_config` shipped with the right `libpq` version (usually `/usr/lib/postgresql/X.Y/bin/`) and add it to the `PATH`:

```bash
export PATH=/usr/lib/postgresql/X.Y/bin/:$PATH
```

> **Note:** You only need `pg_config` to compile `psycopg2`, not for its regular usage.

## Installing `psycopg2`

Now you can install `psycopg2` from pip:

```bash
pip install psycopg2
```
