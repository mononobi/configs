# Install Python 3.8 from Source

## 1. Update Packages
```bash
sudo apt update
```

## 2. Install Build Dependencies
```bash
sudo apt install build-essential checkinstall zlib1g-dev libncursesw5-dev libncurses5-dev tk-dev libbz2-dev libgdbm-dev libnss3-dev libc6-dev openssl libssl-dev libreadline-dev libffi-dev wget libsqlite3-dev
```

## 3. Configure the Build
Configure the build with optimizations and shared libraries:
```bash
./configure --enable-optimizations --enable-loadable-sqlite-extensions --enable-shared --enable-framework
```

## 4. Compile Source Code
Use `-j` followed by the number of cores to speed up compilation (e.g., 4 cores):
```bash
make -j 4
```

## 5. Install Python
Choose one of the following installation methods:

To install alongside your existing Python version (generates `python3.8`):
```bash
sudo make altinstall
```

**OR** to overwrite the default Python 3 executable (`python3`):
```bash
sudo make install
```

## 6. Update Shared Libraries
Load the shared linker configuration:
```bash
sudo ldconfig /usr/local/lib
```

## 7. Verify the Installation
Check the installed Python version:
```bash
python3.8 --version
```

## 8. Install PIP
Install `pip` for Python 3:
```bash
sudo apt-get install python3-pip
```
Verify the `pip` version:
```bash
pip3 --version
```
