# Python 3 is Python

If you don't need to install Python 2 on your system and also want to prevent some apps
from raising errors when they're accessing `python`, you can execute the `script.sh` file.
After doing so, apps that access `python` will be redirected to `python3`.

```bash
./script.sh
```

Now you can type `python` in the terminal, and the Python 3 shell will open.

> **Note:** The script points to `python3.13`, but you can change it to point to any
> installed Python version you'd like to use.
