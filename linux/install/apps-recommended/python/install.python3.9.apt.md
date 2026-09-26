# Python 3.9 Installation Guide (APT)

This guide provides the steps to install Python 3.9 and its related tools using the `apt` package manager via the `deadsnakes` PPA.

## Installation Steps

1. Update the local package index and install the required common software properties:

```bash
sudo apt update
sudo apt install software-properties-common
```

2. Add the `deadsnakes` PPA repository:

```bash
sudo add-apt-repository ppa:deadsnakes/ppa
```

3. Install Python 3.9:

```bash
sudo apt install python3.9
```

4. Verify the Python 3.9 installation by checking its version:

```bash
python3.9 --version
```

5. Install `pip` for Python 3:

```bash
sudo apt-get install python3-pip
```

6. Verify the `pip3` installation by checking its version:

```bash
pip3 --version
```

7. Install the Python 3.9 development headers and the full suite of Python 3.9 packages:

```bash
sudo apt-get install python3.9-dev
sudo apt-get install python3.9-full
```
