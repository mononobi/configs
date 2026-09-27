# Manual Installation of pgAdmin4

You should first add the required repository into the source list of Ubuntu, then install:

```bash
sudo apt install pgadmin4
```

## Installation on Distributions without Official Packages

Use this method on distributions where the official package is not available yet (for
example, right after a new major OS release).

First, install the necessary dependencies:

```bash
sudo apt-get install build-essential libssl-dev libffi-dev libgmp3-dev
sudo apt-get install python3-virtualenv libpq-dev python3-dev
```

Create a virtual environment in the location where you want to install pgAdmin:

```bash
mkdir pgadmin-project
cd pgadmin-project
virtualenv -p python3.8 pgadmin4
```

Activate the virtual environment:

```bash
cd pgadmin4
source bin/activate
```

Download the latest stable version of pgAdmin4 from the pip category:

```bash
wget https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v4.21/pip/pgadmin4-4.21-py2.py3-none-any.whl
```

Install the downloaded file using pip inside the virtual environment:

```bash
pip install pgadmin4-4.21-py2.py3-none-any.whl
```

Create a `config_local.py` file in the installation folder of pgAdmin4 inside the
`site-packages` of the virtual environment:

```bash
touch lib/python3.8/site-packages/pgadmin4/config_local.py
```

Add the following content into the created file:

```python
import os

DATA_DIR = os.path.realpath(os.path.expanduser(u'~/.pgadmin/'))
LOG_FILE = os.path.join(DATA_DIR, 'pgadmin4.log')
SQLITE_PATH = os.path.join(DATA_DIR, 'pgadmin4.db')
SESSION_DB_PATH = os.path.join(DATA_DIR, 'sessions')
STORAGE_DIR = os.path.join(DATA_DIR, 'storage')
SERVER_MODE = False
```

Run the following command inside the virtual environment to start the application. The
application will be accessible at `127.0.0.1:5050`:

```bash
python lib/python3.8/site-packages/pgadmin4/pgAdmin4.py
```

### Running with a Single Command

You can save the following commands as a script in `/usr/local/sbin` to run the
application easily:

```bash
#!/bin/bash

. {path_to_virtualenv_location}/bin/activate
python {path_to_virtualenv_location}/lib/python3.8/site-packages/pgadmin4/pgAdmin4.py
```
